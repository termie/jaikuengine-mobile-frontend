package DJabberd::AWS::Authen;
use DJabberd::AWS::S3;
use strict;
use base 'DJabberd::Authen';
use Carp qw(croak);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new;
    $self->{_users} = {};  # username -> $password
    return $self;
}

sub can_register_jids { 1 }
sub can_unregister_jids { 1 }
sub can_retrieve_cleartext { 1 }

sub unregister_jid {
    my ($self, $cb, %args) = @_;
    my $user = $args{'username'};
    if (delete $self->{_users}{$user}) {
        $cb->deleted;
    } else {
        $cb->notfound;
    }
}

sub register_jid {
    my ($self, $cb, %args) = @_;
    my $user = DJabberd::AWS::S3::safe($args{'username'});
    my $pass = $args{'password'};
    my $key="users/$user/password";

    DJabberd::AWS::S3::get($key, sub {
        my $value=shift;
        my $response=shift;

        warn "register-get $value " . $value->{value} . ($response && $response->as_string) . "\n";
        if ($value->{value} || $response) {
            $cb->conflict;
        } else {
            DJabberd::AWS::S3::put($key, $pass, sub {
                my $ret=shift;
                my $response=shift;
                if ($ret) {
                    $cb->saved;
                } else {
                    $cb->error($response->as_string);
                }
            });
        }
    });
}

sub check_cleartext {
    my ($self, $cb, %args) = @_;
    my $user = DJabberd::AWS::S3::safe($args{'username'});
    my $key="users/$user/password";

    my $pass = $args{'password'};

    DJabberd::AWS::S3::get($key, sub {
        my $value=shift;
        my $response=shift;
        if (!$value || !$value->{value}) {
            return $cb->reject($response->as_string);
        } else {
            unless ($pass eq $value->{value}) {
                return $cb->reject;
            }
        }
        return $cb->accept;
    });
}

sub get_password {
    my ($self, $cb, %args) = @_;
    my $user = DJabberd::AWS::S3::safe($args{'username'});
    my $key="users/$user/password";
    DJabberd::AWS::S3::get($key, sub {
        my $value=shift;
        my $response=shift;
        if (!$value || ! $value->{value}) {
            return $cb->decline;
        } else {
            return $cb->set($value->{value});
        }
    });
}

1;
