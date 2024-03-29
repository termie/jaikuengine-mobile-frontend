# $Id: FollowTail.pm 2160 2006-12-31 21:35:35Z rcaputo $

package POE::Wheel::FollowTail;

use strict;

use vars qw($VERSION);
$VERSION = do {my($r)=(q$Revision: 2160 $=~/(\d+)/);sprintf"1.%04d",$r};

use Carp qw( croak carp );
use Symbol qw( gensym );
use POSIX qw(SEEK_SET SEEK_CUR SEEK_END);
use POE qw(Wheel Driver::SysRW Filter::Line);
use IO::Handle ();

sub CRIMSON_SCOPE_HACK ($) { 0 }

sub SELF_HANDLE      () {  0 }
sub SELF_FILENAME    () {  1 }
sub SELF_DRIVER      () {  2 }
sub SELF_FILTER      () {  3 }
sub SELF_INTERVAL    () {  4 }
sub SELF_EVENT_INPUT () {  5 }
sub SELF_EVENT_ERROR () {  6 }
sub SELF_EVENT_RESET () {  7 }
sub SELF_UNIQUE_ID   () {  8 }
sub SELF_STATE_READ  () {  9 }
sub SELF_LAST_STAT   () { 10 }
sub SELF_FOLLOW_MODE () { 11 }

sub MODE_TIMER  () { 0x01 } # Follow on a timer loop.
sub MODE_SELECT () { 0x02 } # Follow via select().

# Turn on tracing.  A lot of debugging occurred just after 0.11.
sub TRACE_RESET        () { 0 }
sub TRACE_STAT         () { 0 }
sub TRACE_STAT_VERBOSE () { 0 }
sub TRACE_POLL         () { 0 }

# Tk doesn't provide a SEEK method, as of 800.022
BEGIN {
  if (exists $INC{'Tk.pm'}) {
    eval <<'    EOE';
      sub Tk::Event::IO::SEEK {
        my $o = shift;
        $o->wait(Tk::Event::IO::READABLE);
        my $h = $o->handle;
        sysseek($h, shift, shift);
      }
    EOE
  }
}

#------------------------------------------------------------------------------

sub new {
  my $type = shift;
  my %params = @_;

  croak "wheels no longer require a kernel reference as their first parameter"
    if @_ and (ref($_[0]) eq 'POE::Kernel');

  croak "$type requires a working Kernel" unless (defined $poe_kernel);

  croak "FollowTail requires a Handle or Filename parameter, but not both"
    unless $params{Handle} xor defined $params{Filename};

  my $driver = delete $params{Driver};
  $driver = POE::Driver::SysRW->new() unless defined $driver;

  my $filter = delete $params{Filter};
  $filter = POE::Filter::Line->new() unless defined $filter;

  croak "InputEvent required" unless defined $params{InputEvent};

  my $handle   = $params{Handle};
  my $filename = $params{Filename};

  if (defined $filename) {
    $handle = _open_file($filename);
  }

  my @start_stat;
  @start_stat = stat($filename) if defined $handle;

  my $poll_interval = (
    defined($params{PollInterval})
    ?  $params{PollInterval}
    : 1
  );

  my $seek;
  if (exists $params{SeekBack}) {
    $seek = $params{SeekBack} * -1;
    if (exists $params{Seek}) {
      croak "can't have Seek and SeekBack at the same time";
    }
  }
  elsif (exists $params{Seek}) {
    $seek = $params{Seek};
  }
  else {
    $seek = -4096;
  }

  my $self = bless [
    $handle,                          # SELF_HANDLE
    $filename,                        # SELF_FILENAME
    $driver,                          # SELF_DRIVER
    $filter,                          # SELF_FILTER
    $poll_interval,                   # SELF_INTERVAL
    delete $params{InputEvent},       # SELF_EVENT_INPUT
    delete $params{ErrorEvent},       # SELF_EVENT_ERROR
    delete $params{ResetEvent},       # SELF_EVENT_RESET
    &POE::Wheel::allocate_wheel_id(), # SELF_UNIQUE_ID
    undef,                            # SELF_STATE_READ
    \@start_stat,                     # SELF_LAST_STAT
    undef,                            # SELF_FOLLOW_MODE
  ], $type;

  # We couldn't open a file.  SeekBack won't be used because it
  # assumes the file already exists.  If you need more complex
  # seeking, consider opening and seeking yourself.  In fact, the
  # whole SeekBack concept should be deprecated as it only opens a can
  # full of arbitrarily complex worms.  Maybe later.

  unless (defined $handle) {
    carp "FollowTail does not support SeekBack on nonexistent files"
      if defined $params{SeekBack};

    $self->[SELF_FOLLOW_MODE] = MODE_TIMER;
    $self->_define_timer_states();

    return $self;
  }

  # Strange things that ought not be tailed?  Directories...

  if (-d $handle) {
    croak "FollowTail does not tail directories";
  }

  # SeekBack only works with plain files.  We won't honor SeekBack,
  # and we will use select_read to watch the handle rather than the
  # polling interval.

  unless (-f $handle) {
    carp "FollowTail does not support SeekBack on a special file"
      if defined $params{SeekBack};
    carp "FollowTail does not need PollInterval for special files"
      if defined $params{PollInterval};

    # Start the select loop.
    $self->[SELF_FOLLOW_MODE] = MODE_SELECT;
    $self->_define_select_states();

    return $self;
  }

  # We only get this far with plain files that have successfully been
  # opened at the time the wheel is created.  SeekBack and
  # partial-input discarding work here.
  #
  # SeekBack attempts to position the file pointer somewhere before
  # the end of the file.  If it's specified, we assume the user knows
  # where a record begins.  Otherwise we just seek back and discard
  # everything to EOF so we can frame the input record.

  my $end = sysseek($handle, 0, SEEK_END);

  # Seeking back from EOF.
  if ($seek < 0) {
    if (defined($end) and ($end < -$seek)) {
      sysseek($handle, 0, SEEK_SET);
    }
    else {
      sysseek($handle, $seek, SEEK_END);
    }
  }

  # Seeking forward from the beginning of the file.
  elsif ($seek > 0) {
    if ($seek > $end) {
      sysseek($handle, 0, SEEK_END);
    }
    else {
      sysseek($handle, $seek, SEEK_SET);
    }
  }

  # If they set Seek to 0, we start at the beginning of the file.
  # If it was SeekBack, we start at the end.
  elsif (exists $params{Seek}) {
    sysseek($handle, 0, SEEK_SET);
  }
  elsif (exists $params{SeekBack}) {
    sysseek($handle, 0, SEEK_END);
  }
  else {
    die;  # Should never happen.
  }

  # Discard partial input chunks unless a SeekBack was specified.
  unless (defined $params{SeekBack} or defined $params{Seek}) {
    while (defined(my $raw_input = $driver->get($handle))) {
      # Skip out if there's no more input.
      last unless @$raw_input;
      $filter->get($raw_input);
    }
  }

  # Start the timer loop.
  $self->[SELF_FOLLOW_MODE] = MODE_TIMER;
  $self->_define_timer_states();

  return $self;
}

### Define the select based polling loop.  This relies on stupid
### closure tricks to keep references to $self out of anonymous
### coderefs.  Otherwise a circular reference would occur, and the
### wheel would never self-destruct.

sub _define_select_states {
  my $self = shift;

  my $filter      = $self->[SELF_FILTER];
  my $driver      = $self->[SELF_DRIVER];
  my $handle      = $self->[SELF_HANDLE];
  my $unique_id   = $self->[SELF_UNIQUE_ID];
  my $event_input = \$self->[SELF_EVENT_INPUT];
  my $event_error = \$self->[SELF_EVENT_ERROR];
  my $event_reset = \$self->[SELF_EVENT_RESET];

  TRACE_POLL and warn "<poll> defining select state";

  $poe_kernel->state(
    $self->[SELF_STATE_READ] = ref($self) . "($unique_id) -> select read",
    sub {

      # Protects against coredump on older perls.
      0 && CRIMSON_SCOPE_HACK('<');

      # The actual code starts here.
      my ($k, $ses) = @_[KERNEL, SESSION];

      eval {
        sysseek($handle, 0, SEEK_CUR);
      };
      $! = 0;

      TRACE_POLL and warn "<poll> " . time . " read ok";

      if (defined(my $raw_input = $driver->get($handle))) {
        if (@$raw_input) {
          TRACE_POLL and warn "<poll> " . time . " raw input";
          foreach my $cooked_input (@{$filter->get($raw_input)}) {
            TRACE_POLL and warn "<poll> " . time . " cooked input";
            $k->call($ses, $$event_input, $cooked_input, $unique_id);
          }
        }
      }

      # Error reading.  Report the error if it's not EOF, or if it's
      # EOF on a socket or TTY.  Shut down the select, too.
      else {
        if ($! or (-S $handle) or (-t $handle)) {
          TRACE_POLL and warn "<poll> " . time . " error: $!";
          $$event_error and
            $k->call($ses, $$event_error, 'read', ($!+0), $!, $unique_id);
          $k->select($handle);
        }
        eval { IO::Handle::clearerr($handle) }; # could be a globref
      }
    }
  );

  $poe_kernel->select_read($handle, $self->[SELF_STATE_READ]);
}

### Define the timer based polling loop.  This also relies on stupid
### closure tricks.

sub _define_timer_states {
  my $self = shift;

  my $filter        = $self->[SELF_FILTER];
  my $driver        = $self->[SELF_DRIVER];
  my $unique_id     = $self->[SELF_UNIQUE_ID];
  my $poll_interval = $self->[SELF_INTERVAL];
  my $filename      = $self->[SELF_FILENAME];
  my $last_stat     = $self->[SELF_LAST_STAT];

  my $handle        = \$self->[SELF_HANDLE];
  my $event_input   = \$self->[SELF_EVENT_INPUT];
  my $event_error   = \$self->[SELF_EVENT_ERROR];
  my $event_reset   = \$self->[SELF_EVENT_RESET];

  $self->[SELF_STATE_READ] = ref($self) . "($unique_id) -> timer read";
  my $state_read    = \$self->[SELF_STATE_READ];

  TRACE_POLL and warn "<poll> defining timer state";

  $poe_kernel->state(
    $$state_read,
    sub {

      # Protects against coredump on older perls.
      0 && CRIMSON_SCOPE_HACK('<');

      # The actual code starts here.
      my ($k, $ses) = @_[KERNEL, SESSION];

      eval {
        if (defined $filename) {
          my @new_stat = stat($filename);

          TRACE_STAT_VERBOSE and do {
            my @test_new = @new_stat;   splice(@test_new, 8, 1, "(removed)");
            my @test_old = @$last_stat; splice(@test_old, 8, 1, "(removed)");
            warn "<stat> @test_new" if "@test_new" ne "@test_old";
          };

          if (@new_stat) {
            my $did_reset;

            # File shrank.  Consider it a reset.  Seek to the top of
            # the file.
            if ($new_stat[7] < $last_stat->[7]) {
              $did_reset = 1;
            }

            $last_stat->[7] = $new_stat[7];

            # Something fundamental about the file changed.  Reopen it.
            if (
              $new_stat[1] != $last_stat->[1] or # inode's number
              $new_stat[0] != $last_stat->[0] or # inode's device
              $new_stat[6] != $last_stat->[6] or # device type
              $new_stat[3] != $last_stat->[3]    # number of links
            ) {

              TRACE_STAT and do {
                warn "<stat> inode $new_stat[1] != old $last_stat->[1]\n"
                  if $new_stat[1] != $last_stat->[1];
                warn "<stat> inode device $new_stat[0] != old $last_stat->[0]\n"
                  if $new_stat[0] != $last_stat->[0];
                warn "<stat> device type $new_stat[6] != old $last_stat->[6]\n"
                  if $new_stat[6] != $last_stat->[6];
                warn "<stat> link count $new_stat[3] != old $last_stat->[3]\n"
                  if $new_stat[3] != $last_stat->[3];
                warn "<stat> file size $new_stat[7] < old $last_stat->[7]\n"
                  if $new_stat[7] < $last_stat->[7];
              };

              # The file may have rolled.  Try one more read before moving on.
              if (
                defined $$handle and
                defined(my $raw_input = $driver->get($$handle))
              ) {

                # First read the remainder of the file.
                # Got input.  Read a bunch of it, then poll again right away.
                if (@$raw_input) {
                  TRACE_POLL and warn "<poll> " . time . " raw input\n";
                  foreach my $cooked_input (@{$filter->get($raw_input)}) {
                    TRACE_POLL and warn "<poll> " . time . " cooked input\n";
                    $k->call($ses, $$event_input, $cooked_input, $unique_id);
                  }
                }
                $k->yield($$state_read) if defined $$state_read;
              }

              @$last_stat = @new_stat;
              close $$handle if defined $$handle;
              $$handle = _open_file($filename);

              $did_reset = 1;
            }

            if ($did_reset) {
              $$event_reset and $k->call($ses, $$event_reset, $unique_id);
              sysseek($$handle, 0, SEEK_SET);
            }
          }
        }
      };

      $! = 0;
      TRACE_POLL and warn "<poll> " . time . " read ok\n";

      # No open file.  Go around again.
      unless (defined $$handle) {
        $k->delay($$state_read, $poll_interval) if defined $$state_read;
      }

      # Got input.  Read a bunch of it, then poll again right away.
      elsif (defined(my $raw_input = $driver->get($$handle))) {
        if (@$raw_input) {
          TRACE_POLL and warn "<poll> " . time . " raw input\n";
          foreach my $cooked_input (@{$filter->get($raw_input)}) {
            TRACE_POLL and warn "<poll> " . time . " cooked input\n";
            $k->call($ses, $$event_input, $cooked_input, $unique_id);
          }
        }
        $k->yield($$state_read) if defined $$state_read;
      }

      # Got an error of some sort.
      else {
        TRACE_POLL and warn "<poll> " . time . " set delay\n";
        if ($!) {
          TRACE_POLL and warn "<poll> " . time . " error: $!\n";
          $$event_error and
            $k->call($ses, $$event_error, 'read', ($!+0), $!, $unique_id);
          $k->select($$handle);
        }
        $k->delay($$state_read, $poll_interval) if defined $$state_read;
        IO::Handle::clearerr($$handle);
      }
    }
  );

  # Fire up the loop.  The delay() aspect of the loop will prevent
  # duplicate events from being significant for long.
  $poe_kernel->delay($$state_read, 0);
}

#------------------------------------------------------------------------------

sub event {
  my $self = shift;
  push(@_, undef) if (scalar(@_) & 1);

  while (@_) {
    my ($name, $event) = splice(@_, 0, 2);

    if ($name eq 'InputEvent') {
      if (defined $event) {
        $self->[SELF_EVENT_INPUT] = $event;
      }
      else {
        carp "InputEvent requires an event name.  ignoring undef";
      }
    }
    elsif ($name eq 'ErrorEvent') {
      $self->[SELF_EVENT_ERROR] = $event;
    }
    elsif ($name eq 'ResetEvent') {
      $self->[SELF_EVENT_RESET] = $event;
    }
    else {
      carp "ignoring unknown FollowTail parameter '$name'";
    }
  }
}

#------------------------------------------------------------------------------

sub DESTROY {
  my $self = shift;

  # Remove our tentacles from our owner.
  $poe_kernel->select($self->[SELF_HANDLE]) if defined $self->[SELF_HANDLE];

  $poe_kernel->delay($self->[SELF_STATE_READ]);

  if ($self->[SELF_STATE_READ]) {
    $poe_kernel->state($self->[SELF_STATE_READ]);
    undef $self->[SELF_STATE_READ];
  }

  &POE::Wheel::free_wheel_id($self->[SELF_UNIQUE_ID]);
}

#------------------------------------------------------------------------------

sub ID {
  return $_[0]->[SELF_UNIQUE_ID];
}

sub tell {
  my $self = shift;
  return sysseek($self->[SELF_HANDLE], 0, SEEK_CUR);
}

sub _open_file {
  my $filename = shift;

  my $handle = gensym();

  # FIFOs (named pipes) are opened R/W so they don't report EOF.
  # Everything else is opened read-only.
  if (-p $filename) {
    return unless open($handle, "+<$filename");
  }
  else {
    return unless open($handle, "<$filename");
  }

  return $handle;
}

###############################################################################
1;

__END__

=head1 NAME

POE::Wheel::FollowTail - follow the tail of an ever-growing file

=head1 SYNOPSIS

  $wheel = POE::Wheel::FollowTail->new(
    Filename     => $file_name,                    # File to tail
    Driver       => POE::Driver::Something->new(), # How to read it
    Filter       => POE::Filter::Something->new(), # How to parse it
    PollInterval => 1,                  # How often to check it
    InputEvent   => $input_event_name,  # Event to emit upon input
    ErrorEvent   => $error_event_name,  # Event to emit upon error
    ResetEvent   => $reset_event_name,  # Event to emit on file reset
    SeekBack     => $offset,            # How far from EOF to start
    Seek         => $offset,            # How far from BOF to start
  );

  $wheel = POE::Wheel::FollowTail->new(
    Handle       => $open_file_handle,             # File to tail
    Driver       => POE::Driver::Something->new(), # How to read it
    Filter       => POE::Filter::Something->new(), # How to parse it
    PollInterval => 1,                  # How often to check it
    InputEvent   => $input_event_name,  # Event to emit upon input
    ErrorEvent   => $error_event_name,  # Event to emit upon error
    # No reset event available.
    SeekBack     => $offset,            # How far from EOF to start
    Seek         => $offset,            # How far from BOF to start
  );

  $pos = $wheel->tell();  # Get the current log position.

=head1 DESCRIPTION

FollowTail follows the end of an ever-growing file, such as a log of
system events.  It generates events for each new record that is
appended to its file.

This is a read-only wheel so it does not include a put() method.

=head1 CONSTRUCTOR

=over 

=item new

new() creates a new wheel, returning the wheels reference.

=back

=head1 PUBLIC METHODS

=over 2

=item event EVENT_TYPE => EVENT_NAME, ...

event() is covered in the POE::Wheel manpage.

FollowTail's event types are C<InputEvent>, C<ResetEvent>, and
C<ErrorEvent>.

=item ID

The ID method returns a FollowTail wheel's unique ID.  This ID will be
included in every event the wheel generates, and it can be used to
match events with the wheels which generated them.

=item tell

Returns where POE::Wheel::FollowTail is currently in the log file.
tell() may be useful for seeking back into a file when resuming
tailing.

  my $pos = $wheel->tell();

FollowTail generally reads ahead of the data it returns, so the file
position is not necessarily the point after the last record you have
received.

=back

=head1 EVENTS AND PARAMETERS

=over 2

=item Driver

Driver is a POE::Driver subclass that is used to read from and write
to FollowTail's filehandle.  It encapsulates the low-level I/O
operations needed to access a file so in theory FollowTail never needs
to know about them.

POE::Wheel::FollowTail uses POE::Driver::SysRW if one is not
specified.

=item Filter

Filter is a POE::Filter subclass that is used to parse input from the
tailed file.  It encapsulates the lowest level of a protocol so that
in theory FollowTail never needs to know about file formats.

POE::Wheel::FollowTail uses POE::Filter::Line if one is not
specified.

=item PollInterval

PollInterval is the amount of time, in seconds, the wheel will wait
before retrying after it has reached the end of the file.  This delay
prevents the wheel from going into a CPU-sucking loop.

=item Seek

The Seek parameter tells FollowTail how far from the start of the file
to start reading.  Its value is specified in bytes, and values greater
than the file's current size will quietly cause FollowTail to start
from the file's end.

A Seek parameter of 0 starts FollowTail at the beginning of the file.
A negative Seek parameter emulates SeekBack: it seeks backwards from
the end of the file.

Seek and SeekBack are mutually exclusive.  If Seek and SeekBack are
not specified, FollowTail seeks 4096 bytes back from the end of the
file and discards everything until the end of the file.  This helps
ensure that FollowTail returns only complete records.

When either Seek or SeekBack is specified, FollowTail begins returning
records from that position in the file.  It is possible that the first
record returned may be incomplete.  In files with fixed-length
records, it's possible to return entirely the wrong thing, all the
time.  Please be careful.

=item SeekBack

The SeekBack parameter tells FollowTail how far back from the end of
the file to start reading.  Its value is specified in bytes, and
values greater than the file's current size will quietly cause
FollowTail to start from the file's beginning.

A SeekBack parameter of 0 starts FollowTail at the end of the file.
It's recommended to omit Seek and SeekBack to start from the end of a
file.

A negative SeekBack parameter emulates Seek: it seeks forwards from
the start of the file.

Seek and SeekBack are mutually exclusive.  If Seek and SeekBack are
not specified, FollowTail seeks 4096 bytes back from the end of the
file and discards everything until the end of the file.  This helps
ensure that FollowTail returns only complete records.

When either Seek or SeekBack is specified, FollowTail begins returning
records from that position in the file.  It is possible that the first
record returned may be incomplete.  In files with fixed-length
records, it's possible to return entirely the wrong thing, all the
time.  Please be careful.

=item Handle

=item Filename

Either the Handle or Filename constructor parameter is required, but
you cannot supply both.

FollowTail can watch a file or device that's already open.  Give it
the open filehandle with its Handle parameter.

FollowTail can watch a file by name, given as the Filename parameter.
The named file does not need to exist.  FollowTail will wait for it to
appear.

This wheel can detect files that have been "reset".  That is, it can
tell when log files have been restarted due to a rotation or purge.
For FollowTail to do this, though, it requires a Filename parameter.
This is so FollowTail can reopen the file after it has reset.  See
C<ResetEvent> elsewhere in this document.

=item InputEvent

InputEvent contains the name of an event which is emitted for every
complete record read.  Every InputEvent event is accompanied by two
parameters.  C<ARG0> contains the record which was read.  C<ARG1>
contains the wheel's unique ID.

A sample InputEvent event handler:

  sub input_state {
    my ($heap, $input, $wheel_id) = @_[HEAP, ARG0, ARG1];
    print "Wheel $wheel_id received input: $input\n";
  }

=item ResetEvent

ResetEvent contains the name of an event that's emitted every time a
file is reset.

It's only available when watching files by name.  This is because
FollowTail must reopen the file after it has been reset.

C<ARG0> contains the FollowTail wheel's unique ID.

=item ErrorEvent

ErrorEvent contains the event which is emitted whenever an error
occurs.  Every ErrorEvent comes with four parameters:

C<ARG0> contains the name of the operation that failed.  This usually
is 'read'.  Note: This is not necessarily a function name.  The wheel
doesn't know which function its Driver is using.

C<ARG1> and C<ARG2> hold numeric and string values for C<$!>,
respectively.  Note: FollowTail knows how to handle EAGAIN, so it will
never return that error.

C<ARG3> contains the wheel's unique ID.

A sample ErrorEvent event handler:

  sub error_state {
    my ($operation, $errnum, $errstr, $wheel_id) = @_[ARG0..ARG3];
    warn "Wheel $wheel_id generated $operation error $errnum: $errstr\n";
  }

=back

=head1 SEE ALSO

POE::Wheel.

The SEE ALSO section in L<POE> contains a table of contents covering
the entire POE distribution.

=head1 BUGS

This wheel can't tail pipes and consoles on some systems.

=head1 AUTHORS & COPYRIGHTS

Please see L<POE> for more information about authors and contributors.

=cut
