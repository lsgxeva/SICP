(define (make-monitored f)
  (let ((counter 0))
    (lambda (x)
      (cond ((eq? x 'how-many-calls?) counter)
            ((eq? x 'reset-count) (set! counter 0))
            (else
             (begin (set! counter (+ counter 1))
                    (f x)))))))

(define (make-account balance password)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (check-password pw)
    (if (eq? pw password)
        (begin (password-fault 'reset-count)
               #t)
        (if (> (password-fault 'how-many-calls?) 7)
            (begin (call-the-cops) #f)
            #f)))
  (define call-the-cops 
    (lambda () (display "Policeman!!!!")))
  (define password-fault 
    (make-monitored (lambda (x) "Incorrect password")))
  (define (dispatch pw m)
    (if (check-password pw)
        (cond ((eq? m 'withdraw) withdraw)
              ((eq? m 'deposit) deposit)
              (else (error "Unknown requeset -- MAKE-ACCOUNT"
                           m)))
        password-fault))
  dispatch)