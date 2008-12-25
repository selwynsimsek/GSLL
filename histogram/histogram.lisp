;; The histogram structure
;; Liam Healy, Mon Jan  1 2007 - 11:32
;; Time-stamp: <2008-12-25 14:30:48EST histogram.lisp>
;; $Id$

(in-package :gsl)

;;; Define, make, copy histograms in one or two dimensions.

;; /usr/include/gsl/gsl_histogram.h
;; /usr/include/gsl/gsl_histogram2d.h

(defmobject histogram
    "gsl_histogram"
  ((number-of-bins sizet))
  "one-dimensional histogram, including bin boundaries and bin contents."
  NIL
  "set_ranges"
  (((c-pointer ranges) :pointer) ((dim0 ranges) sizet)))

(defmobject histogram2d
    "gsl_histogram2d"
  ((number-of-bins-x sizet) (number-of-bins-y sizet))
  "two-dimensional histogram, including bin boundaries and bin contents."
  NIL
  "set_ranges"
  (((c-pointer x-ranges) :pointer) ((dim0 x-ranges) sizet)
   ((c-pointer y-ranges) :pointer) ((dim0 y-ranges) sizet)))

;;; GSL documentation does not state what the return value for the
;;; C function for reinitialization means; assumed to be error code.

(export 'set-ranges-uniform)
(defgeneric set-ranges-uniform
    (histogram minimum maximum &optional minimum2 maximum2 )
  (:documentation ;; FDL
   "Set the ranges of the existing histogram h to cover
   the range xmin to xmax uniformly.  The values of the
   histogram bins are reset to zero.  The bin ranges are shown in the table
   below,
   bin[0] corresponds to xmin <= x < xmin + d
   bin[1] corresponds to xmin + d <= x < xmin + 2 d
   ......
   bin[n-1] corresponds to xmin + (n-1)d <= x < xmax
   where d is the bin spacing, d = (xmax-xmin)/n."))

;;; GSL documentation does not state what the return value for the
;;; C function for set-ranges-uniform means; assumed to be error code.
(defmfun set-ranges-uniform ((histogram histogram) minimum maximum)
  "gsl_histogram_set_ranges_uniform"
  (((mpointer histogram) :pointer) (minimum :double) (maximum :double))
  :definition :method
  :return (histogram))

;;; GSL documentation does not state what the return value for the
;;; C function means; assumed to be error code.
(defmfun set-ranges-uniform
    ((histogram histogram2d) x-minimum x-maximum &optional y-minimum y-maximum)
  "gsl_histogram2d_set_ranges_uniform"
  (((mpointer histogram) :pointer)
   (x-minimum :double) (x-maximum :double)
   (y-minimum :double) (y-maximum :double))
  :definition :method
  :return (histogram))

(defmfun copy ((destination histogram) (source histogram))
  "gsl_histogram_memcpy"
  (((mpointer destination) :pointer) ((mpointer source) :pointer))
  :definition :method
  :return (destination)
  :documentation			; FDL
  "Copy the histogram source into the pre-existing
   histogram destination, making the latter into
   an exact copy of the former.
   The two histograms must be of the same size.")

(defmfun copy ((destination histogram2d) (source histogram2d))
  "gsl_histogram2d_memcpy"
  (((mpointer destination) :pointer) ((mpointer source) :pointer))
  :definition :method
  :return (destination)
  :documentation			; FDL
  "Copy the histogram source into the pre-existing
   histogram destination, making the latter into
   an exact copy of the former.
   The two histograms must be of the same size.")

;;; Could be part of copy when the second argument is optional?
(export 'clone)
(defgeneric clone (object)
  (:documentation "Create a duplicate object."))

;;; This returns a bare C pointer, which isn't too useful.
(defmfun clone ((source histogram))
  "gsl_histogram_clone"
  (((mpointer source) :pointer))
  :c-return :pointer
  :definition :method
  :documentation			; FDL
  "Create a new histogram which is an
   exact copy of the histogram source, and return the pointer.")

(defmfun clone (source)
  "gsl_histogram2d_clone"
  (((mpointer source) :pointer))
  :definition :method
  :documentation			; FDL
  "Create a new histogram which is an
   exact copy of the histogram source, and return the pointer.")
