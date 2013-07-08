  use strict;
  use lib '/home/cade/pro/perl-mods/';
  use Time::Progress;
  # autoflush to get \r working
  $| = 1;
  # get new `timer'
  my $p = new Time::Progress;

print $Time::Progress::VERSION, "\n";

  # restart and report progress
  $p->restart;
  sleep 1; # or do some work here
  print $p->report( "done %p elapsed: %10L (%10l sec), ETA %20E (%6e sec)\n", 50 );

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
