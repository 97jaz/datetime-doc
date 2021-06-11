#lang scribble/manual

@(require (for-label datetime))

@title{Dates and Times}

@author["Jon Zeppieri"]

@defmodule[datetime]

The @racketmodname[datetime] library provides a feature-rich replacement
for Racket's @seclink["time" #:doc '(lib "scribblings/reference/reference.scrbl")]{basic date and time utilities}.
It is based on, but not wholly compatible with, the @racketmodname[gregor] library.

@table-of-contents[]

@include-section["guide.scrbl"]
@include-section["reference.scrbl"]
