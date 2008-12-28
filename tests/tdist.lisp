;; Regression test TDIST for GSLL, automatically generated

(in-package :gsl)

(LISP-UNIT:DEFINE-TEST TDIST
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST
                         (LIST 0.14989366374481017d0 0.6794142879291215d0
                               -1.615833951108472d0 -1.6008862825783456d0
                               -1.7010935505767397d0 -0.04370959749808691d0
                               0.12761159276595174d0 -0.019731218255494867d0
                               -0.6534666117199732d0 0.2035771324523077d0
                               1.77650300477611d0))
                        (MULTIPLE-VALUE-LIST
                         (LET ((RNG (MAKE-RANDOM-NUMBER-GENERATOR *MT19937* 0)))
                           (LOOP FOR I FROM 0 TO 10 COLLECT
                                 (TDIST RNG 10.0d0)))))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST 0.2546479089470325d0)
                        (MULTIPLE-VALUE-LIST (TDIST-PDF 0.5d0 1.0d0)))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST 0.6475836176504332d0)
                        (MULTIPLE-VALUE-LIST (TDIST-P 0.5d0 1.0d0)))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST 0.35241638234956685d0)
                        (MULTIPLE-VALUE-LIST (TDIST-Q 0.5d0 1.0d0)))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
                        (LIST 0.500000000000001d0)
                        (MULTIPLE-VALUE-LIST
                         (TDIST-PINV 0.6475836176504334d0 1.0d0)))
                       (LISP-UNIT::ASSERT-NUMERICAL-EQUAL (LIST 0.5d0)
                                                          (MULTIPLE-VALUE-LIST
                                                           (TDIST-QINV
                                                            0.3524163823495667d0
                                                            1.0d0))))
