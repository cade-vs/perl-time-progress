# NAME

Time::Progress - Elapsed and estimated finish time reporting.

# SYNOPSIS

    use Time::Progress;

    my ($min, $max) = (0, 4);
    my $p = Time::Progress->new(min => $min, max => $max);

    for (my $c = $min; $c <= $max; $c++) {
      print STDERR $p->report("\r%20b  ETA: %E", $c);
      # do some work
    }
    print STDERR "\n";

# DESCRIPTION

This module displays progress information for long-running processes.
This can be percentage complete, time elapsed, estimated time remaining,
an ASCII progress bar, or any combination of those.

It is useful for code where you perform a number of steps,
or iterations of a loop,
where the number of iterations is known before you start the loop.

The typical usage of this module is:

- Create an instance of `Time::Progress`, specifying min and max count values.
- At the head of the loop, you call the `report()` method with
a format specifier and the iteration count,
and get back a string that should be displayed.

If you include a carriage return character (\\r) in the format string,
then the message will be over-written at each step.
Putting \\r at the start of the format string,
as in the SYNOPSIS,
results in the cursor sitting at the end of the message.

If you display to STDOUT, then remember to enable auto-flushing:

    use IO::Handle;
    STDOUT->autoflush(1);

The shortest time interval that can be measured is 1 second.

# METHODS

## new

    my $p = Time::Progress->new(%options);

Returns new object of Time::Progress class and starts the timer.
It also sets min and max values to 0 and 100,
so the next **report** calls will default to percents range.

You can configure the instance with the following parameters:

- min

    Sets the **min** attribute, as described in the `attr` section below.

- max

    Sets the **max** attribute, as described in the `attr` section below.

- smoothing

    If set to a true value, then the estimated time remaining is smoothed
    in a simplistic way: if the time remaining ever goes up, by less than
    10% of the previous estimate, then we just stick with the previous
    estimate. This prevents flickering estimates.
    By default this feature is turned off.

- smoothing\_delta

    Sets smoothing delta parameter. Default value is 0.1 (i.e. 10%).
    See 'smoothing' parameter for more details. 

## restart

Restarts the timer and clears the stop mark.
Optionally restart() may act also
as attr() for setting attributes:

    $p->restart( min => 1, max => 5 );

is the same as:

    $p->attr( min => 1, max => 5 );
    $p->restart();

If you need to count things, you can set just 'max' attribute since 'min' is
already set to 0 when object is constructed by new():

    $p->restart( max => 42 );

## stop

Sets the stop mark. This is only useful if you do some work, then finish,
then do some work that shouldn't be timed and finally report. Something
like:

    $p->restart;
    # do some work here...
    $p->stop;
    # do some post-work here
    print $p->report;
    # `post-work' will not be timed

Stop is useless if you want to report time as soon as work is finished like:

    $p->restart;
    # do some work here...
    print $p->report;

## continue

Clears the stop mark. (mostly useless, perhaps you need to **restart**?)

## attr

Sets and returns internal values for attributes. Available attributes are:

- min

    This is the min value of the items that will follow (used to calculate
    estimated finish time)

- max

    This is the max value of all items in the even (also used to calculate
    estimated finish time)

- format

    This is the default **report** format. It is used if **report** is called
    without parameters.

**attr** returns array of the set attributes:

    my ( $new_min, $new_max ) = $p->attr( min => 1, max => 5 );

If you want just to get values use undef:

    my $old_format = $p->attr( format => undef );

This way of handling attributes is a bit heavy but saves a lot
of attribute handling functions. **attr** will complain if you pass odd number
of parameters.

## report

This is the most complex method in this package :)

The expected arguments are:

    $p->report( format, [current_item] );

_format_ is string that will be used for the result string. Recognized
special sequences are:

- %l

    elapsed seconds

- %L

    elapsed time in minutes in format MM:SS

- %e

    remaining seconds

- %E

    remaining time in minutes in format MM:SS

- %p

    percentage done in format PPP.P%

- %f

    estimated finish time in format returned by **localtime()**

- %b
- %B

    progress bar which looks like:

        ##############......................

    %b takes optional width:

        %40b -- 40-chars wide bar
        %9b  --  9-chars wide bar
        %b   -- 79-chars wide bar (default)

- %s

    current speed in items per second

- %S

    current min/max speeds (calculated after first 1% of the progress)

Parameters can be omitted and then default format set with **attr** will
be used.

Sequences 'L', 'l', 'E' and 'e' can have width also:

    %10e
    %5l
    ...

Estimate time calculations can be used only if min and max values are set
(see **attr** method) and current item is passed to **report**! if you want
to use the default format but still have estimates use it like this:

    $p->format( undef, 45 );

If you don't give current item (step) or didn't set proper min/max value
then all estimate sequences will have value \`n/a'.

You can freely mix reports during the same event.

## elapsed($item)

Returns the time elapsed, in seconds.
This help function, and those described below,
take one argument: the current item number.

## estimate($item)

Returns an estimate of the time remaining, in seconds.

## elapsed\_str($item)

Returns elapsed time as a formatted string:

    "elapsed time is MM:SS min.\n"

## estimate\_str($item)

Returns estimated remaining time, as a formatted string:

    "remaining time is MM:SS min.\n"

# FORMAT EXAMPLES

    # $c is current element (step) reached
    # for the examples: min = 0, max = 100, $c = 33.3

    print $p->report( "done %p elapsed: %L (%l sec), ETA %E (%e sec)\n", $c );
    # prints:
    # done  33.3% elapsed time   0:05 (5 sec), ETA   0:07 (7 sec)

    print $p->report( "%45b %p\r", $c );
    # prints:
    # ###############..............................  33.3%

    print $p->report( "done %p ETA %f\n", $c );
    # prints:
    # done  33.3% ETA Sun Oct 21 16:50:57 2001

    print $p->report( "%30b %p %s/sec (%S) %L ETA: %E" );
    # ..............................   0.7% 924/sec (938/951)   1:13 ETA: 173:35

# SEE ALSO

The first thing you need to know about [Smart::Comments](https://metacpan.org/pod/Smart%3A%3AComments) is that
it was written by Damian Conway, so you should expect to be a little
bit freaked out by it. It looks for certain format comments in your
code, and uses them to display progress messages. Includes support
for progress meters.

[Progress::Any](https://metacpan.org/pod/Progress%3A%3AAny) separates the calculation of stats from the display
of those stats, so you can have different back-ends which display
progress is different ways. There are a number of separate back-ends
on CPAN.

[Term::ProgressBar](https://metacpan.org/pod/Term%3A%3AProgressBar) displays a progress meter to a standard terminal.

[Term::ProgressBar::Quiet](https://metacpan.org/pod/Term%3A%3AProgressBar%3A%3AQuiet) uses `Term::ProgressBar` if your code
is running in a terminal. If not running interactively, then no progress bar
is shown.

[Term::ProgressBar::Simple](https://metacpan.org/pod/Term%3A%3AProgressBar%3A%3ASimple) provides a simple interface where you
get a `$progress` object that you can just increment in a long-running loop.
It builds on `Term::ProgressBar::Quiet`, so displays nothing
when not running interactively.

[Term::Activity](https://metacpan.org/pod/Term%3A%3AActivity) displays a progress meter with timing information,
and two different skins.

[Text::ProgressBar](https://metacpan.org/pod/Text%3A%3AProgressBar) is another customisable progress meter,
which comes with a number of 'widgets' for display progress
information in different ways.

[ProgressBar::Stack](https://metacpan.org/pod/ProgressBar%3A%3AStack) handles the case where a long-running process
has a number of sub-processes, and you want to record progress
of those too.

[String::ProgressBar](https://metacpan.org/pod/String%3A%3AProgressBar) provides a simple progress bar,
which shows progress using a bar of ASCII characters,
and the percentage complete.

[Term::Spinner](https://metacpan.org/pod/Term%3A%3ASpinner) is simpler than most of the other modules listed here,
as it just displays a 'spinner' to the terminal. This is useful if you
just want to show that something is happening, but can't predict how many
more operations will be required.

[Term::Pulse](https://metacpan.org/pod/Term%3A%3APulse) shows a pulsed progress bar in your terminal,
using a child process to pulse the progress bar until your job is complete.

[Term::YAP](https://metacpan.org/pod/Term%3A%3AYAP) a fork of `Term::Pulse`.

[Term::StatusBar](https://metacpan.org/pod/Term%3A%3AStatusBar) is another progress bar module, but it hasn't
seen a release in the last 12 years.

# GITHUB REPOSITORY

    https://github.com/cade-vs/perl-time-progress
    
    git clone https://github.com/cade-vs/perl-time-progress

# AUTHOR

    Vladi Belperchinov-Shabanski "Cade"

    <cade@bis.bg> <cade@cpan.org>

    http://cade.datamax.bg

# COPYRIGHT AND LICENSE

This software is (c) 2001-2019 by Vladi Belperchinov-Shabanski <cade@bis.bg> <cade@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
