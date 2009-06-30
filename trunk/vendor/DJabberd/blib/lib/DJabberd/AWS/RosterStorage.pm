package DJabberd::AWS::RosterStorage;

use strict;
use warnings;
use base 'DJabberd::RosterStorage';

use DJabberd::Log;
use DJabberd::RosterItem;
use Storable qw(freeze thaw);
our $logger = DJabberd::Log->get_logger();

sub finalize {
    my $self = shift;

    $self->{rosters} = {};
    # 'user@local' => {
    #   'contact@remote' => { rosteritem attribs },
    #   ...
    # }

    return $self;
}

sub blocking { 0 }

use Data::Dumper;
use Devel::Peek;
sub get_roster {
    my ($self, $cb, $jid) = @_;
    my $jidstr = $jid->as_bare_string;

    $logger->debug("Getting roster for '$jid'");

    my $prefix="roster/" . $jid->node;

    DJabberd::AWS::S3::gather($prefix, sub {
        my $results=shift;
        if (!$results) {
            return $cb->declined(shift());
        }
        my $roster = DJabberd::Roster->new;

        #print Dump($results);
        foreach my $value (values %{$results->{data}} ) {
            my $item=$value->{value};
            #print Dumper($item);
            $item=thaw($item);
            #print Dumper($item);
            if ($item) {
                eval {
                my $subscription = DJabberd::Subscription->from_bitmask($item->{subscription});
                $roster->add(DJabberd::RosterItem->new(%$item, subscription => $subscription));
                };
            }
        }

        $logger->debug("  ... got groups, calling set_roster..");

        $cb->set_roster($roster);
    });
}

sub set_roster_item {
    my ($self, $cb, $jid, $ritem) = @_;
    my $jidstr = $jid->as_bare_string;
    my $rjidstr = $ritem->jid->as_bare_string;

    my $item = {
        jid          => $rjidstr,
        name         => $ritem->name,
        groups       => [$ritem->groups],
        subscription => $ritem->subscription->as_bitmask,
    };

    my $key="roster/" . $jid->node . "/" . $rjidstr;
    my $data=freeze($item);
    #print STDERR "FROZEN1 " . Dump($data) . "\n";
    $logger->debug("putting $data\n");
    DJabberd::AWS::S3::put($key, $data, sub {
        my $ret=shift;
        if (!$ret) {
            return $cb->error(shift());
        }
        $logger->debug("Set roster item");
        $cb->done($ritem);
    });
}

sub addupdate_roster_item {
    my ($self, $cb, $jid, $ritem) = @_;
    my $jidstr = $jid->as_bare_string;
    my $rjidstr = $ritem->jid->as_bare_string;

    my $key="roster/" . $jid->node . "/" . $rjidstr;
    DJabberd::AWS::S3::get($key, sub {
        my $ret=shift;
        my $response=shift();
        if(!$ret && $response) {
            my $err='';
            $err=$response->as_string if ($response);
            $logger->warn("error in addupdate-get: " . $err);
            return $cb->error($err);
        }
        my $olditem;
        $olditem=thaw $ret->{value} if ($ret);

        my $newitem = $self->{rosters}->{$jidstr}->{$rjidstr} = {
            jid          => $rjidstr,
            name         => $ritem->name,
            groups       => [$ritem->groups],
        };

        if (defined $olditem) {
            $ritem->set_subscription(DJabberd::Subscription->from_bitmask($olditem->{subscription}));
            $newitem->{subscription} = $olditem->{subscription};
        }
        else {
            $newitem->{subscription} = $ritem->subscription->as_bitmask;
        }

        #print STDERR "FROZEN1 " . Dump(freeze($newitem)) . "\n";
        DJabberd::AWS::S3::put($key, freeze($newitem), sub {
            my $ret=shift;
            unless($ret) {
                return $cb->error(shift());
            }
            $cb->done($ritem);
        });
    });
    
}

sub delete_roster_item {
    my ($self, $cb, $jid, $ritem) = @_;
    $logger->debug("delete roster item!");

    my $jidstr = $jid->as_bare_string;
    my $rjidstr = $ritem->jid->as_bare_string;
    
    my $key="roster/" . $jid->node . "/" . $rjidstr;
    DJabberd::AWS::S3::delete($key, sub {
        my $result=shift;
        my $resp=shift;
        if (!$result) {
            $cb->error($resp);
        } else {
            $cb->done();
        }
    });
}

sub load_roster_item {
    my ($self, $jid, $contact_jid, $cb) = @_;

    my $jidstr = $jid->as_bare_string;
    my $cjidstr = $contact_jid->as_bare_string;
    my $key="roster/" . $jid->node . "/" . $cjidstr;
    
    DJabberd::AWS::S3::get($key, sub {
        my $ret=shift;
        unless (defined $ret) {
            return $cb->set(undef);
        }
        my $options=thaw $ret->{value};

        if ($options) {
            my $subscription = DJabberd::Subscription->from_bitmask($options->{subscription});

            my $item = DJabberd::RosterItem->new(%$options, subscription => $subscription);

            $cb->set($item);
        } else {
            $cb->set(undef);
        }
        return;
    });
}

sub wipe_roster {
    my ($self, $cb, $jid) = @_;

    my $jidstr = $jid->as_bare_string;

    delete $self->{rosters}->{$jidstr};

    $cb->done;
}

1;
