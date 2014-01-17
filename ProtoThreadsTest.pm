package ProtoThreads;

use pthreads;

my $continue = time+5;

my $text = "test";

my $subthread=PT_THREAD(sub {
  my $thread = shift;
  PT_BEGIN($thread);
  print "subthread $text\n";
  PT_END;
});

my $thread = PT_THREAD(sub { 
    my $thread = shift;
    my $mode = shift;
    PT_BEGIN($thread);
    print "first\n";
    PT_YIELD;
    print "second\n";
    PT_YIELD_UNTIL(($continue - time)<0);
    print "third\n";
    if ($mode == 1) {
      PT_EXIT;
    };
    if ($mode == 2) {
      PT_SPAWN($subthread);
    };
    if ($mode == 3) {
      $thread->{numruns} = 0 unless defined $thread->{numruns};
      $thread->{numruns}++;
      print "run: $thread->{numruns}\n";
      if ($thread->{numruns} <= 3) {
        PT_RESTART($thread);
      } 
    }
    print "forth\n";
    PT_END;
  }
);

my $print = time+1;

my $val;
my $state = $thread->{PT_THREAD_STATE};
print "with break:\n";
while ($thread->PT_SCHEDULE(1)) {
  print "$thread->{PT_THREAD_STATE}\n" unless ($state eq $thread->{PT_THREAD_STATE});
  $state = $thread->{PT_THREAD_STATE};
};
print "with subthread\n";
while ($thread->PT_SCHEDULE(2)) {
  print "$thread->{PT_THREAD_STATE}\n" unless ($state eq $thread->{PT_THREAD_STATE});
  $state = $thread->{PT_THREAD_STATE};
};
print "with restart\n";
while ($thread->PT_SCHEDULE(3)) {
  print "$thread->{PT_THREAD_STATE}\n" unless ($state eq $thread->{PT_THREAD_STATE});
  $state = $thread->{PT_THREAD_STATE};
};

1;

#void PT_INIT(struct pt *pt);
#Initialize a protothread.
#
#void PT_BEGIN(struct pt *pt);
#Declare the start of a protothread inside the C function implementing the protothread.
#
#void PT_WAIT_UNTIL(struct pt *pt, condition);
#Block and wait until condition is true.
#
#void PT_WAIT_WHILE(struct pt *pt, condition);
#Block and wait while condition is true.
#
#void PT_WAIT_THREAD(struct pt *pt, thread);
#Block and wait until a child protothread completes.
#
#void PT_SPAWN(struct pt *pt, struct pt *child, thread);
#Spawn a child protothread and wait until it exits.
#
#void PT_RESTART(struct pt *pt);
#Restart the protothread.
#
#void PT_EXIT(struct pt *pt);
#Exit the protothread.
#
#void PT_END(struct pt *pt);
#Declare the end of a protothread.
#
#int PT_SCHEDULE(protothread);
#Schedule a protothread.
#
#void PT_YIELD(struct pt *pt);
#Yield from the current protothread.
#-----------------------------------
