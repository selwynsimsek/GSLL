;; Beta distribution
;; Liam Healy, Sat Sep 30 2006
;; Time-stamp: <2008-10-25 12:08:05EDT beta.lisp>
;; $Id$

(in-package :gsl)

(defmfun beta-rd (generator a b)
  ;; Named #'beta-rd to avoid confusion with the special function #'beta.
  "gsl_ran_beta"
  (((generator generator) :pointer) (a :double) (b :double))
  :c-return :double
  :documentation			; FDL
  "A random variate from the beta distribution.  The distribution function is
   p(x) dx = {\Gamma(a+b) \over \Gamma(a) \Gamma(b)} x^{a-1} (1-x)^{b-1} dx
   0 <= x <= 1.")

(defmfun beta-pdf (x a b)
  "gsl_ran_beta_pdf" ((x :double) (a :double) (b :double))
  :c-return :double
  :documentation			; FDL
  "The probability density p(x) at x
   for a beta distribution with parameters a and b, using the
   formula given in #'beta.")

(defmfun beta-P (x a b)
  "gsl_cdf_beta_P" ((x :double) (a :double) (b :double))
  :c-return :double
  :documentation			; FDL
  "The cumulative distribution functions
  P(x) for the beta distribution with parameters a and b.")

(defmfun beta-Q (x a b)
  "gsl_cdf_beta_Q" ((x :double) (a :double) (b :double))
  :c-return :double
  :documentation			; FDL
  "The cumulative distribution functions
  Q(x) for the beta distribution with parameters a and b.")

(defmfun beta-Pinv (P a b)
  "gsl_cdf_beta_Pinv" ((P :double) (a :double) (b :double))
  :c-return :double
  :documentation			; FDL
  "The inverse cumulative distribution functions
  P(x) for the beta distribution with parameters a and b.")

(defmfun beta-Qinv (Q a b)
  "gsl_cdf_beta_Qinv" ((Q :double) (a :double) (b :double))
  :c-return :double
  :documentation			; FDL
  "The inverse cumulative distribution functions
   Q(x) for the beta distribution with parameters a and b.")

;;; Examples and unit test
(save-test beta
  (letm ((rng (random-number-generator *mt19937* 0)))
      (loop for i from 0 to 10
	    collect
	    (beta-rd rng 1.0d0 2.0d0)))
  (beta-pdf 0.1d0 1.0d0 2.0d0)
  (beta-P 0.1d0 1.0d0 2.0d0)
  (beta-Q 0.1d0 1.0d0 2.0d0)
  (beta-Pinv 0.19d0 1.0d0 2.0d0)
  (beta-Qinv 0.81d0 1.0d0 2.0d0))



