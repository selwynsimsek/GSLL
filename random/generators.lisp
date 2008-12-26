;; Generators of random numbers.
;; Liam Healy, Sat Jul 15 2006 - 14:43
;; Time-stamp: <2008-12-26 11:36:03EST generators.lisp>
;; $Id$

(in-package :gsl)

;;;;****************************************************************************
;;;; Object
;;;;****************************************************************************

(defmobject random-number-generator
    "gsl_rng"
  ((rng-type :pointer))
  "random number generator"		; FDL
  "Make and optionally initialize (or `seed') the random number
   generator of the specified type.  If the generator is seeded with
   the same value of s on two different runs, the same stream of
   random numbers will be generated by successive calls.  If different
   values of s are supplied, then the generated streams of random
   numbers should be completely different.  If the seed s is zero then
   the standard seed from the original implementation is used instead.
   For example, the original Fortran source code for the *ranlux*
   generator used a seed of 314159265, and so choosing s equal to zero
   reproduces this when using *ranlux*."
  "set"
  ((value :ulong)))

;;;;****************************************************************************
;;;; Seed
;;;;****************************************************************************

(defmpar *default-seed*
    "gsl_rng_default_seed"
  "The default seed for random number generators."
  :ulong nil)

;;;;****************************************************************************
;;;; Sampling
;;;;****************************************************************************

(defmfun get-random-number (generator)
  "gsl_rng_get" (((generator generator) :pointer))
  :c-return :ulong
  :documentation			; FDL
  "Generate a random integer.  The
   minimum and maximum values depend on the algorithm used, but all
   integers in the range [min, max] are equally likely.  The
   values of min and max can determined using the auxiliary
   functions #'rng-max and #'rng-min.")

(defmfun uniform (generator)
  "gsl_rng_uniform" (((generator generator) :pointer))
  :c-return :double
  :documentation			; FDL
  "A double precision floating point number uniformly
   distributed in the range [0,1).  The range includes 0.0 but excludes 1.0.
   The value is typically obtained by dividing the result of
   #'rng-get by (+ (rng-max generator) 1.0) in double
   precision.  Some generators compute this ratio internally so that they
   can provide floating point numbers with more than 32 bits of randomness
   (the maximum number of bits that can be portably represented in a single
   :ulong.")

(defmfun uniform>0 (generator)
  "gsl_rng_uniform_pos" (((generator generator) :pointer))
  :c-return :double
  :documentation			; FDL
  "Return a positive double precision floating point number
   uniformly distributed in the range (0,1), excluding both 0.0 and 1.0.
   The number is obtained by sampling the generator with the algorithm of
   #'uniform until a non-zero value is obtained.  You can use
   this function if you need to avoid a singularity at 0.0.")

(defmfun uniform-fixnum (generator upperbound)
  "gsl_rng_uniform_int" (((generator generator) :pointer) (upperbound :ulong))
  :c-return :ulong
  :documentation			; FDL
  "Generate a random integer from 0 to upperbound-1 inclusive.
   All integers in the range are equally likely, regardless
   of the generator used.  An offset correction is applied so that zero is
   always returned with the correct probability, for any minimum value of
   the underlying generator.  If upperbound is larger than the range
   of the generator then the function signals an error.")

;;;;****************************************************************************
;;;; Information functions about instances
;;;;****************************************************************************

(export 'rng-name)
(defgeneric rng-name (rng-instance)
  (:documentation			; FDL
   "The name of the random number generator."))

(defmfun rng-name ((rng-instance random-number-generator))
  "gsl_rng_name" (((generator rng-instance) :pointer))
  :definition :method
  :c-return :string)

(defmfun rng-max (rng-instance)
  "gsl_rng_max" (((generator rng-instance) :pointer))
  :c-return :unsigned-long
  :documentation "The largest value that #'get-random-number
   can return.")

(defmfun rng-min (rng-instance)
  "gsl_rng_min" (((generator rng-instance) :pointer))
  :c-return :unsigned-long
  :documentation			; FDL
  "The smallest value that #'get-random-number
   can return.  Usually this value is zero.  There are some generators with
   algorithms that cannot return zero, and for these generators the minimum
   value is 1.")

(export 'rng-state)
(defgeneric rng-state (rng-instance)
  (:documentation			; FDL
   "A pointer to the state of generator."))

(defmfun rng-state ((rng-instance random-number-generator))
  "gsl_rng_state" (((generator rng-instance) :pointer))
  :c-return :pointer
  :definition :method
  :index gsl-random-state)

(export 'rng-size)
(defgeneric rng-size (rng-instance)
  (:documentation			; FDL
   "The size of the generator."))

(defmfun rng-size ((rng-instance random-number-generator))
  "gsl_rng_size" (((generator rng-instance) :pointer))
  :c-return sizet
  :definition :method
  :index gsl-random-state)

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

(defmfun copy
    ((destination random-number-generator) (source random-number-generator))
  "gsl_rng_memcpy"
  (((generator destination) :pointer) ((generator source) :pointer))
  :definition :method
  :documentation			; FDL
  "Copy the random number generator source into the
   pre-existing generator destination,
   making destination into an exact copy
   of source.  The two generators must be of the same type.")

(defmfun clone ((instance random-number-generator))
  "gsl_rng_clone" (((generator instance) :pointer))
  :definition :method
  :c-return (mptr :pointer)
  :return ((make-instance 'random-number-generator :mpointer mptr)))

;;;;****************************************************************************
;;;; Examples and unit test
;;;;****************************************************************************

(save-test random-number-generators
 (let ((rng (make-random-number-generator *mt19937* 0)))
   (loop for i from 0 to 10
	 collect
	 (uniform-fixnum rng 1000)))
 (let ((rng (make-random-number-generator *cmrg* 0)))
   (loop for i from 0 to 10 collect (uniform rng))))
