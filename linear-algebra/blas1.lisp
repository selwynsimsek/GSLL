;; BLAS level 1, Vector operations
;; Liam Healy, Wed Apr 26 2006 - 15:23
;; Time-stamp: <2008-02-17 10:24:18EST blas1.lisp>
;; $Id$

(in-package :gsl)

;;; Currently only includes vector-single and vector-double routines.
;;; Not ported: routines that use raw vectors gsl_blas_drotg, gsl_blas_drotmg, gsl_blas_drotm

;;;;****************************************************************************
;;;; Generic
;;;;****************************************************************************

(export '(dot norm asum imax swap copy axpy scal rot))

(defgeneric dot (vector1 vector2)
  (:documentation "Dot, or inner, product between vectors."))

(defgeneric norm (x)
  (:documentation			; FDL
   "The Euclidean norm ||x||_2 = \sqrt {\sum x_i^2} of the vector x."))

(defgeneric asum (x)
  (:documentation			; FDL
   "The absolute sum \sum |x_i| of the elements of the vector x."))

(defgeneric imax (x)
  (:documentation			; FDL
   "The index of the largest element of the vector
   x. The largest element is determined by its absolute magnitude for
   real vectors and by the sum of the magnitudes of the real and
   imaginary parts |\Re(x_i)| + |\Im(x_i)| for complex vectors. If the
   largest value occurs several times then the index of the first
   occurrence is returned."))

(defgeneric blas-swap (x y)
  (:documentation			; FDL
   "Exchange the elements of the vectors x and y"))

(defgeneric blas-copy (x y)
  (:documentation			; FDL
   "Copy the elements of the vector x into the vector y."))

(defgeneric axpy (alpha x y)
  (:documentation			; FDL
   "The sum y = \alpha x + y for the vectors x and y."))

(defgeneric scal (alpha x)
  (:documentation			; FDL
   "Rescale the vector x by the multiplicative factor alpha."))

(defgeneric rot (x y c s)
  (:documentation			; FDL
   "Apply a Givens rotation (x', y') = (c x + s y, -s x + c y) to the vectors x, y."))

;;;;****************************************************************************
;;;; Single
;;;;****************************************************************************

(defmfun sdot (result alpha vec1 vec2)
  "gsl_blas_sdsdot"
  ((alpha :float) ((pointer vec1) :pointer) ((pointer vec2) :pointer)
   ((gsl-array result) :pointer))
  :invalidate (result))

(defmfun dot ((vec1 gsl-vector-single) (vec2 gsl-vector-single))
  "gsl_blas_sdot"
  (((pointer vec1) :pointer) ((pointer vec2) :pointer) (result :float))
  :type :method)

(defmfun norm ((vec gsl-vector-single))
  "gsl_blas_snrm2"  (((pointer vec) :pointer))
  :type :method
  :c-return :float)

(defmfun asum ((vec gsl-vector-single))
  "gsl_blas_sasum" (((pointer vec) :pointer))
  :type :method
  :c-return :float)

(defmfun imax ((vec gsl-vector-single))
  "gsl_blas_isamax" (((pointer vec) :pointer))
  :type :method 
  :c-return :int)

(defmfun blas-swap ((vec1 gsl-vector-single) (vec2 gsl-vector-single))
  "gsl_blas_sswap" (((pointer vec1) :pointer) ((pointer vec2) :pointer))
  :type :method 
  :invalidate (vec1 vec2))

(defmfun blas-copy ((vec1 gsl-vector-single) (vec2 gsl-vector-single))
  "gsl_blas_scopy" (((pointer vec1) :pointer) ((pointer vec2) :pointer))
  :type :method
  :invalidate (vec2))

(defmfun axpy (alpha (vec1 gsl-vector-single) (vec2 gsl-vector-single))
  "gsl_blas_saxpy"
  ((alpha :float) ((pointer vec1) :pointer) ((pointer vec2) :pointer))
  :type :method 
  :invalidate (vec2))

(defmfun scal (alpha (vec gsl-vector-single))
  "gsl_blas_sscal" ((alpha :float) ((pointer vec) :pointer))
  :type :method 
  :invalidate (vec)
  :c-return :void)

(defmfun rot
    ((vec1 gsl-vector-single) (vec2 gsl-vector-single)
     (c float) (s float))
  "gsl_blas_srot"
  (((pointer vec1) :pointer) ((pointer vec2) :pointer) (c :float) (s :float))
  :type :method
  :invalidate (vec1 vec2))

;;;;****************************************************************************
;;;; Double
;;;;****************************************************************************

(defmfun dot ((vec1 gsl-vector-double) (vec2 gsl-vector-double))
  "gsl_blas_ddot"
  (((pointer vec1) :pointer) ((pointer vec2) :pointer) (result :double))
  :type :method)

(defmfun norm ((vec gsl-vector-double))
  "gsl_blas_dnrm2"  (((pointer vec) :pointer))
  :type :method
  :c-return :double)

(defmfun asum ((vec gsl-vector-double))
  "gsl_blas_dasum" (((pointer vec) :pointer))
  :type :method
  :c-return :double)

(defmfun imax ((vec gsl-vector-double))
  "gsl_blas_idamax" (((pointer vec) :pointer))
  :type :method 
  :c-return :int)

(defmfun blas-swap ((vec1 gsl-vector-double) (vec2 gsl-vector-double))
  "gsl_blas_dswap" (((pointer vec1) :pointer) ((pointer vec2) :pointer))
  :type :method 
  :invalidate (vec1 vec2))

(defmfun blas-copy ((vec1 gsl-vector-double) (vec2 gsl-vector-double))
  "gsl_blas_dcopy" (((pointer vec1) :pointer) ((pointer vec2) :pointer))
  :type :method
  :invalidate (vec2))

(defmfun axpy (alpha (vec1 gsl-vector-double) (vec2 gsl-vector-double))
  "gsl_blas_daxpy"
  ((alpha :double) ((pointer vec1) :pointer) ((pointer vec2) :pointer))
  :type :method 
  :invalidate (vec2))

(defmfun scal (alpha (vec gsl-vector-double))
  "gsl_blas_dscal" ((alpha :double) ((pointer vec) :pointer))
  :type :method 
  :invalidate (vec)
  :c-return :void)

(defmfun rot
    ((vec1 gsl-vector-double) (vec2 gsl-vector-double)
     (c float) (s float))
  "gsl_blas_drot"
  (((pointer vec1) :pointer) ((pointer vec2) :pointer) (c :double) (s :double))
  :type :method
  :invalidate (vec1 vec2))

;;;;****************************************************************************
;;;; Examples and unit test
;;;;****************************************************************************

#|
(make-tests blas1
 ;; single
 (letm ((a (vector-single #(1.0f0 2.0f0 3.0f0)))
	(b (vector-single #(3.0f0 4.0f0 5.0f0))))
   (dot a b))
 (letm ((b (vector-single #(3.0f0 4.0f0 5.0f0))))
   (norm b))
 (letm ((b (vector-single #(3.0f0 4.0f0 5.0f0))))
   (asum b))
 (letm ((b (vector-single #(3.0f0 5.0f0 4.0f0))))
   (imax b))
 (letm ((a (vector-single #(1.0f0 2.0f0 3.0f0)))
	 (b (vector-single #(3.0f0 4.0f0 5.0f0))))
    (setf (data a) #(1.0f0 2.0f0 3.0f0)
	  (data b) #(3.0f0 4.0f0 5.0f0))
    (axpy 2.0f0 a b)
    (data b))
 (letm ((b (vector-single #(3.0f0 4.0f0 5.0f0))))
    (setf (data b) #(3.0f0 4.0f0 5.0f0))
    (scal 2.0f0 b)
    (data b))
 (letm ((a (vector-single #(1.0f0 3.0f0)))
	 (b (vector-single #(8.0f0 9.0f0))))
    (rot a b (/ (sqrt 2.0f0)) (/ (sqrt 2.0f0)))
    (data b))
 ;; double
 (letm ((a (vector-double #(1.0d0 2.0d0 3.0d0)))
	(b (vector-double #(3.0d0 4.0d0 5.0d0))))
   (dot a b))
 (letm ((b (vector-double #(3.0d0 4.0d0 5.0d0))))
   (norm b))
 (letm ((b (vector-double #(3.0d0 4.0d0 5.0d0))))
   (setf (data b) #(3.0d0 4.0d0 5.0d0))
   (asum b))
 (letm ((b (vector-double #(3.0d0 5.0d0 4.0d0))))
   (setf (data b) #(3.0d0 5.0d0 4.0d0))
   (imax b))
 (letm ((a (vector-double #(1.0d0 2.0d0 3.0d0)))
	(b (vector-double #(3.0d0 4.0d0 5.0d0))))
   (blas-swap a b)
   (data a))
 (letm ((a (vector-double #(1.0d0 2.0d0 3.0d0)))
	(b (vector-double #(3.0d0 4.0d0 5.0d0))))
   (blas-copy b a)
   (data a))
 (letm ((a (vector-double #(1.0d0 2.0d0 3.0d0)))
	(b (vector-double #(3.0d0 4.0d0 5.0d0))))
   (axpy 2.0d0 a b)
   (data b))
 (letm ((b (vector-double #(3.0d0 4.0d0 5.0d0))))
   (scal 2.0d0 b)
   (data b))
 (letm ((a (vector-double #(1.0d0 3.0d0)))
	(b (vector-double #(8.0d0 9.0d0))))
   (rot a b (/ (sqrt 2.0d0)) (/ (sqrt 2.0d0)))
   (data b)))
|#

(LISP-UNIT:DEFINE-TEST BLAS1
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 26.0)
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-SINGLE #(1.0 2.0 3.0)))
	   (B (VECTOR-SINGLE #(3.0 4.0 5.0))))
      (DOT A B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 7.071068)
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-SINGLE #(3.0 4.0 5.0))))
      (NORM B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 12.0)
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-SINGLE #(3.0 4.0 5.0))))
      (ASUM B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 1)
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-SINGLE #(3.0 5.0 4.0))))
      (IMAX B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(5.0 8.0 11.0))
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-SINGLE #(1.0 2.0 3.0)))
	   (B (VECTOR-SINGLE #(3.0 4.0 5.0))))
      (SETF (DATA A) #(1.0 2.0 3.0)
	    (DATA B) #(3.0 4.0 5.0))
      (AXPY 2.0 A B) (DATA B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(6.0 8.0 10.0))
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-SINGLE #(3.0 4.0 5.0))))
      (SETF (DATA B) #(3.0 4.0 5.0)) (SCAL 2.0 B)
      (DATA B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(4.9497476 4.2426405))
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-SINGLE #(1.0 3.0)))
	   (B (VECTOR-SINGLE #(8.0 9.0))))
      (ROT A B (/ (SQRT 2.0)) (/ (SQRT 2.0))) (DATA B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 26.0d0)
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-DOUBLE #(1.0d0 2.0d0 3.0d0)))
	   (B (VECTOR-DOUBLE #(3.0d0 4.0d0 5.0d0))))
      (DOT A B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 7.0710678118654755d0)
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-DOUBLE #(3.0d0 4.0d0 5.0d0))))
      (NORM B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 12.0d0)
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-DOUBLE #(3.0d0 4.0d0 5.0d0))))
      (SETF (DATA B) #(3.0d0 4.0d0 5.0d0))
      (ASUM B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 1)
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-DOUBLE #(3.0d0 5.0d0 4.0d0))))
      (SETF (DATA B) #(3.0d0 5.0d0 4.0d0))
      (IMAX B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(3.0d0 4.0d0 5.0d0))
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-DOUBLE #(1.0d0 2.0d0 3.0d0)))
	   (B (VECTOR-DOUBLE #(3.0d0 4.0d0 5.0d0))))
      (BLAS-SWAP A B) (DATA A))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(3.0d0 4.0d0 5.0d0))
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-DOUBLE #(1.0d0 2.0d0 3.0d0)))
	   (B (VECTOR-DOUBLE #(3.0d0 4.0d0 5.0d0))))
      (BLAS-COPY B A) (DATA A))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(5.0d0 8.0d0 11.0d0))
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-DOUBLE #(1.0d0 2.0d0 3.0d0)))
	   (B (VECTOR-DOUBLE #(3.0d0 4.0d0 5.0d0))))
      (AXPY 2.0d0 A B) (DATA B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(6.0d0 8.0d0 10.0d0))
   (MULTIPLE-VALUE-LIST
    (LETM ((B (VECTOR-DOUBLE #(3.0d0 4.0d0 5.0d0))))
      (SCAL 2.0d0 B) (DATA B))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST #(4.949747468305832d0 4.242640687119286d0))
   (MULTIPLE-VALUE-LIST
    (LETM ((A (VECTOR-DOUBLE #(1.0d0 3.0d0)))
	   (B (VECTOR-DOUBLE #(8.0d0 9.0d0))))
      (ROT A B (/ (SQRT 2.0d0)) (/ (SQRT 2.0d0)))
      (DATA B)))))

