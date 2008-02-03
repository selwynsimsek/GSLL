;; Series acceleration.
;; Liam Healy, Wed Nov 21 2007 - 18:41
;; Time-stamp: <2008-02-02 19:33:39EST series-acceleration.lisp>
;; $Id: $

(in-package :gsl)

;;;;****************************************************************************
;;;; Creation and calculation of Levin series acceleration
;;;;****************************************************************************

(cffi:defcstruct levin
  "The definition of Levin series acceleration for GSL."
  (size :size)
  (position-in-array :size)
  (terms-used :size)
  (sum-plain :double)
  (q-num :pointer)
  (q-den :pointer)
  (dq-num :pointer)
  (dq-den :pointer)
  (dsum :pointer))

(set-asf (levin order) allocate-levin free-levin)

(defun-gsl allocate-levin (order)
  "gsl_sum_levin_u_alloc"
  ((order :size))
  :c-return :pointer
  :export nil
  :index (letm levin)
  :documentation
  "Allocate a workspace for a Levin @math{u}-transform of @var{n}
   terms.  The size of the workspace is @math{O(2n^2 + 3n)}.")

(defun-gsl free-levin (levin)
  "gsl_sum_levin_u_free"
  ((levin :pointer))
  :c-return :void		; Error in GSL manual, should be void?
  :export nil
  :index (letm levin)
  :documentation
  "Free a previously allocated Levin acceleration.")

(defun-gsl accelerate (array levin)
  "gsl_sum_levin_u_accel"
  (((gsl-array array) :pointer) ((dim0 array) :size) (levin :pointer)
   (accelerated-sum :double) (absolute-error :double))
  :documentation
  "From the terms of a series in @var{array}, compute the extrapolated
   limit of the series using a Levin @math{u}-transform.  Additional
   working space must be provided in levin.  The extrapolated sum is
   returned with an estimate of the absolute error.  The actual
   term-by-term sum is returned in 
   @code{w->sum_plain}. The algorithm calculates the truncation error
   (the difference between two successive extrapolations) and round-off
   error (propagated from the individual terms) to choose an optimal
   number of terms for the extrapolation.")

;;;;****************************************************************************
;;;; Acceleration with error estimation from truncation
;;;;****************************************************************************

(set-asf (levin-truncated order) allocate-levin-truncated free-levin-truncated)

(defun-gsl allocate-levin-truncated (order)
  "gsl_sum_levin_utrunc_alloc"
  ((order :size))
  :c-return :pointer
  :export nil
  :index (letm levin-truncated)
  :documentation
  "Allocate a workspace for a Levin @math{u}-transform of @var{n}
   terms, without error estimation.  The size of the workspace is
   @math{O(3n)}.")

(defun-gsl free-levin-truncated (levin)
  "gsl_sum_levin_utrunc_free"
  ((levin :pointer))
  :export nil
  :index (letm levin-truncated)
  :documentation
  "Free a previously allocated Levin acceleration.")

(defun-gsl accelerate-truncated (array levin)
  "gsl_sum_levin_utrunc_accel"
  (((gsl-array array) :pointer) ((dim0 array) :size) (levin :pointer)
   (accelerated-sum :double) (absolute-error :double))
  :documentation
  "From the terms of a series in @var{array}, compute the extrapolated
   limit of the series using a Levin @math{u}-transform.  Additional
   working space must be provided in levin.  The extrapolated sum is
   returned with an estimate of the absolute error.  The actual
   term-by-term sum is returned in @code{w->sum_plain}. The algorithm
   terminates when the difference between two successive extrapolations
   reaches a minimum or is sufficiently small. The difference between
   these two values is used as estimate of the error and is stored in
   @var{abserr_trunc}.  To improve the reliability of the algorithm the
   extrapolated values are replaced by moving averages when calculating
   the truncation error, smoothing out any fluctuations.")

;;;;****************************************************************************
;;;; Example
;;;;****************************************************************************

;;; From Sec. 29.3 in the GSL manual.

(defun acceleration-example ()
  (let ((maxterms 20)
	(sum 0.0d0)
	(zeta2 (/ (expt pi 2) 6)))
    (letm ((levin (levin maxterms)))
      (with-data (array vector-double maxterms)
	(dotimes (n maxterms)
	  (setf (gsl-aref array n) (coerce (/ (expt (1+ n) 2)) 'double-float))
	  (incf sum (gsl-aref array n)))
	(multiple-value-bind (accelerated-sum error)
	    (accelerate array levin)
	  (format t "~&term-by-term sum =~f using ~d terms" sum maxterms)
	  (format t "~&term-by-term sum =~f using ~d terms"
		  (cffi:foreign-slot-value levin 'levin 'sum-plain)
		  (cffi:foreign-slot-value levin 'levin 'terms-used))
	  (format t "~&exact value     = ~f" zeta2)
	  (format t "~&accelerated sum = ~f using ~d terms"
		  accelerated-sum
		  (cffi:foreign-slot-value levin 'levin 'terms-used))
	  (format t "~&estimated error = ~f" error)
	  (format t "~&actual error = ~f" (- accelerated-sum zeta2)))))))

;; term-by-term sum =1.5961632439130233 using 20 terms
;; term-by-term sum =1.5759958390005426 using 13 terms
;; exact value     = 1.6449340668482264
;; accelerated sum = 1.6449340669228176 using 13 terms
;; estimated error = 0.00000000008883604962761638
;; actual error = 0.00000000007459122208786084
