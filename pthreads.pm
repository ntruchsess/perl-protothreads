package pthreads;

use constant {
  PT_WAITING => 0,
  PT_EXITED => 1,
  PT_ENDED => 2,
  PT_YIELDED => 3,
};

use Exporter 'import';
@EXPORT = qw(PT_WAITING PT_EXITED PT_ENDED PT_YIELDED);

use Text::Balanced qw (
  extract_codeblock
);

use Filter::Simple;

#    $_ = "use constant { PT_WAITING => 0, PT_EXITED => 1, PT_ENDED => 2, PT_YIELDED => 3 };
#".$_;

#    s/PT_BEGIN\(\$thread\);/PT_THREAD: { my \$PT_THREAD_STATE = \$thread->{state}; \$PT_THREAD_STATE eq 0 and do {/g;
#    s/PT_YIELD;/\$thread->{state} = __LINE__; return PT_YIELDED; }; \$PT_THREAD_STATE eq __LINE__ and do {/g;
#    s/PT_YIELD_UNTIL\(\$cond\)/\$thread->{state} = __LINE__; return PT_YIELDED; }; \$PT_THREAD_STATE eq __LINE__ and do { return PT_YIELDED unless (\$cond)/g;
#    s/PT_EXIT\(\$thread\)/}; \$thread->{state} = 0; return PT_EXITED; }/g;
#    print $_;

FILTER_ONLY
  code      => sub {
   
  my $code = $_;
  
  while(1) {
    my $thread = " - no PT_BEGIN before use of thread - ";
    if ($code =~ /PT_BEGIN\s*(?=\()/s) {
      if ($') {
        my $before = $`;
        my $after = $';
        my ($match,$remains,$prefix) = extract_codeblock($after,"()");
        print "PT_BEGIN match: $match\n";
        $match =~ /(^\()(.*(?=\)))(\)$)/;
        print "contains: $2\n" if $2;
        $thread = $2 if defined $2;
        $remains =~ s/^\s*;//sg;
        $code=$before."PT_THREAD: { my \$PT_THREAD_STATE = ".$thread."->{state}; \$PT_THREAD_STATE eq 0 and do {".$remains;
      }
      while (1) {
        if ($code =~ /PT_YIELD_UNTIL\s*(?=\()/s) {
          if ($') {
            my $before = $`;
            my $after = $';
            my ($match,$remains,$prefix) = extract_codeblock($after,"()");
            print "PT_YIELD_UNTIL match: $match\n";
            $match =~ /(^\()(.*(?=\)))(\)$)/;
            print "contains: $2\n" if $2;
            my $cond = $2 if defined $2;
            $remains =~ s/^\s*;//sg;
            $code=$before.$thread."->{state} = __LINE__; return PT_YIELDED; }; \$PT_THREAD_STATE eq __LINE__ and do { return PT_YIELDED unless ($cond);".$remains;
          }
          next;
        }
        if ($code =~ /PT_YIELD\s*;/s) {
          print "PT_YIELD match: $&\n";
          $code = $`.$thread."->{state} = __LINE__; return PT_YIELDED; }; \$PT_THREAD_STATE eq __LINE__ and do {".$';
          next;
        }
        if ($code =~ /PT_EXIT\s*;/s) {
          print "PT_EXIT match: $&\n";
          $code = $`."}; ".$thread."->{state} = 0; return PT_EXITED; }".$';
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