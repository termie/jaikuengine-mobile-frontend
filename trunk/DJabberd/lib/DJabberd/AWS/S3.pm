package DJabberd::AWS::S3;
use DJabberd::AWS::Config;
use Net::Amazon::S3;
use DJabberd::AWS::AsyncHTTP;
use strict;

my $net_s3;
my $net_s3r;
my $bucket;
my $bucketr;
my $prefix;

use Devel::Peek;
sub async_http {
    my $request=shift;
    my $cb=shift;
    my $data=$request->content;

    #print STDERR "MESSAGE BODY " . Dump($data) . "\n";
    my $c=DJabberd::AWS::AsyncHTTP->new($request, $cb);
}

sub safe {
    return $_[0];
}

sub init {
    $net_s3 ||= Net::Amazon::S3->new( {
        aws_access_key_id => DJabberd::AWS::Config::access_key_id(),
        aws_secret_access_key => DJabberd::AWS::Config::secret_access_key(),
        async_http => \&async_http,
    });
    $net_s3r ||= Net::Amazon::S3->new( {
        aws_access_key_id => DJabberd::AWS::Config::access_key_id(),
        aws_secret_access_key => DJabberd::AWS::Config::secret_access_key(),
        async_http => \&async_http,
    });

    $bucket ||= $net_s3->bucket(DJabberd::AWS::Config::bucket());
    $bucketr ||= $net_s3r->bucket(DJabberd::AWS::Config::bucket());
    $prefix ||= DJabberd::AWS::Config::prefix();
}

sub put {
    init;

    my $key=shift;
    my $value=shift;
    my $cb=shift;

    $key = $prefix . "/" . $key;

    $bucket->add_key($key, $value, {}, $cb);
}

sub get {
    init;

    my $key=shift;
    my $cb=shift;

    $key = $prefix . "/" . $key;

    $bucketr->get_key($key, 'GET', $cb);
}

sub delete {
    init;

    my $key=shift;
    my $cb=shift;

    $key = $prefix . "/" . $key;

    $bucketr->delete_key($key, 'GET', $cb);
}


sub gather {
    init;

    my $subprefix=shift;
    my $cb=shift;

    my $results={ };

    my $fullprefix=$prefix . "/" . $subprefix;

    $bucketr->list( { prefix=>$fullprefix }, sub {
        my $response=shift;
        if (!$response) {
            return $cb->($response, shift());
        }
        my $count=$#{$response->{keys}}+1;
        $results->{want}=$count;
        $results->{data}={};
        if ($count==0) {
            return $cb->($results);
        }
        foreach my $key (@{$response->{keys}}) {
            #warn "getting $key\n";
            my $unprefix1=substr($key->{key}, length($prefix)+1);
            my $unprefix=substr($key->{key}, length($fullprefix)+1);
            get($unprefix1, sub {
                my $value=shift;
                #print Dumper($value);
                $results->{data}->{$unprefix}=$value;
                $results->{want}--;
                if ($results->{want}==0) {
                    $cb->($results);
                }
            });
        }
    });
}

1;
