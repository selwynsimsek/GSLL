;; Regression test COMBINATION for GSLL, automatically generated

(in-package :gsl)

(LISP-UNIT:DEFINE-TEST COMBINATION
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 4)
   (MULTIPLE-VALUE-LIST
    (LET ((COMB (MAKE-COMBINATION 4 2)))
      (COMBINATION-RANGE COMB))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST 2)
   (MULTIPLE-VALUE-LIST
    (LET ((COMB (MAKE-COMBINATION 4 2)))
      (SIZE COMB))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST (LIST #(0 1) #(0 2) #(0 3) #(1 2) #(1 3) #(2 3)))
   (MULTIPLE-VALUE-LIST
    (LET ((COMB (MAKE-COMBINATION 4 2)))
      (INIT-FIRST COMB)
      (LOOP COLLECT (COPY-SEQ (CL-ARRAY COMB)) WHILE
	   (COMBINATION-NEXT COMB)))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST (LIST #(2 3) #(1 3) #(1 2) #(0 3) #(0 2) #(0 1)))
   (MULTIPLE-VALUE-LIST
    (LET ((COMB (MAKE-COMBINATION 4 2)))
      (INIT-LAST COMB)
      (LOOP COLLECT (COPY-SEQ (CL-ARRAY COMB)) WHILE
	   (COMBINATION-PREVIOUS COMB)))))
  (LISP-UNIT::ASSERT-NUMERICAL-EQUAL
   (LIST
    (LIST #() #(0) #(1) #(2) #(3) #(0 1) #(0 2) #(0 3)
	  #(1 2) #(1 3) #(2 3) #(0 1 2) #(0 1 3) #(0 2 3)
	  #(1 2 3) #(0 1 2 3)))
   (MULTIPLE-VALUE-LIST
    (LOOP FOR I FROM 0 TO 4 APPEND
	 (LET ((COMB (MAKE-COMBINATION 4 I)))
	   (INIT-FIRST COMB)
	   (LOOP COLLECT (COPY-SEQ (CL-ARRAY COMB)) WHILE
		(COMBINATION-NEXT COMB)))))))

