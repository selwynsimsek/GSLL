;********************************************************
; file:        data.lisp                                 
; description: Using GSL storage.                        
; date:        Sun Mar 26 2006 - 16:32                   
; author:      Liam M. Healy                             
; modified:    Wed Apr 12 2006 - 23:35
;********************************************************
;;; $Id: $

(in-package :gsl)

(defmacro gsl-data-functions (string base-type &optional (dimensions 1))
  "For the type named in the string,
   define the allocator (gsl-*-alloc), zero allocator (gsl-*-calloc),
   freeing (gsl-*-free), binary writing (binary-*-write) and
   reading (binary-*-read), formatted writing (write-*-formatted)
   and reading (read-*-formatted) functions."
  (flet ((gsl-name (function-name)
	   (format nil "gsl_~a_~a" string function-name))
	 (cl-name (action kind)
	   (intern (format nil "~a-~:@(~a~)-~a" action string kind))))
    (let ((indlist
	   (loop for i from 1 to dimensions
		 collect `(,(intern (format nil "N~d" i)) :size))))
      `(progn
	(defclass ,(intern (format nil "GSL-~:@(~a~)" string)) (gsl-data)
	  ((base-type :initform ,base-type :reader base-type :allocation :class)
	   (allocator :initform ,(gsl-name "alloc")
		      :reader allocator :allocation :class)
	   (callocator :initform ,(gsl-name "calloc")
		       :reader callocator :allocation :class)
	   (freer :initform ,(gsl-name "free")
		  :reader freer :allocation :class)))
	(cffi:defcfun ,(gsl-name "alloc") :pointer ,@indlist)
	(cffi:defcfun ,(gsl-name "calloc") :pointer ,@indlist)
	(cffi:defcfun ,(gsl-name "free") :void (pointer :pointer))
	(defun ,(cl-name 'write 'binary) (object stream)
	  (check-gsl-status
	   (cffi:foreign-funcall
	    ,(gsl-name "fwrite")
	    :pointer stream
	    :pointer object
	    :int)
	   ',(cl-name 'write 'binary)))
	(defun ,(cl-name 'read 'binary) (object stream)
	  (check-gsl-status
	   (cffi:foreign-funcall
	    ,(gsl-name "fread")
	    :pointer stream
	    :pointer object
	    :int)
	   ',(cl-name 'read 'binary)))
	(defun ,(cl-name 'write 'formatted) (object stream format)
	  "Format the block data to a stream; format is a string,
   one of %g, %e, %f."
	  (check-gsl-status
	   (cffi:foreign-funcall
	    "gsl_block_fprintf"
	    :pointer stream
	    :pointer object
	    :string format
	    :int)
	   ',(cl-name 'write 'formatted)))
	(defun ,(cl-name 'read 'formatted) (object stream)
	  "Read the formatted block data from a stream."
	  (check-gsl-status
	   (cffi:foreign-funcall
	    "gsl_block_fscanf"
	    :pointer stream
	    :pointer object
	    :int)
	   ',(cl-name 'read 'formatted)))))))

(defclass gsl-data ()
  ((pointer :initarg :pointer :reader pointer)
   (storage-size :initarg :storage-size :reader storage-size )))

;;; Accessing elements
(export 'gsl-aref)
(defgeneric gsl-aref (object &rest indices)
  (:documentation "An element of the data."))

(defgeneric (setf gsl-aref) (value object &rest indices)
  (:documentation "Set an element of the data."))

;;; Initializing elements
(export 'set-all)
(defgeneric set-all (object value)
  (:documentation "Set all elements to the value."))

(export 'set-zero)
(defgeneric set-zero (object)
  (:documentation "Set all elements to 0."))

(export 'set-identity)
(defgeneric set-identity (object)
  (:documentation "Set elements to represent the identity."))

(export 'data-import)
(defgeneric data-import (object from)
  (:documentation "Import the values from the CL object."))

(export 'data-export)
(defgeneric data-export (object)
  (:documentation "Create a CL object with the values."))

(export 'data-validate)
(defgeneric data-valid (object)
  (:documentation "Validate the values in the object."))

(export 'with-data)
(defmacro with-data ((symbol type size &optional zero) &body body)
  "Allocate GSL data, bind to pointer,
   and then deallocated it when done.  If zero is T, zero the
   contents when allocating."
  (flet ((cl-name (action)
	   (intern (format nil "GSL-~a-~a" type action))))
    (let ((ptr (gensym "PTR")))
      `(let* ((,ptr
	       (,(if zero (cl-name 'calloc) (cl-name 'alloc))
		 ,@(if (listp size) size (list size))))
	      (,symbol
	       (make-instance ',(intern (format nil "GSL-~a" type))
			      :pointer ,ptr)))
	(check-null-pointer ,ptr
	 :ENOMEM
	 (format nil "For '~a of GSL type ~a." ',symbol ',type))
	#+old
	(when (cffi:null-pointer-p ,ptr)
	  (error 'gsl-error
		 :gsl-errno (cffi:foreign-enum-value 'gsl-errorno :ENOMEM)
		 :gsl-reason
		 (format nil "For '~a of GSL type ~a." ',symbol ',type)))
	(unwind-protect 
	     (progn ,@body)
	  (,(cl-name 'free) ,ptr))))))

#+new
(defmacro with-data ((symbol type size &optional init validate) &body body)
  "Allocate GSL data, bind to pointer,
   and then deallocated it when done.  If init is T, init the
   contents when allocating."
  (flet ((cl-name (action)
	   (intern (format nil "GSL-~a-~a" type action))))
    (let ((ptr (gensym "PTR")))
      `(let* ((,ptr
	       (,(if (eq init t) (cl-name 'calloc) (cl-name 'alloc))
		 ,@(if (listp size) size (list size))))
	      (,symbol
	       (make-instance ',(intern (format nil "GSL-~a" type))
			      :pointer ,ptr)))
	(check-null-pointer ,ptr
	 :ENOMEM
	 (format nil "For '~a of GSL type ~a." ',symbol ',type))
	(unwind-protect 
	     (progn
	       ,@(case init
		       (:identity `((set-identity ,symbol)))
		       ((t) nil)
		       (t `((data-import ,symbol ,init))))
	       ,@(when
		  validate
		  `((unless (data-valid ,symbol)
		      (error "Invalid ~a, ~a" type init))))
	       ,@body)
	  (,(cl-name 'free) ,ptr))))))

#+new
(defun make-data (type size &optional init validate)
  "Make the GSL data, i.e. vector, matrix, combination, etc."
  (make-instance
   (intern (format nil "GSL-~a" type))
   :pointer pointer)
  (case init
    ((:fast :identity) (cl-name 'alloc))
    ((t) nil)
    (t `((data-import ,symbol ,init))))
  (case init
    (:identity `((set-identity ,symbol)))))

#+new
(defun free-data (data)
  )


;;;(with-data (p permutation 5 #(2 3 4 0) t)  foo)

#|
;;; Another version, that takes a passed-in array
(defmacro with-data*
    ((symbol type size &optional init validate) &body body)
  (let ((ptr (gensym "PTR")))
    `(cffi::with-foreign-array (,ptr ,type ,size)
      (let* ((,symbol
	      (make-instance ',(intern (format nil "GSL-~a" type))
			     :pointer ,ptr)))
	(progn
	  ,@(case init
		  (:identity `((set-identity ,symbol)))
		  ((t) nil)
		  (t `((data-import ,symbol ,init))))
	  ,@(when
	     validate
	     `((unless (data-valid ,symbol)
		 (error "Invalid ~a, ~a" type init))))
	  ,@body)))))

;;; test
#+test
(with-data* (comb combination (4 i) t)
  (loop collect (combination-list comb)
	while (combination-next comb)))


#+expansion
(CFFI::WITH-FOREIGN-ARRAY
    ;;;(#:PTR3308 COMBINATION (4 I))	; wrong
    (#:PTR3308 :size ????)	; want
  ;;; need to C-structure here.
  (LET* ((COMB
	  (MAKE-INSTANCE 'GSL-COMBINATION
			 :POINTER
			 #:PTR3308)))
    (PROGN
      (LOOP COLLECT
	    (COMBINATION-LIST COMB)
	    WHILE
	    (COMBINATION-NEXT COMB)))))
|#
