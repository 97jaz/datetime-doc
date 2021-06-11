#lang scribble/manual

@(require
   (for-label datetime
              (only-in racket/base date*)
              racket/match)
   scribble/example
   "shadowed-definitions.rkt")

@(define the-eval (make-base-eval))
@(the-eval '(require racket/match
                     datetime))


@title[#:tag "datetime-guide" #:style '(toc)]{User Guide}

The @racketmodname[datetime] library provides data structures and functions
for working with dates and times.


Although some @racketmodname[datetime] functions
will work with the @|racket-date| and @racket[date*] structures provided by
@racketmodname[racket/base], users are strongly encouraged to use the
new data structures from this library.

@local-table-of-contents[]

@section[#:tag "guide-intro"]{Introduction}




@section[#:tag "guide-calendar"]{The Calendar}

@margin-note{A calendar produced by such an extension is referred to as a
 @italic{proleptic calendar}.}

The @racketmodname[datetime] library uses the Gregorian calendar exclusively
and extends its use to every point in time. So, for example, even though the
earliest adoption of the Gregorian calendar (in the Catholic states of the
Holy Roman Empire) occurred on 15 October 1582---which immediately followed the
date 4 October 1582 in the @italic{Julian} calendar---the
@racketmodname[datetime] library, if asked, will tell you that
15 October 1582 was preceded by 14 October 1582:
@examples[#:eval the-eval
          (-days (date 1582 10 15) 1)]

In most cases this behavior is benign, but it can get you into trouble if you
are working with historical events. For example, if you want to know the
number of days between the Battle of Hastings (14 October 1066)
and the release of Rick Astley's hit single "Never Gonna Give You Up"
(27 July 1987), it's easy to be misled:
@examples[#:eval the-eval
          (days-between (date 1066 10 14) (date 1987 7 27))]

This answer is wrong, because it fails to account for the fact that the reported
date for the Battle of Hastings is in the Julian calendar, not the Gregorian.
If we substitute the correct Gregorian date for the Battle of Hastings into the
above calculation, we get the correct answer, and the historical record is set
straight:
@examples[#:eval the-eval
          (days-between (date 1066 10 20) (date 1987 7 27))]

The calendar adopted by @racketmodname[datetime] has one other potential suprise.
According to the widely-used @italic{anno Domini} year-numbering convention
established by Dionysius Exiguus, there is no year 0. Instead, the year 1 CE (or AD)
immediately follows the year 1 BCE (or BC).

We, however, reject @italic{anno Domini} in favor of the ISO 8601 system and say that
the year 1 is preceded by the year 0, which, in turn, is preceded by the year -1
(and so forth). In the @racketmodname[datetime] calendar, for example, the year of
Socrates' death is -398, instead of the more familiar 399 BCE.


@section[#:tag "guide-structs"]{Date and Time Datatypes}

At the core of the @racketmodname[datetime] library are the datatypes used to
represent dates and times. In this section, we'll discuss each of these in
turn, but our discussions will be limited to describing what they represent,
how to construct them, and how to use 
@seclink["match" #:doc '(lib "scribblings/reference/reference.scrbl")]{pattern matching}
to extract data from them.

But be aware that there are many other things you can do with these datatypes!
Most of the library's functionality is provided by
@seclink["guide-generics"]{generic interfaces}.

@; DATE
@subsection[#:tag "guide-date"]{Dates}

A @deftech{date} is a particular combination of year, month, and day-of-month in the
@seclink["guide-calendar"]{proleptic Gregorian calendar}.

@subsubsection[#:tag "guide-date-cons"]{Construction}
@examples[#:eval the-eval
          (code:line (date 1986 4 26) (code:comment "Chernobyl disaster"))
          (code:line (date 1964 5 1) (code:comment "BASIC release date"))]

As the above examples demonstrate, to create a @tech{date}, you simply call @racket[date]
with a year, month, and day. If you omit the day argument, you'll get back a result
for the first of the month:
@examples[#:eval the-eval
          (date 2000 6)]

And if you omit both the month and day arguments, you'll get back a result for the first
of the year:
@examples[#:eval the-eval
          (date 2000)]


@subsubsection[#:tag "guide-date-match"]{Pattern-matching}

@margin-note{Note that when you use @racket[date] as a match expander,
 you cannot omit the patterns for the month or day fields. You can, of course,
 use the wildcard pattern (@tt{_}) to ignore them.}

Just as @racket[date] is used to create a date, it can also be used with
@racket[match] to extract a date's component fields:
@examples[#:eval the-eval
          (define basic-release-date (date 1964 5))
          (match basic-release-date
            [(date y m d) (list y m d)])]

@; TIME
@subsection[#:tag "guide-time"]{Times}

A @deftech{time} represents a time-of-day, irrespective of date. It comprises fields
containing the hour-of-day, minute-of-hour, second-of-minute, and
nanosecond-of-second. There is no AM/PM field; the hour-of-day is between 0 and 23.

@subsubsection[#:tag "guide-time-cons"]{Construction}

As with @racket[date], the arguments to @racket[time] are provided in order from
most- to least-significant, and you're only required to provide a single argument.
Any omitted trailing arguments default to 0:
@examples[#:eval the-eval
          (time 0 1 2 3)
          (time 21 11 37)
          (time 12 30)
          (time 12)]

@subsubsection[#:tag "guide-time-match"]{Pattern-matching}

Pattern-matching on times works exactly as it does with dates:
@examples[#:eval the-eval
          (define sunset (time 17 50))
          (match sunset
            [(time hour minute _ _) (list hour minute)])]

@; DATETIME
@subsection[#:tag "guide-datetime"]{Date-Times}

A @tech{datetime} is the combination of a @tech{date} and a @tech{time}. So,
for example, if you wanted to represent "10:30 in the morning on 22 October 2017,"
you could use a datetime to accomplish that.

But note that this description ("10:30 in the morning on 22 October 2017") does not
describe an absolute moment in time. The very same moment that a speaker in New York
describes as "10:30" might be described by a Californian as "7:30."

@subsubsection[#:tag "guide-datetime-cons"]{Construction}

There are several ways to construct a datetime, but we'll focus on the three
most-common ones.

First, the @racket[datetime] function constructs a datetime from individual date and time
fields, starting with the year and ending with the nanoseconds. As with the @racket[date]
and @racket[time] constructors, only one argument (the year) is required, and omitted
arguments follow the same rules that were described in the previous sections.
@examples[#:eval the-eval
          (datetime 2017 10 22 10 30)
          (datetime 2017)]

Second, @racket[date->datetime] constructs a datetime from a date and
(optionally) a time. If no time is given, it is assumed to be midnight:
@examples[#:eval the-eval
          (date->datetime (date 2017 10 22) (time 10 30))
          (date->datetime (date 2017))]

Finally, @racket[posix->datetime] constructs a datetime from a POSIX time. The resulting
datetime contains the UTC date and time represented by the input timestamp:
@examples[#:eval the-eval
          (posix->datetime 0)
          (posix->datetime 1508726115.146)]

@subsubsection[#:tag "guide-datetime-match"]{Pattern-matching}

As a match-expander, @racket[datetime] has two forms, corresponding to the first two
constructors described above.

When given seven sub-patterns, each sub-pattern is matched against the
corresponding date or time field, starting with year and ending with nanosecond:
@examples[#:eval the-eval
          (match (datetime 2000 1 1 0 1 2 3)
            [(datetime yr mo dy hr mi sc ns)
             (list yr mo dy hr mi sc ns)])]

But when given two sub-patterns, the first is matched against a @tech{date} and the
second against a @tech{time}:
@examples[#:eval the-eval
          (match (datetime 2000 1 1 0 1 2 3)
            [(datetime (date yr mo dy) tm)
             (list yr mo dy tm)])]