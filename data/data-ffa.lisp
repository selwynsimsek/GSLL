;; Data using ffa
;; Liam Healy 2008-04-06 21:23:41EDT data-ffa.lisp
;; Time-stamp: <2008-04-27 18:23:54EDT data-ffa.lisp>
;; $Id$

(in-package :gsl)

;;;;****************************************************************************
;;;; The class gsl-data and element types that make subclasses
;;;;****************************************************************************

(defclass gsl-data ()
  ((cl-array :initarg :cl-array :accessor cl-array :documentation "The Lisp array.")
   (mpointer :initarg :mpointer :accessor mpointer
	     :documentation "A pointer to the GSL representation of the data.")
   (block-pointer :initform nil :accessor block-pointer
		  :documentation "A pointer to the gsl-block-c.")
   (c-pointer :initarg :c-pointer :accessor c-pointer
	      :documentation "A pointer to the C array.")
   (dimensions :initarg :dimensions :reader dimensions)
   (total-size :initarg :total-size :reader total-size)
   (element-type :initarg :element-type :reader element-type)
   #-native
   (cl-invalid
    :initform t :accessor cl-invalid
    :documentation
    "An indication of whether the Lisp object (slot 'data) agrees with the
     GSL C data.  If NIL, they agree.  If T, they disagree in an unspecified
     way.  If a list of index sets, those indices disagree and the remainder
     are correct.")
   #-native
   (c-invalid
    :initform t :accessor c-invalid
    :documentation
    "An indication of whether the GSL C data agrees with the
     Lisp object (slot 'data).  If NIL, they agree.  If T,
     they disagree in an unspecified
     way.  If a list of index sets, those indices disagree and the remainder
     are correct."))
  (:documentation
   "A superclass for all data storage structures, such as vector, matrix,
   etc."))

(defmethod print-object ((object gsl-data) stream)
  (print-unreadable-object (object stream :type t) 
    (copy-c-to-cl object)
    (princ (cl-array object) stream)))

;;;;****************************************************************************
;;;; Definition of specific data classes
;;;;****************************************************************************

(defparameter *class-element-type* nil
  ;;; This is needed for make-data-from-dimensions
  "The mapping between the class name and the CL element type.")

(defun data-class-name (category element-type)
  "The class name from the type of element."
  ;; e.g. (data-class-name 'vector '(unsigned-byte 8))
  ;; -> VECTOR-UNSIGNED-BYTE-8
  (intern (format nil "~a-~a" category (cl-single element-type))
	  :gsl))

(defparameter *array-element-types*
  (all-types ffa::*cffi-and-lisp-types* t)
  "All the array element types supported.")

(defun data-defclass (category superclass)
  "Define all the subclasses based on the known element types."
  (cons 'progn
	(mapcan
	 (lambda (element-type-cl)
	   (let* ((class-name (data-class-name category element-type-cl)))
	     ;; Define the class
	     `((defclass ,class-name
		   (,superclass)
		 ((element-type :initform ',element-type-cl
				:allocation :class)))
	       ;; Define the letm-expansion method
	       (defmethod letm-expansion
		   (symbol (type (eql ',class-name)) args body)
		 (expand-data symbol type (first args) (second args) body))
	       ;; Push mapping onto *class-element-type*
	       (pushnew ',(cons class-name element-type-cl)
		*class-element-type* :test #'equal)
	       ;; Set up dummy function to provide arglist and documentation
	       (arglist-only
		,class-name
		,(format nil "A ~(~a~) of element type ~(~a~)."
			 category element-type-cl)
		dimensions-or-init
		sync-array-on-exit))))
	 *array-element-types*)))

;;;;****************************************************************************
;;;; Make data from either the dimensions provided or from the initial values
;;;;****************************************************************************

(defun make-data-from-array (class array)
  "Make the data object from the CL array make with make-array*."
  (make-instance class
		 :cl-array array
		 :mpointer nil	; this will be set by :before method below.
		 :c-pointer nil		; this will be set by defmfun
		 :dimensions (array-dimensions array)
		 :total-size (array-total-size array)))

(defun make-data-from-dimensions (type dimensions)
  (make-data-from-array
   type
   (make-array* dimensions (lookup-type type *class-element-type*))))

(defun make-data (type array-or-dimensions)
  (if (typep array-or-dimensions 'array)
      (make-data-from-array type array-or-dimensions)
      (make-data-from-dimensions type array-or-dimensions)))

;;; ... or from the pointer which was malloced by GSL
(defun make-data-from-pointer (pointer &optional (class 'vector-double-float) size)
  "Given a C pointer to a GSL data type, make the CL object."
  )

;;;;****************************************************************************
;;;; Expand letm bindings
;;;;****************************************************************************

(export 'els)
(defun expand-data (symbol type init-or-spec sync-exit body)
  "Expand the form for a gsl-data object.  The symbol is bound
   within the body to the object.  The argument
   init-or-spec is either the
   array dimensions or something made by make-array*."
  (cl-utilities:with-unique-names (cptr)
    `(macrolet
      ;; #'els is a convenience macro to define the make-array*
      ((els (&rest contents)
	`(let ((cont ',contents))
	  (make-array*
	   (if (listp (first cont))	; make a matrix
	       (list (length cont) (length (first cont)))
	       (list (length cont)))	; make a vector
	   ',',(lookup-type type *class-element-type*)
	   :initial-contents
	   (if (listp (first cont))
	       (apply #'append cont)	; flatten lists
	       cont)))))
      (let ((,symbol (make-data ',type ,init-or-spec)))
	(ffa:with-pointer-to-array
	    ((cl-array ,symbol)
	     ,cptr
	     (cl-ffa (element-type ,symbol))
	     (total-size ,symbol)
	     nil)		      ; we need to allow nil direction
	  (unwind-protect
	       (multiple-value-prog1
		   (progn
		     (setf (c-pointer ,symbol) ,cptr)
		     ,@body)
		 ,@(when sync-exit `((copy-c-to-cl ,symbol))))
	    (free-gsl-struct ,symbol)))))))

;;;;****************************************************************************
;;;; Syncronize C and CL
;;;;****************************************************************************

;;; For implementations with separate C and CL storage (non-native),
;;; the two arrays must match when one side has updated and the other
;;; side wishes to refer to the values.  For native implementations,
;;; these don't do anything because they will always match.

;;; Called in defmfun expansion right before GSL function is entered.
(defun copy-cl-to-c (object)
  "Copy the CL array to the C array."
  (declare (ignorable object))
  #-native
  (when (c-invalid object)
    (ffa::copy-array-to-pointer
     (cl-array object)
     (c-pointer object)
     (cl-ffa (element-type object))
     (element-type object)
     0
     (total-size object))
    (setf (c-invalid object) nil)))

;;; Called right before maref
(defun copy-c-to-cl (object)
  "Copy the C array to the CL array."
  (declare (ignorable object))
  #-native
  (when (cl-invalid object)
    (ffa::copy-array-from-pointer
     (cl-array object)
     (c-pointer object)
     (cl-ffa (element-type object))
     (element-type object)
     0
     (total-size object))
    (setf cl-invalid nil)))

(defun maref (object &rest indices)
  "An element of the data."
  (copy-c-to-cl object)
  (apply 'aref (cl-array object) indices))

;;; Alternative to complete copy is to mark which elements have
;;; changed and just copy them.  Is it worth it?
(defun (setf maref) (value object &rest indices)
  "Set an element of the data."
  (apply '(setf aref) value (cl-array object) indices)
  #-native
  (setf c-invalid t))

;;;;****************************************************************************
;;;; C structures
;;;;****************************************************************************

;;; We don't allocate or free the C array data, because that is handled by ffa. 
;;; We can use the GSL functions *_alloc_from_block because they will allocate 
;;; only the structure, but we must use CFFI to allocate the block
;;; structure; otherwise it would try to allocate the C array.
;;; We do not use any of the GSL free functions because they would
;;; free the C array data.

(cffi:defcstruct gsl-block-c
  (size size)
  (data :pointer))

(defun alloc-gsl-struct (object)
  ;; Allocate the GSL structure; this should only be called from #'mpointer
  ;; thus it will be created only when first needed.
  (unless (c-pointer object) (error "No C array.")) ; safety while developing
  (let ((blockptr (cffi:foreign-alloc 'gsl-block-c)))
    (setf (block-pointer object)
	  blockptr
	  (cffi:foreign-slot-value blockptr 'gsl-block-c 'data)
	  (c-pointer object)
	  (cffi:foreign-slot-value blockptr 'gsl-block-c 'size)
	  (total-size object)
	  (mpointer object)
	  (alloc-from-block object))))

(defmethod mpointer :before ((object gsl-data))
  "Make a GSL struct if there isn't one already."
  (unless (slot-value object 'mpointer)
    (alloc-gsl-struct object)))

(defun free-gsl-struct (object)
  "Free the C structure(s) and memory for data."
  ;; This should happen immediately after the with-pointer-to-array
  ;; and substitutes for the GSL "_free" functions.
  (when (block-pointer object)
    (cffi:foreign-free (block-pointer object)) ; free the block struct
    (setf (block-pointer object) nil))
  (when (mpointer object)
    (cffi:foreign-free (mpointer object)) ; free the larger struct
    (setf (mpointer object) nil)))
