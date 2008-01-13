;********************************************************
; file:        simulated-annealing.lisp                  
; description: Simulated Annealing                       
; date:        Sun Feb 11 2007 - 17:23                   
; author:      Liam Healy                                
; modified:    Sat Jan  5 2008 - 21:20
;********************************************************
;;; $Id: $

(in-package :gsl)

;;; This does not work.
;;; Step size passed to the step function is incorrect.
;;; Print function is ignored, but probably couldn't work if it weren't.
;;; Does not converge.


(cffi:defcstruct simulated-annealing-parameters
  (n-tries :int)		; how many points to try for each step
  (iterations-fixed-T :int) ; how many iterations at each temperature?
  (step-size :double)		    ; max step size in the random walk
  ;; The following parameters are for the Boltzmann distribution
  (k :double)
  (t-initial :double)
  (mu-t :double)
  (t-min :double))

(defmacro with-simulated-annealing-parameters
    ((name number-of-tries iterations-per-temperature
		      step-size &optional k t-initial mu-t t-min)
     &body body)
  `(cffi:with-foreign-object (,name 'simulated-annealing-parameters)
    (setf
     (cffi:foreign-slot-value
      ,name 'simulated-annealing-parameters 'n-tries)
     ,number-of-tries
     (cffi:foreign-slot-value
      ,name 'simulated-annealing-parameters 'iterations-fixed-T)
     ,iterations-per-temperature
     (cffi:foreign-slot-value
      ,name 'simulated-annealing-parameters 'step-size)
     ,step-size
     ;; The following parameters are for the Boltzmann distribution
     (cffi:foreign-slot-value
      ,name 'simulated-annealing-parameters 'k)
     ,k
     (cffi:foreign-slot-value
      ,name 'simulated-annealing-parameters 't-initial)
     ,t-initial
     (cffi:foreign-slot-value
      ,name 'simulated-annealing-parameters 'mu-t)
     ,mu-t
     (cffi:foreign-slot-value
      ,name 'simulated-annealing-parameters 't-min)
     ,t-min)
    ,@body))

(defun-gsl simulated-annealing
    (generator x0-p
	       Ef take-step distance-function
	        print-position
		;; copy-function copy-constructor destructor
	       element-size parameters)
  "gsl_siman_solve"
  (((generator generator) :pointer) (x0-p :pointer)
   ((cffi:get-callback Ef) :pointer)
   ((cffi:get-callback take-step) :pointer)
   ((cffi:get-callback distance-function) :pointer)
   ((cffi:get-callback print-position) :pointer)
   ((cffi:null-pointer) :pointer)
   ((cffi:null-pointer) :pointer)
   ((cffi:null-pointer) :pointer)
   ;;((cffi:get-callback copy-function) :pointer)
   ;;((cffi:get-callback copy-constructor) :pointer)
   ;;((cffi:get-callback destructor) :pointer)
   (element-size :size) (parameters simulated-annealing-parameters))
  :c-return :void
  :documentation
  "Perform a simulated annealing search through a given
   space.  The space is specified by providing the functions @var{Ef} and
   @var{distance}.  The simulated annealing steps are generated using the
   random number generator @var{r} and the function @var{take_step}.

   The starting configuration of the system should be given by x0-p
   The routine offers two modes for updating configurations, a fixed-size
   mode and a variable-size mode.  In the fixed-size mode the configuration
   is stored as a single block of memory of size element-size
   The functions copy-function,
   copy-constructor and destructor should be NIL in
   fixed-size mode.  In the variable-size mode the functions
   copy-function, copy-constructor and destructor are used to
   create, copy and destroy configurations internally.  The variable
   @var{element_size} should be zero in the variable-size mode.

   The parameters structure (described below) controls the run by
   providing the temperature schedule and other tunable parameters to the
   algorithm.

   On exit the best result achieved during the search is placed in
   x0-p.  If the annealing process has been successful this
   should be a good approximation to the optimal point in the space.

   If the function pointer @var{print_position} is not null, a debugging
   log will be printed to @code{stdout} with the following columns:
   number_of_iterations temperature x x-x0p Ef(x)
   and the output of the function @var{print_position} itself.  If
   @var{print_position} is null then no information is printed.
   The simulated annealing routines require several user-specified
   functions to define the configuration space and energy function.")

(defmacro def-energy-function (name)
  "Define an energy or distance fuction for simulated annealing."
  `(def-scalar-function ,name :double :pointer nil))

(defmacro def-step-function (name)
  "Define a step fuction for simulated annealing."
  (let ((generator (gensym "GEN"))
	(arguments (gensym "ARGS"))
	(step-size (gensym "SS")))
    `(cffi:defcallback ,name :void
      ((,generator :pointer) (,arguments :pointer) (,step-size :double))
      (,name ,generator ,arguments ,step-size))))

(defmacro def-distance-function (name)
  "Define a metric distance fuction for simulated annealing."
  (let ((x (gensym "X"))
	(y (gensym "Y")))
    `(cffi:defcallback ,name :double
      ((,x :pointer) (,y :pointer))
      (,name ,x ,y))))

(defmacro def-print-function (name)
  "Define a print function for simulated annealing."
  `(def-scalar-function ,name :int :pointer nil))

;;;;****************************************************************************
;;;; Example
;;;;****************************************************************************

;;; Trivial example, Sec. 24.3.1
;;; This does not work.

(defun M2 (cx cy)
  (with-c-double (cx x)
    (with-c-double (cy y)
      (abs (- x y)))))

(defun E2 (arg)
  (with-c-double (arg x)
    (incf *sa-function-calls*)
    (when (> *sa-function-calls* 100)
      (error "too much"))
    (* (exp (- (expt (1- x) 2))) (sin (* 8 x)))))

(defun S2 (generator parameters step-size)
  (with-c-double (parameters x)
    ;;(format t "~&~d ~d" x step-size)
    (let ((step-size 10.0d0))		; this is coming in wrong, so we fix it
      (let ((rand (uniform generator)))
	(setf x (+ x (- (* 2 rand step-size) step-size)))))))

(defparameter *sa-example-print* nil)

;;; Print functions are a problem because it is likely that the C
;;; stdout and the CL *standard-output* are not the same stream.
;;; Also, it seems to ignore that a function is supplied, and avoids
;;; printing anything.
(defun P2 (arg)
  (with-c-double (arg x)
    (when *sa-example-print*
      (format T "~&from P2: ~a" x))))

(def-energy-function E2)
(def-distance-function M2)
(def-step-function S2)
(def-print-function P2)

(defun simulated-annealing-example ()
  (let ((*sa-function-calls* 0))
    (rng-environment-setup)
    (cffi:with-foreign-object (initial :double)
      (setf (double-to-cl initial) 15.5d0)
      (with-simulated-annealing-parameters
	  (params 200 10 10.0d0 1.0d0 0.002d0 1.005d0 2.0d-6)
	(simulated-annealing
	 (make-random-number-generator) initial
	 'E2 'S2 'M2 'P2
	 (cffi:foreign-type-size :double)
	 params)))))
