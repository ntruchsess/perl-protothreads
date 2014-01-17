package ProtoThreads;

use strict;
use warnings;
use ProtoThreads;

my $continue = time+3;

my $text = "test";
my $start = time;

my $child=PT_THREAD(sub {
  my $thread = shift;
  PT_BEGIN($thread);
  print time-$start." childthread of $text\n";
  PT_END;
});

sub thread(@) { 
  my ($thread,$mode) = @_;
  PT_BEGIN($thread);
  print time-$start." thread-$mode first\n";
  PT_YIELD;
  print time-$start." thread-$mode second\n";
  PT_YIELD_UNTIL(($continue - time)<0);
  print time-$start." thread-$mode third\n";
  if ($mode == 1) {
    PT_EXIT;
  };
  if ($mode == 2) {
    $text = "thread-2";
    PT_SPAWN($child);
  };
  if ($mode == 3) {
    $thread->{numruns} = 0 unless defined $thread->{numruns};
    $thread->{numruns}++;
    print time-$start." thread-$mode run: $thread->{numruns}\n";
    if ($thread->{numruns} < 3) {
      $continue = time+2;
      PT_RESTART;
    } 
  }
  print time-$start." thread-$mode forth\n";
  PT_END;
};

my $thread1 = PT_THREAD(\&thread);
my $thread2 = PT_THREAD(\&thread);
my $thread3 = PT_THREAD(\&thread);

my $running1 = 1;
my $running2 = 1;
my $running3 = 1;

do {
  $running1 = $thread1->PT_SCHEDULE(1) if $running1; 
  $running2 = $thread2->PT_SCHEDULE(2) if $running2; 
  $running3 = $thread3->PT_SCHEDULE(3) if $running3; 
} while ($running1 || $running2 || $running3);
1;
