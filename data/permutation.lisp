;********************************************************
; file:        permutation.lisp                        
; description: Permutations
; date:        Sun Mar 26 2006 - 11:51                   
; author:      Liam M. Healy                             
; modified:    Tue Apr 18 2006 - 23:27
;********************************************************
;;; $Id: $

(in-package :gsl)

;;;;****************************************************************************
;;;; Permutation structure and CL object
;;;;****************************************************************************

;;; GSL-permutation definition
(cffi:defcstruct gsl-permutation-c
  (size :size)
  (data :pointer))

;;; Allocation, freeing, reading and writing
(defdata "permutation" :size 'fixnum)

(defmethod gsl-array ((object gsl-permutation))
  (foreign-slot-value (pointer object) 'gsl-permutation-c 'data))

(add-wrap-type gsl-permutation-c (lambda (x) `(pointer ,x)))

;;;;****************************************************************************
;;;; Getting values
;;;;****************************************************************************

(defun-gsl gsl-aref
    (((pointer permutation) :pointer) ((first indices) :size))
  "gsl_permutation_get"
  :method ((permutation gsl-permutation) &rest indices)
  :return (:size)
  :c-return-value :return
  :documentation "The ith element of the permutation.")

;;;;****************************************************************************
;;;; Setting values
;;;;****************************************************************************

(defun-gsl set-identity (((pointer permutation) :pointer))
     "gsl_permutation_init"
     :method ((permutation gsl-permutation))
     :documentation
     "Initialize the permutation @var{p} to the identity, i.e.
   @math{(0,1,2,@dots{},n-1)}.")

(defun-gsl permutation-copy
    ((destination gsl-permutation-c) (source gsl-permutation-c) )
  "gsl_permutation_memcpy"
  :after ((cl-invalidate destination))
  :documentation
  "Copy the elements of the permutation @var{src} into the
   permutation @var{dest}.  The two permutations must have the same size.")

(defun-gsl permutation-swap ((p gsl-permutation-c) (i :size) (j :size))
  "gsl_permutation_swap"
  :after ((cl-invalidate p))
  :documentation
  "Exchanges the @var{i}-th and @var{j}-th elements of the
   permutation @var{p}.")

;;;;****************************************************************************
;;;; Permutation properties
;;;;****************************************************************************

(defun-gsl permutation-size ((p gsl-permutation-c))
  "gsl_permutation_size"
  :c-return-value :return
  :return (:size) 
  :documentation
  "The size of the permutation @var{p}.")

(defun-gsl permutation-data ((p gsl-permutation-c))
  "gsl_permutation_data"
  :c-return-value :return
  :return (:pointer) 
  :documentation
  "A pointer to the array of elements in the
   permutation @var{p}.")

(defun-gsl data-valid (((pointer permutation) :pointer))
  "gsl_permutation_valid"
  :method ((permutation gsl-permutation))
  :c-return-value :return
  :return (:boolean) 
  :documentation
  "Check that the permutation @var{p} is valid.  The @var{n}
elements should contain each of the numbers 0 to @math{@var{n}-1} once and only
once.")

;;;;****************************************************************************
;;;; Permutation functions
;;;;****************************************************************************

(defun-gsl permutation-reverse ((p gsl-permutation-c))
  "gsl_permutation_reverse"
  :after ((cl-invalidate p))
  :c-return-value :void
  :documentation
  "Reverse the order of the elements of the permutation @var{p}.")

(defun-gsl permutation-inverse ((inv gsl-permutation-c) (p gsl-permutation-c))
  "gsl_permutation_inverse"
  :after ((cl-invalidate inv))
  :documentation
  "Reverse the order of the elements of the permutation @var{p}.")

(defun-gsl permutation-next ((p gsl-permutation-c))
  "gsl_permutation_next"
  :c-return-value :success-failure
  :after ((cl-invalidate p))
  :documentation
  "Advance the permutation @var{p} to the next permutation
   in lexicographic order and return T.  If no further
   permutations are available, return NIL and leave
   @var{p} unmodified.  Starting with the identity permutation and
   repeatedly applying this function will iterate through all possible
   permutations of a given order.")

(defun-gsl permutation-previous ((p gsl-permutation-c))
  "gsl_permutation_prev"
  :c-return-value :success-failure
  :after ((cl-invalidate p))
  :documentation
  "Step backwards from the permutation @var{p} to the
   previous permutation in lexicographic order, returning T.
   If no previous permutation is available, return
   NIL and leaves @var{p} unmodified.")

;;;;****************************************************************************
;;;; Applying Permutations
;;;;****************************************************************************

(defun-gsl permute
    ((p gsl-permutation-c) (data :pointer) (stride :size) (n :size))
  "gsl_permute"
  :documentation
  "Apply the permutation @var{p} to the array @var{data} of
   size @var{n} with stride @var{stride}.")

(defun-gsl permute-inverse
    ((p gsl-permutation-c) (data :pointer) (stride :size) (n :size))
  "gsl_permute_inverse"
  :documentation
  "Apply the inverse of the permutation @var{p} to the array @var{data} of
   size @var{n} with stride @var{stride}.")

(defun-gsl permute-vector ((p gsl-permutation-c) (v gsl-vector-c))
  "gsl_permute_vector"
  :after ((cl-invalidate v))
  :documentation
  "Apply the permutation @var{p} to the elements of the
   vector @var{v}, considered as a row-vector acted on by a permutation
   matrix from the right, @math{v' = v P}.  The @math{j}-th column of the
   permutation matrix @math{P} is given by the @math{p_j}-th column of the
   identity matrix. The permutation @var{p} and the vector @var{v} must
   have the same length.")

(defun-gsl permute-vector-inverse ((p gsl-permutation-c) (v gsl-vector-c))
  "gsl_permute_vector_inverse"
  :after ((cl-invalidate v))
  :documentation
  "Apply the inverse of the permutation @var{p} to the
  elements of the vector @var{v}, considered as a row-vector acted on by
  an inverse permutation matrix from the right, @math{v' = v P^T}.  Note
  that for permutation matrices the inverse is the same as the transpose.
  The @math{j}-th column of the permutation matrix @math{P} is given by
  the @math{p_j}-th column of the identity matrix. The permutation @var{p}
  and the vector @var{v} must have the same length.")

(defun-gsl permutation*
    ((p gsl-permutation-c) (pa gsl-permutation-c) (pb gsl-permutation-c))
  "gsl_permutation_mul"
  :after ((cl-invalidate p))
  :documentation
  "Combine the two permutations @var{pa} and @var{pb} into a
  single permutation @var{p}, where @math{p = pa . pb}. The permutation
  @var{p} is equivalent to applying @math{pb} first and then @var{pa}.")

;;;;****************************************************************************
;;;; Permutations in cyclic form
;;;;****************************************************************************

(defun-gsl linear-to-canonical ((q gsl-permutation-c) (p gsl-permutation-c))
  "gsl_permutation_linear_to_canonical"
  :after ((cl-invalidate q))
  :documentation
  "Compute the canonical form of the permutation @var{p} and
   stores it in the output argument @var{q}.")

(defun-gsl canonical-to-linear ((p gsl-permutation-c) (q gsl-permutation-c))
  "gsl_permutation_canonical_to_linear"
  :after ((cl-invalidate p))
  :documentation
  "Convert a permutation @var{q} in canonical form back into
   linear form storing it in the output argument @var{p}.")

(defun-gsl inversions ((p gsl-permutation-c))
  "gsl_permutation_inversions"
  :c-return-value :return
  :return (:size)
  :documentation
  "Count the number of inversions in the permutation
  @var{p}.  An inversion is any pair of elements that are not in order.
  For example, the permutation 2031 has three inversions, corresponding to
  the pairs (2,0) (2,1) and (3,1).  The identity permutation has no
  inversions.")

(defun-gsl linear-cycles ((p gsl-permutation-c))
  "gsl_permutation_linear_cycles"
  :c-return-value :return
  :return (:size)
  :documentation
  "Count the number of cycles in the permutation @var{p}, given in linear form.")

(defun-gsl canonical-cycles ((p gsl-permutation-c))
  "gsl_permutation_canonical_cycles"
  :c-return-value :return
  :return (:size)
  :documentation
  "Count the number of cycles in the permutation @var{q},
   given in canonical form.")

;;;;****************************************************************************
;;;; Examples
;;;;****************************************************************************

#|
(with-data (perm permutation 4 t)
  (loop collect (data perm 'list)
    while (permutation-next perm)))

((0 1 2 3) (0 1 3 2) (0 2 1 3) (0 2 3 1) (0 3 1 2) (0 3 2 1) (1 0 2 3)
 (1 0 3 2) (1 2 0 3) (1 2 3 0) (1 3 0 2) (1 3 2 0) (2 0 1 3) (2 0 3 1)
 (2 1 0 3) (2 1 3 0) (2 3 0 1) (2 3 1 0) (3 0 1 2) (3 0 2 1) (3 1 0 2)
 (3 1 2 0) (3 2 0 1) (3 2 1 0))
|#