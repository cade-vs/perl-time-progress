# NAME

Time::Progress - Elapsed and estimated finish time reporting.

# SYNOPSIS

    use Time::Progress;
    # autoflush to get \r working
    $| = 1;
    # get new `timer'
    my $p = Time::Progress->new;

    # restart and report progress
    $p->restart;
    sleep 5; # or do some work here
    print $p->report( "done %p elapsed: %L (%l sec), ETA %E (%e sec)\n", 50 );

    # set min and max values
    $p->attr( min => 2, max => 20 );
    # restart `timer'
    $p->restart;
    my $c;
    for( $c = 2; $c <= 20; $c++ )
      {
      # print progress bar and percentage done
      print $p->report( "eta: %E min, %40b %p\r", $c );
      sleep 1; # work...
      }
    # stop timer
    $p->stop;

    # report times
    print $p->elapsed_str;

# DESCRIPTION

Shortest time interval that can be measured is 1 second. The available methods are:

- new

    my $p = Time::Progress->new;

Returns new object of Time::Progress class and starts the timer. It
also sets min and max values to 0 and 100, so the next __report__ calls will
default to percents range.

- restart

restarts the timer and clears the stop mark. optionally restart() may act also
as attr() for setting attributes:

    $p->restart( min => 1, max => 5 );

is the same as:

    $p->attr( min => 1, max => 5 );
    $p->restart();

If you need to count things, you can set just 'max' attribute since 'min' is
already set to 0 when object is constructed by new():

    $p->restart( max => 42 );

- stop

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

- continue

Clears the stop mark. (mostly useless, perhaps you need to __restart__?)

- attr

Sets and returns internal values for attributes. Available attributes are:

    - min

    This is the min value of the items that will follow (used to calculate
    estimated finish time)

    - max

    This is the max value of all items in the even (also used to calculate
    estimated finish time)

    - format

    This is the default __report__ format. It is used if __report__ is called
    without parameters.

__attr__ returns array of the set attributes:

    my ( $new_min, $new_max ) = $p->attr( min => 1, max => 5 );

If you want just to get values use undef:

    my $old_format = $p->attr( format => undef );

This way of handling attributes is a bit heavy but saves a lot
of attribute handling functions. __attr__ will complain if you pass odd number
of parameters.

- report

__report__ is the most complex method in this package. :)

expected arguments are:

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

    estimated finish time in format returned by __localtime()__

        - %b
    - %B

    progress bar which looks like:

        ##############......................

    %b takes optional width:

        %40b -- 40-chars wide bar
        %9b  --  9-chars wide bar
        %b   -- 79-chars wide bar (default)

Parameters can be ommited and then default format set with __attr__ will
be used.

Sequences 'L', 'l', 'E' and 'e' can have width also:

    %10e
    %5l
    ...

Estimate time calculations can be used only if min and max values are set
(see __attr__ method) and current item is passed to __report__! if you want
to use the default format but still have estimates use it like this:

    $p->format( undef, 45 );

If you don't give current item (step) or didn't set proper min/max value
then all estimate sequences will have value \`n/a'.

You can freely mix reports during the same event.

- elapsed
- estimate

helpers -- return elapsed/estimate seconds.

- elapsed\_str
- estimate\_str

helpers -- return elapsed/estimated string in format:

    "elapsed time is MM:SS min.\n"
    "remaining time is MM:SS min.\n"

all helpers need one argument -- current item.

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

# GITHUB REPOSITORY

[https://github.com/cade-vs/perl-time-progress](https://github.com/cade-vs/perl-time-progress)



# AUTHOR

Vladi Belperchinov-Shabanski "Cade"

<cade@biscom.net> <cade@datamax.bg> <cade@cpan.org>

[http://cade.datamax.bg](http://cade.datamax.bg)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2001 by Vladi Belperchinov-Shabanski
<cade@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
