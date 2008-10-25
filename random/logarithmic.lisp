;; Logarithmic distribution
;; Liam Healy, Sat Nov 25 2006 - 16:00
;; Time-stamp: <2008-10-25 17:53:40EDT logarithmic.lisp>
;; $Id$

(in-package :gsl)

(defmfun logarithmic (generator p)
  "gsl_ran_logarithmic"
  (((generator generator) :pointer) (p :double))
  :c-return :uint
  :documentation			; FDL
  "A random integer from the logarithmic distribution.
   The probability distribution for logarithmic random variates
   is p(k) = {-1 \over \log(1-p)} {\left( p^k \over k \right)}
   for k >= 1.")

(defmfun logarithmic-pdf (k p)
  "gsl_ran_logarithmic_pdf" ((k :uint) (p :double))
  :c-return :double
  :documentation
  "The probability p(k) of obtaining k
   from a logarithmic distribution with probability parameter p,
   using the formula given in #'logarithmic.")

;;; Examples and unit test
(save-test logarithmic
  (letm ((rng (random-number-generator *mt19937* 0)))
     (loop for i from 0 to 10
	   collect
	   (logarithmic rng 0.9d0)))
  (logarithmic-pdf 2 0.4d0))
