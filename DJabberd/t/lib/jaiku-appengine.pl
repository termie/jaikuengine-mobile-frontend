use FindBin qw($Bin);

BEGIN {
  # Pull in uninstalled modules from this directory tree so that we can work
  # with development versions easier.
  # Code copied from djabberd.pl
  opendir(my $dh, "$Bin/../../");
  foreach my $d (grep { /^DJabberd-/ || /^Jaiku-/ } readdir($dh)) {
    my $dir = "$Bin/../../$d/lib";
    if (-d $dir) {
      unshift(@INC, $dir);
    }
  }
}

use Carp;
use DJabberd::Jaiku::API;
use DJabberd::Jaiku::Authen;
use DJabberd::Jaiku::PresenceDb;
use Jaiku::Backend::API;
use Jaiku::MessageQueue::Client;
use Jaiku::Storage::API;

require "$Bin/../../DJabberd/t/lib/djabberd-test.pl";

$SIG{__WARN__} = sub { Carp::cluck(@_); };
$SIG{__DIE__} = sub { Carp::croak(@_); };

my $jaiku_api;

sub jaiku_plugins {
  my $jaiku = DJabberd::Jaiku::API->new();
  $jaiku->set_config_base_url('http://localhost:8080');
  $jaiku->set_config_consumer_key('ROOT_CONSUMER_KEY');
  $jaiku->set_config_consumer_secret('ROOT_CONSUMER_SECRET');
  $jaiku->set_config_token_key('ROOT_TOKEN_KEY');
  $jaiku->set_config_token_secret('ROOT_TOKEN_SECRET');
  return [
      $jaiku,
      DJabberd::Jaiku::Authen->new(),
      DJabberd::RosterStorage::InMemoryOnly->new(),
      DJabberd::Delivery::Local->new,
      DJabberd::Delivery::S2S->new,
      DJabberd::Jaiku::PresenceDb->new(),
  ];
}

{
  no warnings 'once';
  $Jaiku::MessageQueue::Client::g_poll_interval = 0.1;
  $Jaiku::Storatge::API::g_put_interval = 0.1;
  $Test::DJabberd::Server::PLUGIN_CB = sub {
    my $self = shift;
    my $ret = jaiku_plugins();
    return $ret;
  };
}

use Jaiku::API;
use LWP::UserAgent;
use URI;

my $cached_api;

sub get_jaiku_api {
  return $cached_api if ($cached_api);
  my $params = { };
  $params->{base_url} = new URI('http://localhost:8080');
  $params->{consumer_key} = 'ROOT_CONSUMER_KEY';
  $params->{consumer_secret} = 'ROOT_CONSUMER_SECRET';
  $params->{token_key} = 'ROOT_TOKEN_KEY';
  $params->{token_secret} = 'ROOT_TOKEN_SECRET';

  my $ua = LWP::UserAgent->new();
  $async_http = sub {
      my ($request, $callback) = @_;
      my $response = $ua->request($request);
      $callback->($response);
  };
  $params->{async_http} = $async_http;

  $cached_api = Jaiku::API->new(%$params);
  return $cached_api;
}

package Test::DJabberd::Client;
sub receive_filter_avatars {
  my ($pa, $timeout) = @_;
  my $xml;
  while ($xml = $pa->recv_xml($timeout)) {
    last unless($xml);
    if ($xml =~ /phonenumberisverified/) {
      if ($xml =~ /id>(\d+)<id/) {
        $pa->send_xml("<ack xmlns='http://www.cs.helsinki.fi/group/context'>$1</ack>");
      }
    } else {
      last;
    }
  }
  return $xml;
}

1;
