;; Coulumb functions
;; Liam Healy, Sat Mar 18 2006 - 23:23
;; Time-stamp: <2009-04-26 22:57:18EDT coulomb.lisp>
;; $Id$

(in-package :gsl)

;;; /usr/include/gsl/gsl_sf_coulomb.h

;;;;****************************************************************************
;;;; Normalized Hydrogenic Bound States
;;;;****************************************************************************

(defmfun hydrogenicR-1 (x r)
  "gsl_sf_hydrogenicR_1_e" ((x :double) (r :double) (ret sf-result))
  :documentation			; FDL
  "The lowest-order normalized hydrogenic bound state radial
   wavefunction R_1 := 2Z \sqrt{Z} \exp(-Z r).")

(defmfun hydrogenicR (n l x r)
  "gsl_sf_hydrogenicR_e"
  ((n :int) (l :int) (x :double) (r :double) (ret sf-result))
  :documentation			; FDL
  "The n-th normalized hydrogenic bound state radial wavefunction,
  R_n := {2 Z^{3/2} \over n^2}  \left({2Z \over n}\right)^l
  \sqrt{(n-l-1)! \over (n+l)!} \exp(-Z r/n) L^{2l+1}_{n-l-1}(2Z/n r).
  The normalization is chosen such that the wavefunction \psi is given by 
  \psi(n,l,r) = R_n Y_{lm}.")

;;;;****************************************************************************
;;;; Coulomb Wave Functions
;;;;****************************************************************************

(defmfun coulomb-wave-FG (eta x L-F k)
  "gsl_sf_coulomb_wave_FG_e"
  ((eta :double) (x :double) (L-F :double) (k :int)
   (F sf-result) (Fp sf-result) (G sf-result) (Gp sf-result)
   (exp-F (:pointer :double)) (exp-G (:pointer :double)))
  :return
  ((val F) (val Fp) (val G) (val Gp)
   (dcref exp-F) (dcref exp-G)
   (err F) (err Fp) (err G) (err Gp))
  :documentation			; FDL
  "The Coulomb wave functions F_L(\eta,x),
  G_{L-k}(\eta,x) and their derivatives F'_L(\eta,x), G'_{L-k}(\eta,x)
  with respect to x.  The parameters are restricted to L, L-k > -1/2},
  x > 0 and integer k.  Note that L itself is not restricted to being
  an integer. The results are stored in the parameters F, G for the
  function values and Fp, Gp for the derivative values.  If an
  overflow occurs, the condition 'overflow is signalled and scaling
  exponents are stored in the modifiable parameters exp-F, exp-G.")

(defmfun coulomb-wave-F-array
    (L-min eta x &optional (size-or-array *default-sf-array-size*)
	   &aux (fc-array (vdf size-or-array)))
  "gsl_sf_coulomb_wave_F_array"
  ((L-min :double) ((1- (dim0 fc-array)) :int) (eta :double) (x :double)
   ((c-pointer fc-array) :pointer) (F-exponent (:pointer :double)))
  :outputs (fc-array)
  :return (fc-array (dcref F-exponent))
  :documentation			; FDL
  "The Coulomb wave function F_L(\eta,x) for
  L = Lmin ... Lmin + kmax, storing the results in fc-array.
  In the case of overflow the exponent is stored in the second value returned.")

(defmfun coulomb-wave-FG-array
    (L-min eta x
	   &optional (fc-size-or-array *default-sf-array-size*)
	   gc-size-or-array
	   &aux (fc-array (vdf fc-size-or-array))
	   (gc-array (vdf (or gc-size-or-array (dim0 fc-array)))))
  "gsl_sf_coulomb_wave_FG_array"
  ((L-min :double) ((1- (dim0 fc-array)) :int) (eta :double) (x :double)
   ((c-pointer fc-array) :pointer) ((c-pointer gc-array) :pointer)
   (F-exponent (:pointer :double)) (G-exponent (:pointer :double)))
  :outputs (fc-array gc-array)
  :return (fc-array gc-array (dcref F-exponent) (dcref G-exponent))
  :documentation			; FDL
  "The functions F_L(\eta,x),
  G_L(\eta,x) for L = Lmin ... Lmin + kmax storing the
  results in fc_array and gc_array.  In the case of overflow the
  exponents are stored in F_exponent and G_exponent.")

(defmfun coulomb-wave-FGp-array
    (L-min eta x
	   &optional (fc-size-or-array *default-sf-array-size*)
	   fcp-size-or-array
	   gc-size-or-array
	   gcp-size-or-array
	   &aux (fc-array (vdf fc-size-or-array))
	   (fcp-array (vdf (or fcp-size-or-array (dim0 fc-array))))
	   (gc-array (vdf (or gc-size-or-array (dim0 fc-array))))
	   (gcp-array (vdf (or gcp-size-or-array (dim0 fc-array)))))
  "gsl_sf_coulomb_wave_FGp_array"
  ((L-min :double) ((1- (dim0 fc-array)) :int) (eta :double) (x :double)
   ((c-pointer fc-array) :pointer) ((c-pointer fcp-array) :pointer)
   ((c-pointer gc-array) :pointer) ((c-pointer gcp-array) :pointer)
   (F-exponent (:pointer :double)) (G-exponent (:pointer :double)))
  :outputs (fc-array fcp-array gc-array gcp-array)
  :return
  (fc-array fcp-array gc-array gcp-array
	    (dcref F-exponent) (dcref G-exponent))
  :documentation			; FDL
  "The functions F_L(\eta,x),
  G_L(\eta,x) and their derivatives F'_L(\eta,x),
  G'_L(\eta,x) for L = Lmin ... Lmin + kmax storing the
  results in fc_array, gc_array, fcp_array and gcp_array.
  In the case of overflow the exponents are stored in F_exponent
  and G_exponent.")

(defmfun coulomb-wave-sphF-array
    (L-min eta x &optional (size-or-array *default-sf-array-size*)
	   &aux (fc-array (vdf size-or-array)))
  "gsl_sf_coulomb_wave_sphF_array"
  ((L-min :double) ((1- (dim0 fc-array)) :int) (eta :double) (x :double)
   ((c-pointer fc-array) :pointer) (F-exponent (:pointer :double)))
  :outputs (fc-array)
  :return (fc-array (dcref F-exponent))
  :documentation			; FDL
  "The Coulomb wave function divided by the argument
   F_L(\eta, x)/x for L = Lmin ... Lmin + kmax, storing the
   results in fc_array.  In the case of overflow the exponent is
   stored in F_exponent. This function reduces to spherical Bessel
   functions in the limit \eta \to 0.")

;;;;****************************************************************************
;;;; Coulomb Wave Function Normalization Constant
;;;;****************************************************************************

(defmfun coulomb-CL (L eta)
  "gsl_sf_coulomb_CL_e" ((L :double) (eta :double) (ret sf-result))
  :documentation			; FDL
  "The Coulomb wave function normalization constant C_L(\eta)
   for L > -1.")

(defmfun coulomb-CL-array
    (L-min eta &optional (size-or-array *default-sf-array-size*)
	   &aux (array (vdf size-or-array)))
  "gsl_sf_coulomb_CL_array"
  ((L-min :double) ((1- (dim0 array)) :int) (eta :double)
   ((c-pointer array) :pointer))
  :outputs (array)
  :documentation			; FDL
  "The Coulomb wave function normalization constant C_L(\eta)
   for L = Lmin ... Lmin + kmax, Lmin > -1.")

;;;;****************************************************************************
;;;; Examples and unit test
;;;;****************************************************************************

(save-test coulomb
 (hydrogenicr-1 1.0d0 2.5d0)
 (hydrogenicr 3 1 1.0d0 2.5d0)
 (coulomb-wave-FG 0.0d0 1.0d0 2.0d0 0)
 (let ((arr (make-marray 'double-float :dimensions 3)))
   (coulomb-wave-F-array 0.0d0 1.0d0 2.0d0 arr)
   (cl-array arr))
 (coulomb-wave-fg 1.0d0 2.0d0 2.5d0 1)
 (let ((Farr (make-marray 'double-float :dimensions 3))
       (Garr (make-marray 'double-float :dimensions 3)))
   (coulomb-wave-FG-array 1.5d0 1.0d0 1.0d0 Farr Garr)
   (append (coerce (cl-array Farr) 'list) (coerce (cl-array Garr) 'list)))
 (let ((arr (make-marray 'double-float :dimensions 3)))
   (coulomb-wave-sphF-array  0.0d0 1.0d0 2.0d0 arr) (cl-array arr))
 (coulomb-cl 1.0d0 2.5d0)
 (let ((cl (make-marray 'double-float :dimensions 3)))
   (coulomb-CL-array 0.0d0 1.0d0 cl) (cl-array cl)))
