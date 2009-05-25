;; Dirichlet distribution
;; Liam Healy, Sun Oct 29 2006
;; Time-stamp: <2009-05-24 22:55:07EDT dirichlet.lisp>
;; $Id$

(in-package :gsl)

;;; /usr/include/gsl/gsl_randist.h

(defmfun sample
    ((generator random-number-generator) (type (eql 'dirichlet))
     &key alpha (theta (vdf (dim0 alpha))))
  "gsl_ran_dirichlet"
  (((mpointer generator) :pointer)
   ((dim0 alpha) sizet)
   ((c-pointer alpha) :pointer)
   ;; theta had better be at least as long as alpha, or they'll be trouble
   ((c-pointer theta) :pointer))
  :definition :method
  :inputs (alpha)
  :outputs (theta)
  :c-return :void
  :return (theta)
  :documentation			; FDL
  "An array of K=(length alpha) random variates from a Dirichlet
  distribution of order K-1.  The distribution function is
  p(\theta_1,\ldots,\theta_K) \, d\theta_1 \cdots d\theta_K = 
        {1 \over Z} \prod_{i=1}^{K} \theta_i^{\alpha_i - 1} 
          \; \delta(1 -\sum_{i=1}^K \theta_i) d\theta_1 \cdots d\theta_K
  theta_i >= 0 and alpha_i >= 0.
  The delta function ensures that \sum \theta_i = 1.
  The normalization factor Z is
  Z = {\prod_{i=1}^K \Gamma(\alpha_i) \over \Gamma( \sum_{i=1}^K \alpha_i)}
  The random variates are generated by sampling K values 
  from gamma distributions with parameters a=alpha_i, b=1, 
  and renormalizing. 
  See A.M. Law, W.D. Kelton, \"Simulation Modeling and Analysis\"
  (1991).")

(defmfun dirichlet-pdf (alpha theta)
  "gsl_ran_dirichlet_pdf"
  (((1- (dim0 alpha)) sizet)
   ((c-pointer alpha) :pointer)
   ;; theta had better be at least as long as alpha, or they'll be trouble
   ((c-pointer theta) :pointer))
  :inputs (alpha theta)
  :c-return :double
  :documentation			; FDL
  "The probability density p(\theta_1, ... , \theta_K)
   at theta[K] for a Dirichlet distribution with parameters 
   alpha[K], using the formula given for #'dirichlet.")

(defmfun dirichlet-log-pdf (alpha theta)
  "gsl_ran_dirichlet_lnpdf"
  (((1- (dim0 alpha)) sizet)
   ((c-pointer alpha) :pointer)
   ;; theta had better be at least as long as alpha, or they'll be trouble
   ((c-pointer theta) :pointer))
  :inputs (alpha theta)
  :c-return :double
  :documentation			; FDL
  "The logarithm of the probability density 
   p(\theta_1, ... , \theta_K)
   for a Dirichlet distribution with parameters 
   alpha[K].")

;;; Examples and unit test
(save-test dirichlet
 (let ((rng (make-random-number-generator +mt19937+ 0))
       (alpha #m(1.0d0 2.0d0 3.0d0 4.0d0)))
   (cl-array (sample rng 'dirichlet :alpha alpha)))
 (let ((alpha #m(1.0d0 2.0d0 3.0d0 4.0d0))
       (theta #m(1.0d0 2.0d0 3.0d0 4.0d0)))
   (dirichlet-pdf alpha theta))
 (let ((alpha #m(1.0d0 2.0d0 3.0d0 4.0d0))
       (theta #m(1.0d0 2.0d0 3.0d0 4.0d0)))
   (dirichlet-log-pdf alpha theta)))



