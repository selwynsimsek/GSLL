;********************************************************
; file:        roots-one.lisp                           
; description: One-dimensional root solver.              
; date:        Sun Dec  9 2007 - 15:47                   
; author:      Liam Healy                                
; modified:    Tue Jan  8 2008 - 22:53
;********************************************************
;;; $Id: $

(in-package :gsl)


;;;;****************************************************************************
;;;; Function definition
;;;;****************************************************************************

;;; Solvers that require the function and its derivative use the
;;; following structure.
(cffi:defcstruct gsl-function-fdf
  ;; See /usr/include/gsl/gsl_math.h
  "The definition of a function and its derivative for root finding in GSL."
  (function :pointer)
  (df :pointer)
  (fdf :pointer)
  (parameters :pointer))

;;; Temporarily added a name argument to debug.  Once solved that can
;;; probably be removed.
(export 'def-solver-functions)
(defmacro def-solver-functions (name function df fdf)
  "Setup functions for solvers.
   The CL functions name and derivative should be defined previously
   with defuns."
  (let ((arg (make-symbol "ARG"))
	(params (make-symbol "PARAMS"))
	(func (make-symbol "F"))
	(deriv (make-symbol "DF")))
    `(progn
      (cffi:defcallback ,function :double
	  ((,arg :double)
	   (,params :pointer))
	(declare (ignore ,params))
	(,function ,arg))
      (cffi:defcallback ,df :double
	  ((,arg :double)
	   (,params :pointer))
	(declare (ignore ,params))
	(,df ,arg))
      (cffi:defcallback ,fdf :pointer
	  ((,arg :double)
	   (,func :pointer)
	   (,deriv :pointer)
	   (,params :pointer))
	(declare (ignore ,params))
	(,fdf ,arg ,func ,deriv)
	(cffi:null-pointer))
      (defparameter ,name (cffi:foreign-alloc 'gsl-function-fdf))
      (set-slot-function ,name 'gsl-function-fdf 'function ',function)
      (set-slot-function ,name 'gsl-function-fdf 'df ',df)
      (set-slot-function ,name 'gsl-function-fdf 'fdf ',fdf)
      (set-parameters ,name 'gsl-function-fdf))))

;;;;****************************************************************************
;;;; Initialization
;;;;****************************************************************************

(defun-gsl allocate-fsolver (type)
  "gsl_root_fsolver_alloc"
  ((type :pointer))
  :c-return :pointer
  :documentation
  "Allocate an instance of a solver of the given type.")

(defun-gsl allocate-fdfsolver (type)
  "gsl_root_fsolver_alloc"
  ((type :pointer))
  :c-return :pointer
  :documentation
  "Allocate an instance of a derivative-based solver of the given type.")

(defun-gsl set-fsolver (solver function lower upper)
  "gsl_root_fsolver_set"
  ((solver :pointer) (function :pointer)
   (lower :double) (upper :double))
  :documentation
  "Initialize or reinitialize an existing solver
   to use the function and the initial search interval
   [lower, upper].")

(defun-gsl set-fdfsolver (solver function-derivative root-guess)
  "gsl_root_fdfsolver_set"
  ((solver :pointer) (function-derivative :pointer) (root-guess :double))
  :documentation
  "Initialize or reinitialize an existing solver.")

(defun-gsl free-fsolver (solver)
  "gsl_root_fsolver_free"
  ((solver :pointer))
  :c-return :void
  :documentation
  "Free all the memory associated with the solver.")

(defun-gsl free-fdfsolver (solver)
  "gsl_root_fdfsolver_free"
  ((solver :pointer))
  :c-return :void
  :documentation
  "Free all the memory associated with the solver.")

(defun-gsl fsolver-name (solver)
  "gsl_root_fsolver_name"
  ((solver :pointer))
  :c-return :string
  :documentation
  "The name of the solver.")

(defun-gsl fdfsolver-name (solver)
  "gsl_root_fdfsolver_name"
  ((solver :pointer))
  :c-return :string
  :documentation
  "The name of the solver.")

(export '(with-fsolver with-fdfsolver))
(defmacro with-fsolver
    ((solver solver-type function lower upper) &body body)
  "Create and initialize an fsolver for one-dimensional problems,
   and clean up afterwards."
  `(let ((,solver (allocate-fsolver ,solver-type)))
    (unwind-protect
	 (progn
	   (set-fsolver ,solver ,function ,lower ,upper)
	   ,@body)
      (free-fsolver ,solver))))

(defmacro with-fdfsolver ((solver solver-type f-df-fdf root-guess)
     &body body)
  "Create and initialize an fdfsolver for one-dimensional problems,
   and clean up afterwards."
  `(let ((,solver (allocate-fdfsolver ,solver-type)))
    (unwind-protect
	 (progn
	   (set-fdfsolver ,solver ,f-df-fdf ,root-guess)
	   ,@body)
      (free-fdfsolver ,solver))))

;;;;****************************************************************************
;;;; Iteration
;;;;****************************************************************************

;; It appears that this is always returning :SUCCESS (0).
(defun-gsl iterate-fsolver (solver)
  "gsl_root_fsolver_iterate"
  ((solver :pointer))
  :c-return :success-continue
  :documentation
  "Perform a single iteration of the solver.  The following
   errors may be signalled: :EBADFUNC,
   the iteration encountered a singular point where the function or its
   derivative evaluated to infinity or NaN, or
   :EZERODIV, the derivative of the function vanished at the iteration point,
   preventing the algorithm from continuing without a division by zero.")

(defun-gsl iterate-fdfsolver (solver)
  "gsl_root_fdfsolver_iterate"
  ((solver :pointer))
  :documentation
  "Perform a single iteration of the solver.  The following
   errors may be signalled: :EBADFUNC,
   the iteration encountered a singular point where the function or its
   derivative evaluated to infinity or NaN, or
   :EZERODIV, the derivative of the function vanished at the iteration point,
   preventing the algorithm from continuing without a division by zero.")

(defun-gsl fsolver-root (solver)
  "gsl_root_fsolver_root"
  ((solver :pointer))
  :c-return :double
  :documentation
  "The current estimate of the root for the solver.")

(defun-gsl fdfsolver-root (solver)
  "gsl_root_fdfsolver_root"
  ((solver :pointer))
  :c-return :double
  :documentation
  "The current estimate of the root for the solver.")

(defun-gsl fsolver-lower (solver)
  "gsl_root_fsolver_x_lower"
  ((solver :pointer))
  :c-return :double
  :documentation
  "The lower end of the current bracketing interval for the solver.")

(defun-gsl fsolver-upper (solver)
  "gsl_root_fsolver_x_upper"
  ((solver :pointer))
  :c-return :double
  :documentation
  "The upper end of the current bracketing interval for the solver.")

;;;;****************************************************************************
;;;; Search stopping conditions
;;;;****************************************************************************

(defun-gsl root-test-interval (lower upper absolute-error relative-error)
  "gsl_root_test_interval"
  ((lower :double) (upper :double)
   (absolute-error :double) (relative-error :double))
  :c-return :success-failure
  :documentation
  "Test for the convergence of the interval [lower,upper]
   with absolute error absolute-error and relative error
   relative-error.  This returns T
   if the following condition is achieved,
   |a - b| < epsabs + epsrel min(|a|,|b|) 
   when the interval @math{x = [a,b]} does not include the origin.  If the
   interval includes the origin then @math{\min(|a|,|b|)} is replaced by
   zero (which is the minimum value of @math{|x|} over the interval).  This
   ensures that the relative error is accurately estimated for roots close
   to the origin.

   This condition on the interval also implies that any estimate of the
   root @math{r} in the interval satisfies the same condition with respect
   to the true root @math{r^*},
   |r - r^*| < epsabs + epsrel r^*
   assuming that the true root @math{r^*} is contained within the interval.")

(defun-gsl root-test-delta (x1 x0 absolute-error relative-error)
  "gsl_root_test_delta"
  ((x1 :double) (x0 :double)
   (absolute-error :double) (relative-error :double))
  :c-return :success-failure
  :documentation
  "Test for the convergence of the sequence ... x0, x1
   with absolute error absolute-error and relative error
   relative-error.  The test returns T if the following
   condition is achieved,
   |x_1 - x_0| < epsabs + epsrel |x_1|
   and returns NIL otherwise.")

(defun-gsl root-test-residual (f absolute-error)
  "gsl_root_test_residual"
  ((f :double) (absolute-error :double))
  :c-return :success-failure
  :documentation
  "Tests the residual value f against the absolute
   error bound absolute-error.  The test returns T if the
   following condition is achieved,
   |f| < epsabs
   and returns NIL otherwise.  This criterion is suitable
   for situations where the precise location of the root, @math{x}, is
   unimportant provided a value can be found where the residual,
   |f(x)|, is small enough.")

;;;;****************************************************************************
;;;; Root bracketing algorithms
;;;;****************************************************************************

(defvariable *bisection-fsolver* "gsl_root_fsolver_bisection"
  "The bisection algorithm is the simplest method of bracketing the
   roots of a function.   It is the slowest algorithm provided by
   the library, with linear convergence.

   On each iteration, the interval is bisected and the value of the
   function at the midpoint is calculated.  The sign of this value is used
   to determine which half of the interval does not contain a root.  That
   half is discarded to give a new, smaller interval containing the
   root.  This procedure can be continued indefinitely until the interval is
   sufficiently small.

   At any time the current estimate of the root is taken as the midpoint of
   the interval.")

(defvariable *false-position-fsolver* "gsl_root_fsolver_falsepos"
  "The false position algorithm is a method of finding roots based on
   linear interpolation.  Its convergence is linear, but it is usually
   faster than bisection.

   On each iteration a line is drawn between the endpoints (a,f(a))
   and (b,f(b)) and the point where this line crosses the
   x-axis taken as a ``midpoint''.  The value of the function at
   this point is calculated and its sign is used to determine which side of
   the interval does not contain a root.  That side is discarded to give a
   new, smaller interval containing the root.  This procedure can be
   continued indefinitely until the interval is sufficiently small.

   The best estimate of the root is taken from the linear interpolation of
   the interval on the current iteration.")

(defvariable *brent-fsolver* "gsl_root_fsolver_brent"
  "The Brent-Dekker method (referred to here as Brent's method)
   combines an interpolation strategy with the bisection algorithm.  This
   produces a fast algorithm which is still robust.

   On each iteration Brent's method approximates the function using an
   interpolating curve.  On the first iteration this is a linear
   interpolation of the two endpoints.  For subsequent iterations the
   algorithm uses an inverse quadratic fit to the last three points, for
   higher accuracy.  The intercept of the interpolating curve with the
   x-axis is taken as a guess for the root.  If it lies within the
   bounds of the current interval then the interpolating point is accepted,
   and used to generate a smaller interval.  If the interpolating point is
   not accepted then the algorithm falls back to an ordinary bisection
   step.

   The best estimate of the root is taken from the most recent
   interpolation or bisection.")

;;;;****************************************************************************
;;;; Root finding algorithms using derivatives
;;;;****************************************************************************

(defvariable *newton-fdfsolver* "gsl_root_fdfsolver_newton"
  "Newton's Method is the standard root-polishing algorithm.  The algorithm
   begins with an initial guess for the location of the root.  On each
   iteration, a line tangent to the function @math{f} is drawn at that
   position.  The point where this line crosses the @math{x}-axis becomes
   the new guess.  The iteration is defined by the following sequence,
   x_{i+1} = x_i - f(x_i) / f'(x_i)
   Newton's method converges quadratically for single roots, and linearly
   for multiple roots.")

(defvariable *secant-fdfsolver* "gsl_root_fdfsolver_secant"
  "The secant method is a simplified version of Newton's method which does
   not require the computation of the derivative on every step.
   On its first iteration the algorithm begins with Newton's method, using
   the derivative to compute a first step,
   x_1 = x_0 - f(x_0)/f'(x_0)
   Subsequent iterations avoid the evaluation of the derivative by
   replacing it with a numerical estimate, the slope of the line through
   the previous two points,
   x_{i+1} = x_i - f(x_i) / f'_{est}
    where
   f'_{est} =  f(x_{i}) - f(x_{i-1}) / x_i - x_{i-1}
   When the derivative does not change significantly in the vicinity of the
   root the secant method gives a useful saving.  Asymptotically the secant
   method is faster than Newton's method whenever the cost of evaluating
   the derivative is more than 0.44 times the cost of evaluating the
   function itself.  As with all methods of computing a numerical
   derivative the estimate can suffer from cancellation errors if the
   separation of the points becomes too small.

   On single roots, the method has a convergence of order (1 + \sqrt
   5)/2 (approximately 1.62).  It converges linearly for multiple
   roots.")

(defvariable *steffenson-fdfsolver* "gsl_root_fdfsolver_steffenson"
  "The Steffenson method provides the fastest convergence of all the
   routines.  It combines the basic Newton algorithm with an Aitken
   ``delta-squared'' acceleration.  If the Newton iterates are x_i
   then the acceleration procedure generates a new sequence R_i,
   R_i = x_i - (x_{i+1} - x_i)^2 / (x_{i+2} - 2 x_{i+1} + x_i)
   which converges faster than the original sequence under reasonable
   conditions.  The new sequence requires three terms before it can produce
   its first value so the method returns accelerated values on the second
   and subsequent iterations.  On the first iteration it returns the
   ordinary Newton estimate.  The Newton iterate is also returned if the
   denominator of the acceleration term ever becomes zero.

   As with all acceleration procedures this method can become unstable if
   the function is not well-behaved.")

;;;;****************************************************************************
;;;; Examples
;;;;****************************************************************************

;;; This is the example given in Sec. 32.10.

(let ((a 1.0d0) (b 0.0d0) (c -5.0d0))
  (defun quadratic (x)
    (print (+ (* (+ (* a x) b) x) c)))
  (defun quadratic-derivative (x)
    (print (+ (* 2 a x) b)))
  (defun quadratic-and-derivative (x cy cdy)
    (with-c-doubles ((cy y) (cdy dy))
      (setf y (+ (* (+ (* a x) b) x) c)
	    dy (+ (* 2 a x) b)))))

(def-scalar-function quadratic)

(defun roots-one-example ()
  "Solving a quadratic, the example given in Sec. 32.10 of the GSL manual."
  (let ((max-iter 50))
    (with-fsolver (solver *brent-fsolver* quadratic 0.0d0 5.0d0)
      (format t "~&iter ~6t   [lower ~24tupper] ~36troot ~44terr ~54terr(est)")
      (loop for iter from 0
	    for root = (fsolver-root solver)
	    for lower = (fsolver-lower solver)
	    for upper = (fsolver-upper solver)
	    do (iterate-fsolver solver)
	    while  (and (< iter max-iter)
			(not (root-test-interval lower upper 0.0d0 0.001d0)))
	    do
	    (format t "~&~d~6t~10,6f~18t~10,6f~28t~12,9f ~44t~10,4g ~10,4g"
		    iter lower upper
		    root (- root (sqrt 5.0d0))
		    (- upper lower))))))

;;; Because def-solver-functions and def-scalar-fucntion bind a symbol
;;; of the same name as the first function, and we want both to run,
;;; we'll make an alias function so we can use both.  
(eval-when (:load-toplevel :execute)
  (setf (fdefinition 'quadratic-df) #'quadratic))

(def-solver-functions
    *quadratic* quadratic quadratic-derivative quadratic-and-derivative)

;;; This fails with memory fault:
;;; (set-fdfsolver (allocate-fdfsolver newton-fdfsolver) *quadratic* 5.0d0)
;;; I don't know why.  Thus the example does not work either.

(defun roots-one-fdf-example ()
  "Solving a quadratic, the example given in Sec. 32.10 of the GSL manual."
  (let ((max-iter 100)
	(initial 5.0d0))
    (with-fdfsolver
	(solver *newton-fdfsolver* *quadratic* initial)
      (format t "~&iter ~6t ~36troot ~44terr ~54terr(est)")
      (loop for iter from 0
	    for oldroot = initial then root
	    for root = (fdfsolver-root solver)
	    do (iterate-fdfsolver solver)
	    while (and (< iter max-iter)
		       (not (root-test-delta root oldroot 0.0d0 1.0d-3)))
	    do
	    (format t "~&~d~6t~g ~18t~10,4g ~10,4g"
		    iter root (- root (sqrt 5.0d0)) (- root oldroot))))))
