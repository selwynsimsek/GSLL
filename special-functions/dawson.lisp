;********************************************************
; file:        dawson.lisp                               
; description: Dawson function                           
; date:        Sun Mar 19 2006 - 14:31                   
; author:      Liam M. Healy                             
; modified:    Mon Jun 12 2006 - 23:17
;********************************************************
;;; $Id: $

#|
The Dawson integral is defined by @math{\exp(-x^2) \int_0^x dt
\exp(t^2)}.  A table of Dawson's integral can be found in Abramowitz &
Stegun, Table 7.5.  The Dawson functions are declared in the header file
@file{gsl_sf_dawson.h}.
|#

(in-package :gsl)

(defun-gsl dawson (x)
  "gsl_sf_dawson_e" ((x :double) (ret sf-result))
  :documentation
  "Dawson's integral for @var{x}.")

(lisp-unit:define-test dawson
  (lisp-unit:assert-first-fp-equal "0.538079506913d+00" (dawson 1.0d0)))
