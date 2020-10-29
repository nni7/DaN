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
# т.е. никакой обработки запроса пока не делаю, этой программе достаточно 
# узнать по какому сокету выслать ответ.

# 4
print $client "HTTP/1.1 200 OK\r\n";
print $client "Content-Type: text/html; charset=utf-8\r\n";
print $client "Transfer-Encoding: chunked\r\n";
print $client "Connection: keep-alive\r\n";
print $client "\r\n";

# 5
print $client "B\r\n"; # B - это 11 в шестнадцатиричном формате
print $client "hello world\r\n";

# 6
print $client "0\r\n";
print $client "\r\n";

# 7
shutdown($client, 2);
close($client);

