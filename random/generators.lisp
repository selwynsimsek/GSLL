;********************************************************
; file:        generators.lisp                           
; description: Generators of random numbers.             
; date:        Sat Jul 15 2006 - 14:43                   
; author:      Liam M. Healy                             
; modified:    Sat Feb 17 2007 - 21:56
;********************************************************
;;; $Id: $

(in-package :gsl)

;;; Would it be useful to have a make-data like macro?

(export '(random-number-generator make-random-number-generator))

(defgeneric generator (object)
  (:method ((object t))
    (if (cffi:pointerp object)
	object
	(call-next-method)))
  (:documentation "The foreign pointer to the GSL generator function."))

(defclass gsl-random ()
  ((type :initarg :type :reader rng-type)
   (generator :initarg :generator :accessor generator)))

(defclass random-number-generator (gsl-random)
  ()
  (:documentation "A generator of random numbers."))

(defmethod print-object ((object gsl-random) stream)
  (print-unreadable-object (object stream :type t :identity t) 
    (format stream "~a" (when (generator object) (rng-name object)))))

(defun make-random-number-generator
    (&optional (type *default-type*) (generator t))
  "Make a random number generator; by default it is allocated on creation."
  (let ((instance
	 (make-instance
	  'random-number-generator
	  :type type
	  :generator generator)))
    (if (eq generator t) (alloc instance) instance)))

;;;;****************************************************************************
;;;; Initialization
;;;;****************************************************************************

(defun-gsl alloc ((generator random-number-generator))
  "gsl_rng_alloc" (((rng-type generator) :pointer))
  :type :method
  :c-return (ptr :pointer)
  :return ((progn (setf (generator generator) ptr) generator))
  :documentation
  "Instatiate a random number generator of specified type.
   For example, create an instance of the Tausworthe
   generator: (rng-alloc *taus*).
   The generator is automatically initialized with the default seed,
   @code{gsl_rng_default_seed}.  This is zero by default but can be changed
   either directly or by using the environment variable @code{GSL_RNG_SEED}")

(defun-gsl free ((generator random-number-generator))
  "gsl_rng_free" (((generator generator) :pointer))
  :type :method
  :c-return :void
  :after ((setf (generator generator) nil))
  :documentation "Free all the memory associated with the generator.")

;;;;****************************************************************************
;;;; Seed
;;;;****************************************************************************

(cffi:defcvar ("gsl_rng_default_seed" *default-seed*) :ulong)
(setf (documentation '*default-seed* 'variable)
      "The default seed for random number generators.")
(map-name '*default-seed* "gsl_rng_cmrg")
(export '*default-seed*)

(defun-gsl rng-set (rng-instance value)
  "gsl_rng_set" (((generator rng-instance) :pointer) (value :ulong))
  :c-return :void
  :documentation
  "Initialize (or `seeds') the random number generator.  If
   the generator is seeded with the same value of @var{s} on two different
   runs, the same stream of random numbers will be generated by successive
   calls to the routines below.  If different values of @var{s} are
   supplied, then the generated streams of random numbers should be
   completely different.  If the seed @var{s} is zero then the standard seed
   from the original implementation is used instead.  For example, the
   original Fortran source code for the @code{ranlux} generator used a seed
   of 314159265, and so choosing @var{s} equal to zero reproduces this when
   using @code{gsl_rng_ranlux}.")

;;;;****************************************************************************
;;;; Sampling
;;;;****************************************************************************

(defun-gsl get-random-number (generator)
  "gsl_rng_get" (((generator generator) :pointer))
  :c-return :ulong
  :documentation
  "Generate a random integer.  The
   minimum and maximum values depend on the algorithm used, but all
   integers in the range [@var{min},@var{max}] are equally likely.  The
   values of @var{min} and @var{max} can determined using the auxiliary
   functions @code{gsl_rng_max (r)} and @code{gsl_rng_min (r)}.")

(defun-gsl uniform (generator)
  "gsl_rng_uniform" (((generator generator) :pointer))
  :c-return :double
  :documentation
  "A double precision floating point number uniformly
   distributed in the range [0,1).  The range includes 0.0 but excludes 1.0.
   The value is typically obtained by dividing the result of
   #'rng-get by (+ (rng-max generator) 1.0) in double
   precision.  Some generators compute this ratio internally so that they
   can provide floating point numbers with more than 32 bits of randomness
   (the maximum number of bits that can be portably represented in a single
   :ulong.")

(defun-gsl uniform>0 (generator)
  "gsl_rng_uniform_pos" (((generator generator) :pointer))
  :c-return :double
  :documentation
  "Return a positive double precision floating point number
   uniformly distributed in the range (0,1), excluding both 0.0 and 1.0.
   The number is obtained by sampling the generator with the algorithm of
   @code{gsl_rng_uniform} until a non-zero value is obtained.  You can use
   this function if you need to avoid a singularity at 0.0.")

(defun-gsl uniform-fixnum (generator upperbound)
  "gsl_rng_uniform_int" (((generator generator) :pointer) (upperbound :ulong))
  :c-return :ulong
  :documentation
  "Generate a random integer from 0 to upperbound-1 inclusive.
   All integers in the range are equally likely, regardless
   of the generator used.  An offset correction is applied so that zero is
   always returned with the correct probability, for any minimum value of
   the underlying generator.  If upperbound is larger than the range
   of the generator then the function signals an error.")

;;;;****************************************************************************
;;;; Information functions about instances
;;;;****************************************************************************

(defun-gsl rng-name ((rng-instance random-number-generator))
  "gsl_rng_name" (((generator rng-instance) :pointer))
  :type :method
  :c-return :string
  :documentation "The name of the random number generator.")

(defun-gsl rng-max (rng-instance)
  "gsl_rng_max" (((generator rng-instance) :pointer))
  :c-return :unsigned-long
  :documentation "The largest value that @code{gsl_rng_get}
   can return.")

(defun-gsl rng-min (rng-instance)
  "gsl_rng_min" (((generator rng-instance) :pointer))
  :c-return :unsigned-long
  :documentation "The smallest value that @code{gsl_rng_get}
   can return.  Usually this value is zero.  There are some generators with
   algorithms that cannot return zero, and for these generators the minimum
   value is 1.")

(defun-gsl rng-state ((rng-instance random-number-generator))
  "gsl_rng_state" (((generator rng-instance) :pointer))
  :c-return :pointer
  :type :method
  :export nil
  :index gsl-random-state
  :documentation "A pointer to the state of generator.")

(defun-gsl rng-size ((rng-instance random-number-generator))
  "gsl_rng_size" (((generator rng-instance) :pointer))
  :c-return :size
  :type :method
  :export nil
  :index gsl-random-state
  :documentation "The size of the generator.")

(export 'gsl-random-state)
(defun gsl-random-state (rng-instance)
  "The complete state of a given random number generator, specified
   as a vector of bytes."
  (let* ((gen rng-instance)
	 (ans
	  (make-array (rng-size gen)
		      :element-type '(unsigned-byte 8))))
    (loop for i from 0 below (length ans)
       do
       (setf (aref ans i)
	     (mem-aref (rng-state gen) :uint8 i)))
    ans))

;;;;****************************************************************************
;;;; Copying state
;;;;****************************************************************************

(defun-gsl copy
    ((destination random-number-generator) (source random-number-generator))
  "gsl_rng_memcpy"
  (((generator destination) :pointer) ((generator source) :pointer))
  :type :method
  :documentation
  "Copy the random number generator @var{source} into the
   pre-existing generator @var{destination},
   making @var{destination} into an exact copy
   of @var{source}.  The two generators must be of the same type.")

(defun-gsl clone-generator ((instance random-number-generator))
  "gsl_rng_clone" (((generator instance) :pointer))
  :c-return :pointer
  :type :method
  :documentation
  "Create a new generator which is an exact copy of the original.
   Don't use; use #'make-random-number-generator, #'copy instead.")

(defun-gsl write-binary
    ((object random-number-generator) stream)
  "gsl_rng_fwrite"
  ((stream :pointer) ((generator object) :pointer))
  :type :method)

(defun-gsl read-binary
    ((object random-number-generator) stream)
  "gsl_block_fread"
  ((stream :pointer) ((pointer object) :pointer))
  :type :method)

;;;;****************************************************************************
;;;; Examples and unit test
;;;;****************************************************************************

(defparameter *rng-mt19937* (make-random-number-generator *mt19937*))
(defparameter *rng-cmrg* (make-random-number-generator *cmrg*))
;;; (defparameter *rng-default* (make-random-number-generator *default-type*))

(lisp-unit:define-test random-number-generators
  (lisp-unit:assert-equal
   '(999 162 282 947 231 484 957 744 540 739 759)
   (progn
     (rng-set *rng-mt19937* 0)
     (loop for i from 0 to 10
	collect
	(uniform-fixnum *rng-mt19937* 1000))))
  (lisp-unit:assert-equal
   '("0.111776229978d+00" "0.959166794996d+00" "0.841526801158d+00"
     "0.925403713680d+00" "0.275406984741d+00" "0.709304057392d+00"
     "0.554133304187d+00" "0.880695776958d+00" "0.597139396983d+00"
     "0.751874113340d+00" "0.931108462127d+00")
   (lisp-unit:fp-sequence
    (progn
      (rng-set *rng-cmrg* 0)
      (loop for i from 0 to 10
	 collect (uniform *rng-cmrg*))))))
