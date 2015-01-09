use strict;
use warnings;

package IPC::Open3::Callback::CommandFailedException;

# ABSTRACT: An exception thrown when run_or_die encounters a failed command
# PODNAME: IPC::Open3::Callback::CommandFailedException

use overload q{""} => 'to_string', fallback => 1;
use parent qw(Class::Accessor);
__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_ro_accessors(qw(command exit_status out err));

sub new {
    my ($class, @args) = @_;
    return bless( {}, $class )->_init( @args );
}

sub _init {
    my ($self, $command, $exit_status, $out, $err) = @_;
    
    $self->{command} = $command;
    $self->{exit_status} = $exit_status;
    if ( defined( $out ) ) {
        $out =~ s/^\s+//;
        $out =~ s/\s+$//;
        $self->{out} = $out;
    }
    if ( defined( $err ) ) {
        $err =~ s/^\s+//;
        $err =~ s/\s+$//;
        $self->{err} = $err;
    }

    return $self;
}

sub to_string {
    my ($self) = @_;
    if ( !$self->{message} ) {
        my @message = ( 'FAILED (', $self->{exit_status}, '): ', 
            @{$self->{command}} );
        if ( $self->{out} ) {
            push( @message, "\n***** out *****\n", $self->{out}, "\n***** end out *****" );
        }
        if ( $self->{err} ) {
            push( @message, "\n***** err *****\n", $self->{err}, "\n***** end err *****" );
        }
        $self->{message} = join( '', @message );
    }
    return $self->{message};
}

1;

__END__
=head1 SYNOPSIS

  use IPC::Open3::Callback::CommandRunner;
  
  my $runner = IPC::Open3::Callback::CommandRunner->new();
  eval {
      $runner->run_or_die( 'echo Hello World' );
  };
  if ( $@ && ref( $@ ) eq 'IPC::Open3::Callback::CommandFailedException' ) {
      # gather info
      my $command = $@->get_command(); # an arrayref
      my $exit_status = $@->get_exit_status();
      my $out = $@->get_out();
      my $err = $@->get_err();
      
      # or just print 
      print( "$@\n" ); # includes all info
  }

=head1 DESCRIPTION

This provides a container for information obtained when a command fails.  The
C<command> and C<exit_status> will always be available, but C<out> and C<err>
will only be present if you supply the command option C<out_buffer =E<gt> 1> and
C<err_buffer =E<gt> 1> respectively.

=attribute get_command()

Returns a reference to the array supplied as the C<command> to command runner.

=attribute get_exit_status()

Returns the exit status from the attempt to run the command.

=attribute get_out()

Returns the text written to C<STDOUT> by the command.  Only present if 
C<out_buffer> was requested as a command runner option. 

=attribute get_err()

Returns the text written to C<STDERR> by the command.  Only present if 
C<err_buffer> was requested as a command runner option. 

=method to_string()

Returns a string representation of all of the attributes.  The C<qw{""}>
operator is overridden to call this method.

=head1 SEE ALSO
IPC::Open3::Callback
IPC::Open3::Callback::CommandRunner
https://github.com/lucastheisen/ipc-open3-callback

