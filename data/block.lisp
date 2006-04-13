;********************************************************
; file:        block.lisp                               
; description: Blocks of data                            
; date:        Mon Mar 27 2006 - 12:28                   
; author:      Liam M. Healy                             
; modified:    Thu Apr 13 2006 - 00:00
;********************************************************
;;; $Id: $

(in-package :gsl)

;;; Block definition
(cffi:defcstruct block
  (size :size)
  (data :pointer))

(gsl-data-functions "block" :double)

