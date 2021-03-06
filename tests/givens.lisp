;; Regression test GIVENS for GSLL, automatically generated

(in-package :gsl)

(LISP-UNIT:DEFINE-TEST GIVENS
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST
                         (LIST
                          #(-47.39726 8.24 3.29 -8.93 34.12 -6.15 49.27 -13.49)
                          #(-0.6856937 42.73 -17.24 43.31 -16.12 -8.25 21.44
                            -49.08)))
                        (MULTIPLE-VALUE-LIST
                         (LET ((V1
                                (MAKE-MARRAY 'SINGLE-FLOAT :INITIAL-CONTENTS
                                             '(-34.5 8.24 3.29 -8.93 34.12
                                               -6.15 49.27 -13.49)))
                               (V2
                                (MAKE-MARRAY 'SINGLE-FLOAT :INITIAL-CONTENTS
                                             '(32.5 42.73 -17.24 43.31 -16.12
                                               -8.25 21.44 -49.08)))
                               (ANGLES
                                (MAKE-MARRAY 'SINGLE-FLOAT :INITIAL-CONTENTS
                                             '(-39.66 -49.46 19.68 -5.55 -8.82
                                               25.37 -30.58 31.67)))
                               (SINES
                                (MAKE-MARRAY 'SINGLE-FLOAT :DIMENSIONS '8))
                               (COSINES
                                (MAKE-MARRAY 'SINGLE-FLOAT :DIMENSIONS '8)))
                           (LOOP FOR I BELOW 8 DO
                                 (SETF (MAREF SINES I) (SIN (MAREF ANGLES I)))
                                 (SETF (MAREF COSINES I)
                                         (COS (MAREF ANGLES I))))
                           (GIVENS-ROTATION V1 V2 COSINES SINES)
                           (LIST (CL-ARRAY V1) (CL-ARRAY V2)))))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST
                         (LIST
                          #(-47.39725730461627d0 8.24d0 3.29d0 -8.93d0 34.12d0
                            -6.15d0 49.27d0 -13.49d0)
                          #(-0.6856936845760199d0 42.73d0 -17.24d0 43.31d0
                            -16.12d0 -8.25d0 21.44d0 -49.08d0)))
                        (MULTIPLE-VALUE-LIST
                         (LET ((V1
                                (MAKE-MARRAY 'DOUBLE-FLOAT :INITIAL-CONTENTS
                                             '(-34.5d0 8.24d0 3.29d0 -8.93d0
                                               34.12d0 -6.15d0 49.27d0
                                               -13.49d0)))
                               (V2
                                (MAKE-MARRAY 'DOUBLE-FLOAT :INITIAL-CONTENTS
                                             '(32.5d0 42.73d0 -17.24d0 43.31d0
                                               -16.12d0 -8.25d0 21.44d0
                                               -49.08d0)))
                               (ANGLES
                                (MAKE-MARRAY 'DOUBLE-FLOAT :INITIAL-CONTENTS
                                             '(-39.66d0 -49.46d0 19.68d0
                                               -5.55d0 -8.82d0 25.37d0 -30.58d0
                                               31.67d0)))
                               (SINES
                                (MAKE-MARRAY 'DOUBLE-FLOAT :DIMENSIONS '8))
                               (COSINES
                                (MAKE-MARRAY 'DOUBLE-FLOAT :DIMENSIONS '8)))
                           (LOOP FOR I BELOW 8 DO
                                 (SETF (MAREF SINES I) (SIN (MAREF ANGLES I)))
                                 (SETF (MAREF COSINES I)
                                         (COS (MAREF ANGLES I))))
                           (GIVENS-ROTATION V1 V2 COSINES SINES)
                           (LIST (CL-ARRAY V1) (CL-ARRAY V2))))))

