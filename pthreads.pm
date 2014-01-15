package pthreads;

use constant {
  PT_WAITING => 0,
  PT_EXITED => 1,
  PT_ENDED => 2,
  PT_YIELDED => 3,
};

use Filter::Util::Call;

sub import {
  my ($type) = @_;
  my ($ref) = [];
  filter_add(bless $ref);
}

sub filter {
  my ($self) = @_;
  my ($status);
  if (($status = filter_read()) > 0) {
    PARSE: {
      /PT_BEGIN\(\$thread\);/ and do {
        s/PT_BEGIN\(\$thread\);/PT_THREAD: { my \$PT_THREAD_STATE = \$thread->{state}; \$PT_THREAD_STATE eq 0 and do {/g;
        last;
      };
      /PT_YIELD;/ and do {
        s/PT_YIELD/\$thread->{state} = __LINE__; return PT_YIELDED; }; \$PT_THREAD_STATE eq __LINE__ and do {/g;
        last;
      };
      /PT_YIELD_UNTIL\(\$cond\)/ and do {
        s/PT_YIELD_UNTIL\(\$cond\)/\$thread->{state} = __LINE__; return PT_YIELDED; }; \$PT_THREAD_STATE eq __LINE__ and do { return PT_YIELDED unless (\$cond)/g;
        print $_;
        last;
      };
      /PT_EXIT\(\$thread\);/ and do {
        s/PT_EXIT\(\$thread\)/}; \$thread->{state} = 0; return PT_EXITED; }/g;
        last;
      };
    };
    print $_;
  };
  $status;
}
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