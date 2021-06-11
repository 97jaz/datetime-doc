#lang at-exp racket/base

(require scribble/manual
         (for-label racket/base))

(define racket-date @racket[date])
(define racket-time @racket[time])

(provide racket-date
         racket-time)
