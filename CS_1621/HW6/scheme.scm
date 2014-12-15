;Write a Scheme function that returns the number of zeros in a given simple list of numbers
(define (numzeros lis)
  (cond
    ((null? lis) 0)
    ((= 0 (car lis)) (+ 1 (numzeros (cdr lis))))
    (else (numzeros (cdr lis)))
  )
)

; Write a Scheme function that returns the reverse of its simple list parameter
(define (revlist lis)
  (cond
    ((null? lis) '())
	(else ((cdr list) . (revlist (cdr lis))))
  )
)