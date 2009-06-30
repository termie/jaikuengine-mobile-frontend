package DJabberd::AWS::AsyncHTTP;
use DJabberd::DNS;
use URI;
use strict;
use fields qw(response_data dns request cb connection uri);

sub new {
    my ($class, $request, $cb) = @_;
    my $uri=URI->new($request->uri);
    $request->protocol("HTTP/1.1");
    $request->init_header('Host' => $uri->host);
    $request->init_header('Connection' => 'close');

    my $content=$request->content;
    $request->content($content);

    my $len=length($content);
    $request->init_header('Content-Length' => $len);
    $request->init_header('User-Agent' => 'libwww-perl/5.805');

    #print "Sending: " . $request->as_string . "\n";

    my $host=$uri->host;
    my $port=$uri->port;

    my $self=fields::new($class);

    my $dns=new DJabberd::DNS(hostname=>$host, port=>$port, callback=>
        sub { $self->connect(@_); });

    $self->{dns}=$dns;
    $self->{request}=$request;
    $self->{cb}=$cb;
    $self->{uri}=$uri;

    return $self;
}

sub connect {
    my $self=shift;
    my $endpoint=shift;
    die "DNS lookup failed " unless($endpoint);
    my $connection=Connection->new($endpoint, $self->{request}, $self->{cb}, $self->{uri});
}

1;

package Connection;
use base 'Danga::Socket';
use fields qw(request headers data cb state ssl write_when_readable uri response body remain_in_chunk chunked length);
use HTTP::Response;
use IO::Handle;
use Socket;
use DJabberd::Stanza::StartTLS;
 
use constant POLLIN        => 1;
use constant POLLOUT       => 4;

sub new {
    my ($class, $endpoint, $request, $cb, $uri) = @_;

    my $sock;
    my $proto = getprotobyname('tcp');
    socket $sock, PF_INET, SOCK_STREAM, $proto;
    unless ($sock && defined fileno($sock)) {
        die "Cannot alloc socket";
        return;
    }
    my $ip=$endpoint->addr;
    connect $sock, Socket::sockaddr_in($endpoint->port, Socket::inet_aton($ip));
    IO::Handle::blocking($sock, 0);

    my $self = $class->SUPER::new($sock);
    $self->watch_write(1);
    $self->{request}=$request;
    $self->{headers}='';
    $self->{cb}=$cb;
    $self->{uri}=$uri;
    $self->{body}='';

    $self->{state}="connecting";

    return $self;
}

sub event_read {
    my Connection $self = shift;
    # for async SSL:  if a session renegotation is in progress,
    # our previous write wants us to become readable first.
    # we then go back into the write path (by flushing the write
    # buffer) and it then does a read on this socket.
    #warn "event_read\n";
    if (my $ar = $self->{write_when_readable}) {
        $self->{write_when_readable} = 0;
        $self->watch_read($ar->[0]);  # restore previous readability state
        $self->watch_write(1);
        return;
    }
    #warn "got some data\n";

    my $bref;
    if (my $ssl = $self->{ssl}) {
        my $data = Net::SSLeay::read($ssl);

        my $errs = Net::SSLeay::print_errs('SSL_read');
        if ($errs) {
            warn "SSL Read error: $errs\n";
            $self->close;
            return;
        }

        # Net::SSLeays buffers internally, so if we didn't read anything, it's
        # in its buffer
        return unless $data && length $data;
        $bref = \$data;
    } else {
        # non-ssl mode:
        $bref = $self->read(20_000);
    }
    return $self->close unless defined $bref;
    #print "read $$bref\n";

    unless (defined($self->{data})) {
        if ($$bref=~/(.*?\r?\n\r?\n)(.*)/s) {
            #warn "found end of headers";
            $self->{headers} .= $1;
            $self->{data} = $2;
            my $resp=HTTP::Response->parse($self->{headers});
            $self->{response}=$resp;
            if ($resp->headers->header('Transfer-Encoding')=~/chunked/i) {
                $self->{chunked}=1;
                $self->{remain_in_chunk}=0;
            } elsif (my $len=$resp->headers->header('Content-Length')) {
                $self->{length}=$len;
                if ($len==0) {
                    $self->done;
                    return;
                }
            }
            $self->parse_body;
        } else {
            $self->{headers} .= $$bref;
        }
    } else {
        $self->{data} .= $$bref;
        $self->parse_body;
    }
}

sub parse_body {
    my $self=shift;
    if ($self->{chunked}) {
        my $remaining=$self->{remain_in_chunk};
        while ( length($self->{data}) ) {
            #print STDERR "\nPARSING remaining $remaining data " . $self->{data} . "\n";
            die "cannot parse chunked" if ($remaining<0);
            if ($remaining) {
                my $data=$self->{data};
                my $append=substr($data, 0, $remaining);
                #print STDERR "APPEND: $append\n";
                $self->{body} .= $append;
                $self->{remain_in_chunk}-= length($append);
                substr($data, 0, length($append))='';
                $self->{data}=$data;
            }
            if ($self->{remain_in_chunk}==0 && length($self->{data})) {
                $self->{data}=~/^\r?\n?([0-9a-f]+[^\n]*)\r?\n(.*)/si || last;
                my $rest=$2;
                my $len="0x" . $1;
                my $len=oct($len); 
                if ($len==0) {
                    #print STDERR "LEN 0\n";
                    $self->done;
                    last;
                }
                $self->{remain_in_chunk}=$len;
                $self->{data}=$rest;
            }
            $remaining=$self->{remain_in_chunk};
        }
    } elsif(my $len=$self->{length}) {
        if (length($self->{data})==$len) {
            $self->{body}=$self->{data};
            $self->done;
        }
    } else {
        $self->{body} .= $self->{data};
        $self->{data}='';
    }
}

sub done {
    my $self=shift;
    return unless ($self->{cb});

    #print STDERR "DONE :" . $self->{body} . "\n";

    $self->{response}->content($self->{body});

    #print "Content-length: " . $resp->header('Content-length') . "\n";
    #print "Length of data: " . length($self->{data}) . "\n";

    $self->{cb}->($self->{response});
    $self->{cb}=undef;

    #$self->write("GET / HTTP/1.1\r\nConnection: close\r\n\r\n");
}

sub close {
    my Connection $self = shift;
    my $resp;

    if ($self->{cb}) { $self->done; }

    if (my $ssl = $self->{ssl}) {
        Net::SSLeay::free($ssl);
        $self->{ssl} = undef;
    }

    $self->SUPER::close;

    #warn "closed\n";
}

sub event_err {
    #warn "event_err\n";
    $_[0]->close;
}

sub event_write {
    my Connection $self = shift;

    if ($self->{state} eq "connecting") {
        $self->{state}="connected";
        $self->on_connected;
    } else {
        if ($self->write(undef)) {
            $self->watch_write(0);
            if ($self->{ssl}) {
                Net::SSLeay::shutdown($self->{ssl});
            } else {
                CORE::shutdown $self->{sock}->fileno, 1;
            } 
        }    
    }
}

use Devel::Peek;
sub on_connected {
    my Connection $self = shift;

    if ($self->{uri}->scheme eq "https") {
        $self->setup_ssl;
    }
    # note that we must request watch_read() before
    # attempting to write, so that the request is remembered
    # when the SSL handshake ends
    $self->watch_read(1);
    my $content=$self->{request}->content || "";
    $self->{request}->content('');

    #print STDERR "CONTENT " . Dump($content) . "\n";

    my $to_write= $self->{request}->as_string("\r\n");
    utf8::decode($to_write);
    $to_write .= $content;
    #print STDERR "SENDING |$to_write|\n";
    $self->write($to_write);
}

sub setup_ssl {
    my Connection $self = shift;

    my $ctx = Net::SSLeay::CTX_new()
        or die("Failed to create SSL_CTX $!");

    $Net::SSLeay::ssl_version = 10; # Insist on TLSv1
    Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
        and Net::SSLeay::die_if_ssl_error("ssl ctx set options");

    Net::SSLeay::CTX_set_mode($ctx, 1)  # enable partial writes
        and Net::SSLeay::die_if_ssl_error("ssl ctx set options");

    my $ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
    $self->{ssl} = $ssl;

    my $fileno = $self->{sock}->fileno;
    warn "setting ssl ($ssl) fileno to $fileno\n";
    Net::SSLeay::set_fd($ssl, $fileno);

    $Net::SSLeay::trace = 2;

    my $rv = Net::SSLeay::connect($ssl);
    if (!$rv) {
        warn "SSL accept error on $self\n";
        $self->close;
        return;
    }

    #warn "$self:  Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";

    $self->set_writer_func(DJabberd::Stanza::StartTLS->danga_socket_writerfunc($self));
}

# called by Danga::Socket when a write doesn't fully go through.  by default it
# enables writability.  but we want to do nothing if we're waiting for a read for SSL
sub on_incomplete_write {
    my $self = shift;
    return if $self->{write_when_readable};
    $self->SUPER::on_incomplete_write;
}

# called by SSL machinery to let us know a write is stalled on readability.
# so we need to (at least temporarily) go readable and then process writes.
sub write_when_readable {
    my $self = shift;
    #warn "write_when_readable\n";

    # enable readability, but remember old value so we can pop it back
    my $prev_readable = ($self->{event_watch} & POLLIN)  ? 1 : 0;
    $self->watch_read(1);
    $self->{write_when_readable} = [ $prev_readable ];

    # don't need to push/pop its state because Danga::Socket->write, called later,
    # will do the one final write, or if not all written, will turn on watch_write
    $self->watch_write(0);
}


1;
