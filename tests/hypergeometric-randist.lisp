;; Regression test HYPERGEOMETRIC-RANDIST for GSLL, automatically generated

(in-package :gsl)

(LISP-UNIT:DEFINE-TEST HYPERGEOMETRIC-RANDIST
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST (LIST 2 1 0 0 1 1 3 1 0 1 3))
                        (MULTIPLE-VALUE-LIST
                         (LET ((RNG (MAKE-RANDOM-NUMBER-GENERATOR *MT19937* 0)))
                           (LOOP FOR I FROM 0 TO 10 COLLECT
                                 (HYPERGEOMETRIC RNG 3 6 3)))))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST 0.35714285714285693d0)
                        (MULTIPLE-VALUE-LIST (HYPERGEOMETRIC-PDF 0 2 6 3)))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST 0.892857142857143d0)
                        (MULTIPLE-VALUE-LIST (HYPERGEOMETRIC-P 1 2 6 3)))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST 0.10714285714285704d0)
                        (MULTIPLE-VALUE-LIST (HYPERGEOMETRIC-Q 1 2 6 3))))
