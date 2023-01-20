#lang scribble/manual
@require[scribble-math]
@require[scribble-math/dollar]
@require[racket/runtime-path]
@require[scribble/minted]

@require["../../lib.rkt"]
@define-runtime-path[hw-file "hw4.rkt"]


@title[#:tag "hw4" #:style (with-html5 manual-doc-style)]{Homework 4}

@bold{Released:} @italic{Wednesday, February 1, 2023 at 6:00pm}

@bold{Due:} @italic{Wednesday, February 8, 2023 at 6:00pm}


@nested[#:style "boxed"]{
What to Download:

@url{https://github.com/logiccomp/s23-hw4/raw/main/hw4.rkt}
}

Please start with this file, filling in where appropriate, and submit your homework to the @tt{HW4} assignment on Gradescope. This page has additional information, and allows us to format things nicely.


@section{Superoptimization}

Superoptimization is the idea of replacing a given loop-free sequence of instructions with an equivalent sequence of instructions 
that is somehow better (usually, shorter and as a result, faster). It's used in compilers at the very lowest level, to 
optimize numeric operations into often counter-intuitive sequences of instructions that can be baffling at first. It was invented by computer scientist Alexia Massalin in 1987: her idea was to find the shortest sequence of instructions, given a particular instruction set, to compute a given function. This 
is in contrast to most compiler optimization, which merely aim to improve performance, rather than 
finding truly optimal solutions.


The resulting programs often rely somewhat complex interactions between different instructions, and sometimes "startling" programs that rely on strange overlap between representations of
different values: often times, code with branches is replaced with equivalent code that doesn't use branches, for example. 

@section{Problem 1}
While super-optimization is something that can be done using SMT solvers, in this homework, we will tackle a simpler problem: verifying ordinary optimizations. In particular,
showing that a program before and after an optimization are equivalent. 

Our first optimization will use a slightly extended version of the same stack-based calculator
from HW2. Note that since we are using the language @mintinline["racket"]{#lang rosette/safe} instead of @mintinline["racket"]{#lang isl-spec}, @mintinline["racket" "define-struct"] is slightly different, in that by default the struct values will
print out without showing their contents. The @mintinline["racket" "#:transparent"] optional argument changes
that.

@minted-file-part["racket" "p1a" hw-file]


Your task is to first implement a function that verifies that two programs written in this 
language are equivalent, where equivalent means runs to the same thing:

@minted-file-part["racket" "p1b" hw-file]

@section{Problem 2}
The next problem is to implement a simple optimization. In this case, we want you to implement 
a simple form of @italic{constant folding}. Constant folding is the idea of replacing a series of 
operations that are all on constants with the result of running those operations at optimization time. By doing it at optimization time, it won't have to be done when the program is actually running. In this case, 
we want your optimization to replace the sequence @mintinline["racket" "(make-push n) (make-push m) (make-add)"] with @mintinline["racket" "(make-push o)"] where @mintinline["racket" "o"] is @mintinline["racket" "m"] plus @mintinline["racket" "n"]. You do not need to (and should not) replace
sequences that only appear after the initial constant folding has been done. i.e., the sequence @mintinline["racket" "(make-push l) (make-push n) (make-push m) (make-add) (make-add)"] should turn into @mintinline["racket" "(make-push l) (make-push o) (make-add)"], where @mintinline["racket" "o"] is the result of adding @mintinline["racket" "n"] and @mintinline["racket" "m"], but should @italic{not} be further optimized into a single @mintinline["racket" "(make-push p)"], where @mintinline["racket" "p"] is the result of adding @mintinline["racket" "l"] and @mintinline["racket" "o"].

@minted-file-part["racket" "p2" hw-file]

@section{Problem 3}
To check that your constant folding works, we are going to take two approaches. First, we'll
use Property Based Testing (PBT) using the @link["https://docs.racket-lang.org/quickcheck/index.html"]{Quickcheck} library. In order to do that, you need to 
define a generator for @mintinline["racket" "SimpleInstr"]s. Note that, since we are in a @mintinline["racket"]{#lang rosette/safe} file, we have required the quickcheck library directly, so there are no @code{qc:} prefixes on the functions.

@minted-file-part["racket" "p3a" hw-file]

With that, you can now define a property that generates a list of instructions, runs the constant 
folding optimization on it, and then verifies that the result is equivalent to the original program. Note that @mintinline["racket" "property"] is how the quickcheck library writes @code{for-all}.

@minted-file-part["racket" "p3b" hw-file]

@section{Problem 4}
To gain more confidence in our approach, we'll use Rosette to do a limited form of @italic{exhaustive}
testing. First, we'll define a symbolic version of a @mintinline["racket" "SimpleInstr"], using @mintinline["racket" "choose*"] to enumerate different possibilies (for reference on how to do this, see lecture notes: @seclink["l10" "2/1"]):

@minted-file-part["racket" "p4a" hw-file]

Using that, we can define a program that a is list of up to 6 instructions. Think about how you could
have it be @italic{up to} 6 instructions, rather than exactly 6 instructions. 

@minted-file-part["racket" "p4b" hw-file]

Finally, we can now use this symbolic program to verify that the constant folding optimization
works on all programs of up to 6 instructions by using @mintinline["racket" "verify"] and 
@mintinline["racket" "assert"] from Rosette.

@minted-file-part["racket" "p4c" hw-file]

@section{Problem 5}
In this problem, we'll extend the stack calculator to include @italic{variables}, so that 
there are real limits to what even the best constant folding could do. We represent variable
names with numbers, to make things easier, and now @mintinline["racket" "eval"] takes a set of 
variable bindings that give values for each variable. 

@minted-file-part["racket" "p5a" hw-file]


Your first task is to make an updated version of your verify function, to check that two programs
are equivalent. Now, you take in a set of variable bindings that both programs will use.

@minted-file-part["racket" "p5b" hw-file]

Your next task is to define a more general version of constant folding. This time, look for 
any sequence of @mintinline["racket" "(make-push n) (make-push m) (make-op)"] where @mintinline["racket" "op"] is one of @mintinline["racket" "add"], @mintinline["racket" "sub"], or @mintinline["racket" "mul"]. You still
shouldn't replace sequences that only appear after the initial constant folding has been done.

@minted-file-part["racket" "p5c" hw-file]

Now, define a new generator for instructions:

@minted-file-part["racket" "p5d" hw-file]

And a generator for bindings:

@minted-file-part["racket" "p5e" hw-file]

So you can do PBT testing of your constant folding:

@minted-file-part["racket" "p5f" hw-file]

Now you'll update the symbolic version, by defining a symbolic instruction, program, binding,
and environment. Note that for this example, to keep things running fast, have the 
program have only up to @bold{4} instructions, and have the environment have only up to @bold{2} bindings.

@minted-file-part["racket" "p5g" hw-file]

And finally using that, we can run the same verification as before:

@minted-file-part["racket" "p5h" hw-file]