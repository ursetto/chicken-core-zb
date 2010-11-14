;;;; thread-list.scm
;
; usage: csi -s thread-list.scm [COUNT]

(use srfi-18)


(define count #f)

(define (run n)
  (set! count n)
  (print "creating " n " threads ...")
  (let loop ((n n) (prev #f))
    (cond ((negative? n)
	   (print "starting ...")
	   (thread-start! prev))
	  (else
	   (loop
	    (sub1 n)
	    (make-thread
	     (lambda ()
	       (thread-start! prev)
	       (bump n))))))))

(define (bump n)
  (set! count (sub1 count))
  (cond ((zero? count) 
	 (newline)
	 (exit))
	((zero? (modulo n 1000))
	 (print* "."))))

(run (string->number (optional (command-line-arguments) "250000")))
(thread-sleep! 604800)


; time csi -s thread-list.scm 1000000 -:h1g -:d
;   11 secs
;
; csc thread-list.scm -o a.out -v -O4 -f -d0
; time a.out 1000000 -:h1g -:d
;   4 secs
;
; (x86, Core2 Duo, 2.4Ghz, 2GB RAM)
