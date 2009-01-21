;; Stepping functions for ODE systems.
;; Liam Healy, Mon Sep 24 2007 - 21:33
;; Time-stamp: <2009-01-20 19:09:55EST stepping.lisp>
;; $Id$

(in-package :gsl)

(defmobject ode-stepper "gsl_odeiv_step"
  ((type :pointer) (dimensions sizet))
  "stepper for ordinary differential equations"
  "Make a stepper for ordinary differential equations.  The type is
   one of the GSL-supplied types defined in stepping.lisp, and
   dimensions is the number of dependent variables.  This instance
   should be reinitialized whenever the next use of it will not be a
   continuation of a previous step."
  "reset" nil)

(defmfun name ((object ode-stepper))
  "gsl_odeiv_step_name"
  (((mpointer object) :pointer))
  :definition :method
  :c-return :string
  :documentation			; FDL
  "The name of the stepping function.")

(defmfun step-order (stepper)
  "gsl_odeiv_step_order"
  (((mpointer stepper) :pointer))
  :c-return :uint
  :documentation			; FDL
  "The order of the stepping function on the previous
  step, which can vary if the stepping function itself is adaptive.")

(defmfun step-apply
    (stepper time step-size y yerr dydt-in dydt-out dydt)
  "gsl_odeiv_step_apply"
  (((mpointer stepper) :pointer)
   (time :double)
   (step-size :double)
   (y :pointer)
   (yerr :pointer)
   (dydt-in :pointer)
   (dydt-out :pointer)
   (dydt :pointer))
  :documentation			; FDL
  "Apply the stepping function stepper to the system of
   equations defined by dydt, using the step size step-size to advance
   the system from time time and state y to time t+h.
   The new state of the system is stored in y on output, with an
   estimate of the absolute error in each component stored in yerr
   If the argument dydt_in is not null it should point an array
   containing the derivatives for the system at time t on input. This
   is optional as the derivatives will be computed internally if they are
   not provided, but allows the reuse of existing derivative information.
   On output the new derivatives of the system at time t+h will
   be stored in dydt-out if it is not null.

   User-supplied functions defined in the system dydt
   should signal an error or return the correct value.")

(defmpar *step-rk2* "gsl_odeiv_step_rk2"
  ;; FDL
  "Embedded Runge-Kutta (2, 3) method.")

(defmpar *step-rk4* "gsl_odeiv_step_rk4"
  ;; FDL
  "4th order (classical) Runge-Kutta.")

(defmpar *step-rkf45* "gsl_odeiv_step_rkf45"
  ;; FDL
  "Embedded Runge-Kutta-Fehlberg (4, 5) method.  This method is a good
   general-purpose integrator.")

(defmpar *step-rkck* "gsl_odeiv_step_rkck"
  ;; FDL
  "Embedded Runge-Kutta Cash-Karp (4, 5) method.")

(defmpar *step-rk8pd* "gsl_odeiv_step_rk8pd"
  ;; FDL
  "Embedded Runge-Kutta Prince-Dormand (8,9) method.")

(defmpar *step-rk2imp* "gsl_odeiv_step_rk2imp"
  ;; FDL
  "Implicit 2nd order Runge-Kutta at Gaussian points.")

(defmpar *step-rk4imp* "gsl_odeiv_step_rk4imp"
  ;; FDL
  "Implicit 4th order Runge-Kutta at Gaussian points.")

(defmpar *step-bsimp* "gsl_odeiv_step_bsimp"
  ;; FDL
  "Implicit Bulirsch-Stoer method of Bader and Deuflhard.  This algorithm
   requires the Jacobian.")

(defmpar *step-gear1* "gsl_odeiv_step_gear1"
  ;; FDL
  "M=1 implicit Gear method.")

(defmpar *step-gear2* "gsl_odeiv_step_gear2"
  ;; FDL
  "M=2 implicit Gear method.")
