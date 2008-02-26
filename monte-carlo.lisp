;; Monte Carlo Integration
;; Liam Healy Sat Feb  3 2007 - 17:42
;; Time-stamp: <2008-02-17 18:29:59EST monte-carlo.lisp>
;; $Id$

(in-package :gsl)

;;;;****************************************************************************
;;;; PLAIN Monte Carlo
;;;;****************************************************************************

(cffi:defcstruct plain-state
  (dim size)
  (x :pointer))

(defgo-s (monte-carlo-plain dim) monte-carlo-plain-alloc monte-carlo-plain-free)

(defmfun monte-carlo-plain-alloc (dim)
  "gsl_monte_plain_alloc"
  ((dim size))
  :c-return :pointer
  :export nil
  :index (letm monte-carlo-plain)
  :documentation			; FDL
  "Allocate and initialize a workspace for Monte Carlo
   integration in dim dimensions.")

(defmfun monte-carlo-plain-init (integrator-state)
  "gsl_monte_plain_init"
  ((integrator-state :pointer))
  :documentation			; FDL
  "Initialize a previously allocated integration state.
   This allows an existing workspace to be reused for different
   integrations.")

(defmfun monte-carlo-plain-free (integrator-state)
  "gsl_monte_plain_free"
  ((integrator-state :pointer))
  :c-return :void
  :export nil
  :index (letm monte-carlo-plain)
  :documentation			; FDL
  "Frees the memory associated with the integrator.")

(defmfun monte-carlo-integrate-plain
    (function lower-limits upper-limits calls generator state)
  "gsl_monte_plain_integrate"
  ((function :pointer)
   ((gsl-array lower-limits) :pointer) ((gsl-array upper-limits) :pointer)
   ((dim0 lower-limits) size) (calls size)
   ((generator generator) :pointer)
   (state :pointer)
   (result :double) (abserr :double))
  :documentation			; FDL
  "Uses the plain Monte Carlo algorithm to integrate the
   function f over the hypercubic region defined by the
   lower and upper limits in the arrays 'lower-limits and
   'upper-limits, each a gsl-vector of length dim.
   The integration uses a fixed number
   of function calls calls, and obtains random sampling points using
   the random number generator 'generator. A previously allocated workspace
   'state must be supplied.  The result of the integration is returned
   with an estimated absolute error.")

;;;;****************************************************************************
;;;; MISER
;;;;****************************************************************************

;;; The MISER algorithm of Press and Farrar is based on recursive
;;; stratified sampling.  This technique aims to reduce the overall
;;; integration error by concentrating integration points in the
;;; regions of highest variance.

(cffi:defcstruct miser-state
  (min-calls size)
  (min-calls-per-bisection size)
  (dither :double)
  (estimate-frac :double)
  (alpha :double)
  (dim size)
  (estimate-style :int)
  (depth :int)
  (verbose :int)
  (x :pointer)
  (xmid :pointer)
  (sigma-l :pointer)
  (sigma-r :pointer)
  (fmax-l :pointer)
  (fmax-r :pointer)
  (fmin-l :pointer)
  (fmin-r :pointer)
  (fsum-l :pointer)
  (fsum-r :pointer)
  (fsum2-l :pointer)
  (fsum2-r :pointer)
  (hits-l :pointer)
  (hits-r :pointer))

(defgo-s (monte-carlo-miser dim) monte-carlo-miser-alloc monte-carlo-miser-free)

(defmfun monte-carlo-miser-alloc (dim)
  "gsl_monte_miser_alloc"
  ((dim size))
  :c-return :pointer
  :export nil
  :index (letm monte-carlo-miser)
  :documentation			; FDL
  "Allocate and initialize a workspace for Monte Carlo integration in
   dim dimensions.  The workspace is used to maintain
   the state of the integration.  Returns a pointer to miser-state.")

(defmfun monte-carlo-miser-init (integrator-state)
  "gsl_monte_miser_init"
  ((integrator-state :pointer))
  :documentation			; FDL
  "Initialize a previously allocated integration state.
   This allows an existing workspace to be reused for different
   integrations.")

(defmfun monte-carlo-miser-free (integrator-state)
  "gsl_monte_miser_free"
  ((integrator-state :pointer))
  :c-return :void
  :export nil
  :index (letm monte-carlo-miser)
  :documentation			; FDL
  "Frees the memory associated with the integrator.")

(export 'miser-parameter)
(defmacro miser-parameter (workspace parameter)
  ;; FDL
  "Get or set with setf the parameter value for the MISER Monte Carlo
   integration method."
  ;; (miser-parameter ws min-calls)
  ;; (setf (miser-parameter ws min-calls) 300)
 `(foreign-slot-value ,workspace 'miser-state ',parameter))

(defmfun monte-carlo-integrate-miser
    (function lower-limits upper-limits calls generator state)
  "gsl_monte_miser_integrate"
  ((function :pointer)
   ((gsl-array lower-limits) :pointer) ((gsl-array upper-limits) :pointer)
   ((dim0 lower-limits) size) (calls size)
   ((generator generator) :pointer)
   (state :pointer)
   (result :double) (abserr :double))
  :documentation			; FDL
  "Uses the miser Monte Carlo algorithm to integrate the
   function f over the hypercubic region defined by the
   lower and upper limits in the arrays 'lower-limits and
   'upper-limits, each a gsl-vector of the samelength
   The integration uses a fixed number
   of function calls calls, and obtains random sampling points using
   the random number generator 'generator. A previously allocated workspace
   'state must be supplied.  The result of the integration is returned
   with an estimated absolute error.")

;;;;****************************************************************************
;;;; VEGAS
;;;;****************************************************************************

;;; The vegas algorithm of Lepage is based on importance sampling.  It
;;; samples points from the probability distribution described by the
;;; function |f|, so that the points are concentrated in the regions
;;; that make the largest contribution to the integral.

(cffi:defcstruct vegas-state
  ;; grid 
  (dim size)
  (bins-max size)
  (bins :uint)				; uint
  (boxes :uint)		       ; these are both counted along the axes
  (xi :pointer)
  (xin :pointer)
  (delx :pointer)
  (weight :pointer)
  (vol :double)
  (x :pointer)
  (bin :pointer)
  (box :pointer)
  (d :pointer)				; distribution
  ;; control variables
  (alpha :double)
  (mode :int)
  (verbose :int)
  (iterations :uint)
  (stage :int)
  ;; scratch variables preserved between calls to vegas1/2/3
  (jac :double)
  (wtd-int-sum :double)
  (sum-wgts :double)
  (chi-sum :double)
  (chisq :double)
  (result :double)
  (sigma :double)
  (it-start :uint)
  (it-num :uint)
  (samples :uint)
  (calls-per-box :uint)
  (ostream :pointer))

(defgo-s (monte-carlo-vegas dim) monte-carlo-vegas-alloc monte-carlo-vegas-free)

(defmfun monte-carlo-vegas-alloc (dim)
  "gsl_monte_vegas_alloc"
  ((dim size))
  :c-return :pointer
  :export nil
  :index (letm monte-carlo-vegas)
  :documentation			; FDL
  "Allocate and initialize a workspace for Monte Carlo integration in
   dim dimensions.  The workspace is used to maintain
   the state of the integration.  Returns a pointer to vegas-state.")

(defmfun monte-carlo-vegas-init (integrator-state)
  "gsl_monte_vegas_init"
  ((integrator-state :pointer))
  :documentation			; FDL
  "Initialize a previously allocated integration state.
   This allows an existing workspace to be reused for different
   integrations.")

(defmfun monte-carlo-vegas-free (integrator-state)
  "gsl_monte_vegas_free"
  ((integrator-state :pointer))
  :c-return :void
  :export nil
  :index (letm monte-carlo-vegas)
  :documentation			; FDL
  "Frees the memory associated with the integrator.")

(export 'vegas-parameter)
(defmacro vegas-parameter (workspace parameter)
  ;; FDL
  "Get or set with setf the parameter value for the VEGAS Monte Carlo
   integration method."
  ;; (vegas-parameter ws bins-max)
  ;; (setf (vegas-parameter ws bins-max) 300)
 `(foreign-slot-value ,workspace 'vegas-state ',parameter))

(defmfun monte-carlo-integrate-vegas
    (function lower-limits upper-limits calls generator state)
  "gsl_monte_vegas_integrate"
  ((function :pointer)
   ((gsl-array lower-limits) :pointer) ((gsl-array upper-limits) :pointer)
   ((dim0 lower-limits) size) (calls size)
   ((generator generator) :pointer)
   (state :pointer)
   (result :double) (abserr :double))
  :documentation			; FDL
  "Uses the vegas Monte Carlo algorithm to integrate the
   function f over the dim-dimensional hypercubic region
   defined by the lower and upper limits in the arrays x1 and
   xu, each of size dim.  The integration uses a fixed number
   of function calls calls, and obtains random sampling points using
   the random number generator r.  A previously allocated workspace
   s must be supplied.  The result of the integration is returned
   with an estimated absolute error.  The result
   and its error estimate are based on a weighted average of independent
   samples. The chi-squared per degree of freedom for the weighted average
   is returned via the state struct component, s->chisq, and must be
   consistent with 1 for the weighted average to be reliable.")

;;;;****************************************************************************
;;;; Callback definition
;;;;****************************************************************************

(cffi:defcstruct monte-function
  (function :pointer)
  (dimensions size)
  (parameters :pointer))

(export 'def-mc-function)
(defmacro def-mc-function (name dimensions)
  `(def-single-function ,name :double :pointer monte-function
    ((dimensions ,dimensions))))

;;;;****************************************************************************
;;;; Examples and unit test
;;;;****************************************************************************

;;; Example from Sec. 23.5
;;; This is a function that occurs in random walk studies.

(defun monte-carlo-g (arg)
  (with-c-double (arg x y z)
    (* (/ (expt pi 3))
       (/ (- 1 (* (cos x) (cos y) (cos z)))))))

(def-mc-function monte-carlo-g 3)

(defun random-walk-plain-example (&optional (nsamples 500000))
  (letm ((ws (monte-carlo-plain 3))
	 (lower (vector-double #(0.0d0 0.0d0 0.0d0)))
	 (upper (vector-double (vector pi pi pi)))
	 (rng (random-number-generator *mt19937* 0)))
    (monte-carlo-integrate-plain monte-carlo-g lower upper nsamples rng ws)))

(defun random-walk-miser-example (&optional (nsamples 500000))
  (letm ((ws (monte-carlo-miser 3))
	 (lower (vector-double #(0.0d0 0.0d0 0.0d0)))
	 (upper (vector-double (vector pi pi pi)))
	 (rng (random-number-generator *mt19937* 0)))
    (monte-carlo-integrate-miser monte-carlo-g lower upper nsamples rng ws)))

(defun random-walk-vegas-example (&optional (nsamples 500000))
  (letm ((ws (monte-carlo-vegas 3))
	 (lower (vector-double #(0.0d0 0.0d0 0.0d0)))
	 (upper (vector-double (vector pi pi pi)))
	 (rng (random-number-generator *mt19937* 0)))
    (monte-carlo-integrate-vegas monte-carlo-g lower upper nsamples rng ws)))

#|
(make-tests monte-carlo
  (random-walk-plain-example)
  (random-walk-miser-example)
  (random-walk-vegas-example))
|#

(LISP-UNIT:DEFINE-TEST MONTE-CARLO
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 1.4122087033540667d0 0.013435861456267064d0)
   (MULTIPLE-VALUE-LIST (RANDOM-WALK-PLAIN-EXAMPLE)))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 1.3895297058825096d0 0.0050106269732269415d0)
   (MULTIPLE-VALUE-LIST (RANDOM-WALK-MISER-EXAMPLE)))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 1.3931632739551914d0 1.4981164744582692d-4)
   (MULTIPLE-VALUE-LIST (RANDOM-WALK-VEGAS-EXAMPLE))))

