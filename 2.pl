#!/usr/bin/perl

use strict;
use warnings;

use Socket qw(IPPROTO_TCP TCP_NODELAY);
use IO::Socket::INET;

# 1
my $port = 9133;

# 2
my $server = IO::Socket::INET->new(
                                LocalPort => $port,
                                Listen    => 20,
                                Proto     => 'tcp',
                                Reuse     => 1,
                ) or die "Can't open socket: $!";
$server->setsockopt(IPPROTO_TCP, TCP_NODELAY, 1);

# 3
my $client = $server->accept();
$client->setsockopt(IPPROTO_TCP, TCP_NODELAY, 1);

# 4
send_raw( $client, "HTTP/1.1 200 OK\r\n",
                   "Content-Type: text/html; charset=utf-8\r\n",
                   "Transfer-Encoding: chunked\r\n",
                   "Connection: keep-alive\r\n",
                   "\r\n" );

# 5
send_raw( $client, "B\r\n", "hello world\r\n" );

# 6
send_raw( $client, "0\r\n", "\r\n" );

# 7
shutdown($client, 2);
close($client);


sub send_raw {
  my $socket = shift;

  foreach ( @_ ) {
    print $socket $_;
  }

  return;
}

