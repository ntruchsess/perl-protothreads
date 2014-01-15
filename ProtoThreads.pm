package ProtoThreads;

use strict;
use warnings;
use Template;

use constant {
  PT_WAITING => 0,
  PT_EXITED => 1,
  PT_ENDED => 2,
  PT_YIELDED => 3,
};

our %threads = ();

sub execute($$) {
  my ($thread,$cond) = @_;
  
  #PT_BEGIN($thread);
  PT_THREAD: { my $PT_THREAD_STATE = $thread->{state}; $PT_THREAD_STATE eq 0 and do {
      print "first\n";
    #PT_YIELD
    $thread->{state} = __LINE__; return PT_YIELDED; }; $PT_THREAD_STATE eq __LINE__ and do {
      print "second\n";
    #PT_YIELD_UNTIL($cond)
    $thread->{state} = __LINE__; return PT_YIELDED; }; $PT_THREAD_STATE eq __LINE__ and do { return PT_YIELDED unless ($cond);
      print "third\n";
    #PT_WAIT_UNTIL(pt, condition)
    $thread->{state} = __LINE__;}; $PT_THREAD_STATE eq __LINE__ and do { return PT_WAITING unless ($cond);
      print "third\n";
    #PT_WAIT_WHILE(pt, cond)
    $thread->{state} = __LINE__;}; $PT_THREAD_STATE eq __LINE__ and do { return PT_WAITING if ($cond);
      print "forth\n";
    #PT_WAIT_THREAD(pt, thread) PT_WAIT_WHILE((pt), PT_SCHEDULE(thread))      
    #$thread->{state} = __LINE__;}; $PT_THREAD_STATE eq __LINE__ and do { return PT_WAITING if (execute($thread) == PT_WAITING);
    #  print "fifth\n";
    #PT_EXIT($thread);
    }; $thread->{state} = 0; return PT_EXITED; };
};

#PI_INIT
my $thread = { state => 0 };
my $condition = 1;
my $continue = time+5;
my $print = time+1;

while (execute($thread,($continue - time)<0) ne PT_EXITED) { unless (($print-time) > 0) { print "$thread->{state}\n"; $print = time+1 };};

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