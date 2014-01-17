package pthreads;

use constant {
  PT_WAITING => 0,
  PT_EXITED => 1,
  PT_ENDED => 2,
  PT_YIELDED => 3,
};

use Exporter 'import';
@EXPORT = qw(PT_THREAD PT_WAITING PT_EXITED PT_ENDED PT_YIELDED PT_INIT PT_SCHEDULE);
@EXPORT_OK = qw();

use Text::Balanced qw (
  extract_codeblock
);

sub PT_THREAD($) {
  my $method = shift;
  return bless({
    PT_THREAD_STATE => 0,
    PT_THREAD_METHOD => $method 
  }, "pthreads");
}

sub PT_INIT($) {
  my $self = shift;
  $self->{PT_THREAD_STATE} = 0;
}

sub PT_SCHEDULE(@) {
  my ($self) = @_;
  my $state = $self->{PT_THREAD_METHOD}(@_); 
  return ($state == PT_WAITING or $state == PT_YIELDED);
}

sub PT_NEXTCOMMAND($$) {
  my ($code,$command) = @_;
  if ($code =~ /$command\s*(?=\()/s) {
    if ($') {
      my $before = $`;
      my $after = $';
      my ($match,$remains,$prefix) = extract_codeblock($after,"()");
#      $match =~ /(^\()(.*(?=\)))(\)$)/;
      $match =~ /(^\()(.*)(\)$)/;
      my $arg = $2 if defined $2;
      $remains =~ s/^\s*;//sg;
      return (1,$before,$arg,$remains);
    }
  }
  return undef;
}

use Filter::Simple;

#  #PT_BEGIN($thread);
#  my $PT_YIELD_FLAG = 1; goto $thread->{state} if $thread->{state};
#    print "first\n";
#  #PT_YIELD
#  $PT_YIELD_FLAG = 0; $thread->{state} = "PT1"; PT1: return PT_YIELDED unless $PT_YIELD_FLAG;
#    print "second\n";
#  #PT_YIELD_UNTIL($cond)
#  $PT_YIELD_FLAG = 0; $thread->{state} = "PT2"; PT2: return PT_YIELDED return PT_YIELDED unless ($PT_YIELD_FLAG and $cond);
#    print "third\n";
#  #PT_WAIT_UNTIL(pt, condition)
#  $thread->{state} = "PT3"; PT3: return PT_WAITING unless ($cond);
#    print "third\n";
#  #PT_WAIT_WHILE(pt, cond)
#  $thread->{state} = "PT4"; PT4: return PT_WAITING if ($cond);
#    print "forth\n";
#  #PT_WAIT_THREAD(pt, thread) PT_WAIT_WHILE((pt), PT_SCHEDULE(thread))      
#  #$thread->{state} = __LINE__;}; $PT_THREAD_STATE eq __LINE__ and do { return PT_WAITING if (execute($thread) == PT_WAITING);
#  #  print "fifth\n";
#  #PT_EXIT($thread);
#  $thread->{state} = ""; return PT_EXITED;

FILTER_ONLY
  code      => sub {
   
  my $code = $_;
  my $counter = 1;
  my ($success,$before,$arg,$after);
  
  while(1) {
    my $thread = " - no PT_BEGIN before use of thread - ";
    ($success,$before,$arg,$after) = PT_NEXTCOMMAND($code,"PT_RESTART");
    if ($success) {
      $code=$before.$arg."->{PT_THREAD_STATE}=0; return PT_WAITING;".$after;
      next;
    }
    ($success,$before,$arg,$after) = PT_NEXTCOMMAND($code,"PT_BEGIN");
    if ($success) {
      $thread = $arg;
      $code=$before."{ my \$PT_YIELD_FLAG = 1; goto ".$thread."->{PT_THREAD_STATE} if ".$thread."->{PT_THREAD_STATE};".$after;
      while (1) {
        ($success,$before,$arg,$after) = PT_NEXTCOMMAND($code,"PT_YIELD_UNTIL");
        if ($success) {
          $code=$before."\$PT_YIELD_FLAG = 0; ".$thread."->{PT_THREAD_STATE} = PT_LABEL_$counter; PT_LABEL_$counter: return PT_YIELDED unless (\$PT_YIELD_FLAG and $arg);".$after;
          $counter++;
          next;
        }
        if ($code =~ /PT_YIELD\s*;/s) {
          $code = $`."\$PT_YIELD_FLAG = 0; ".$thread."->{PT_THREAD_STATE} = PT_LABEL_$counter; PT_LABEL_$counter: return PT_YIELDED unless \$PT_YIELD_FLAG;".$';
          $counter++;
          next;
        }
        ($success,$before,$arg,$after) = PT_NEXTCOMMAND($code,"PT_WAIT_UNTIL");
        if ($success) {
          $code=$before.$thread."->{PT_THREAD_STATE} = PT_LABEL_$counter; PT_LABEL_$counter: return PT_WAITING unless ($arg);".$after;
          $counter++;
          next;
        }
        ($success,$before,$arg,$after) = PT_NEXTCOMMAND($code,"PT_WAIT_WHILE");
        if ($success) {
          print "wait_while: $arg\n";
          $code=$before.$thread."->{PT_THREAD_STATE} = PT_LABEL_$counter; PT_LABEL_$counter: return PT_WAITING if ($arg);".$after;
          $counter++;
          next;
        }
        ($success,$before,$arg,$after) = PT_NEXTCOMMAND($code,"PT_WAIT_THREAD");
        if ($success) {
          print "wait_thread: $arg\n";
          $code=$before."PT_WAIT_WHILE(PT_SCHEDULE(".$arg."));".$after;
          next;
        }
        ($success,$before,$arg,$after) = PT_NEXTCOMMAND($code,"PT_SPAWN");
        if ($success) {
          print "spawn: $arg\n";
          $code=$before.$arg."->{PT_THREAD_STATE} = 0; PT_WAIT_THREAD($arg);".$after;
          next;
        }
        if ($code =~ /PT_EXIT\s*;/s) {
          $code = $`.$thread."->{PT_THREAD_STATE} = 0; return PT_EXITED;".$';
          next;
        }
        if ($code =~ /PT_END\s*;/s) {
          $code = $`."} ".$thread."->{PT_THREAD_STATE} = 0; return PT_ENDED;".$';
        }
        last;
      }
      next;
    }
    last;
  };
  
  print $code;
  
  $_ = $code;
  
  };

1;

#typedef unsigned short lc_t;
#
##define LC_INIT(s) s = 0;
#
##define LC_RESUME(s) switch(s) { case 0:
#
##define LC_SET(s) s = __LINE__; case __LINE__:
#
##define LC_END(s) }
#
##endif /* __LC_SWITCH_H__ */
#
#struct pt {
#  lc_t lc;
#};
#
##define PT_INIT(pt)   LC_INIT((pt)->lc)
#
##define PT_THREAD(name_args) char name_args
#
##define PT_BEGIN(pt) { char PT_YIELD_FLAG = 1; LC_RESUME((pt)->lc)
#
##define PT_END(pt) LC_END((pt)->lc); PT_YIELD_FLAG = 0; \
#                   PT_INIT(pt); return PT_ENDED; }
#
##define PT_WAIT_UNTIL(pt, condition)	        \
#  do {						\
#    LC_SET((pt)->lc);				\
#    if(!(condition)) {				\
#      return PT_WAITING;			\
#    }						\
#  } while(0)
#
##define PT_WAIT_WHILE(pt, cond)  PT_WAIT_UNTIL((pt), !(cond))
#
##define PT_WAIT_THREAD(pt, thread) PT_WAIT_WHILE((pt), PT_SCHEDULE(thread))
#
##define PT_SPAWN(pt, child, thread)		\
#  do {						\
#    PT_INIT((child));				\
#    PT_WAIT_THREAD((pt), (thread));		\
#  } while(0)
#
##define PT_RESTART(pt)				\
#  do {						\
#    PT_INIT(pt);				\
#    return PT_WAITING;			\
#  } while(0)
#
##define PT_EXIT(pt)				\
#  do {						\
#    PT_INIT(pt);				\
#    return PT_EXITED;			\
#  } while(0)
#
##define PT_SCHEDULE(f) ((f) == PT_WAITING)
#
##define PT_YIELD(pt)				\
#  do {						\
#    PT_YIELD_FLAG = 0;				\
#    LC_SET((pt)->lc);				\
#    if(PT_YIELD_FLAG == 0) {			\
#      return PT_YIELDED;			\
#    }						\
#  } while(0)
#
##define PT_YIELD_UNTIL(pt, cond)		\
#  do {						\
#    PT_YIELD_FLAG = 0;				\
#    LC_SET((pt)->lc);				\
#    if((PT_YIELD_FLAG == 0) || !(cond)) {	\
#      return PT_YIELDED;			\
#    }						\
#  } while(0)
#
#  