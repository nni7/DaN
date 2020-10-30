#!/usr/bin/perl

use strict;
use warnings;

use IO::Socket::INET;
use Data::Dumper;

# 1
my $port = 9133;

# 2
my $server = get_server( $port );

while(1) {
  # 3
  my $client = get_client( $server );
  # 4
  send_header( $client );
  # 5
  send_data_chunked( $client, "hello world" );
  # 6
  send_finish( $client );
  # 7
  client_close( $client );
}


sub get_server {
  my $port = shift;

  my $server = IO::Socket::INET->new(
                                LocalPort => $port,
                                Listen    => 20,
                                Proto     => 'tcp',
                                Reuse     => 1,
                ) or die "Can't open socket: $!";

  return $server;
}

sub get_client {
  my $server = shift;

  my $client = $server->accept();
  return $client;
}

sub send_header {
  my $client = shift;

  send_data( $client, "HTTP/1.1 200 OK",
                      "Content-Type: text/html; charset=utf-8",
                      "Transfer-Encoding: chunked",
                      "Connection: keep-alive",
                      "" );
}

sub send_finish {
  my $client = shift;

  send_data_chunked( $client, "" );
}

sub client_close {
  my $client = shift;

  shutdown($client, 2);
  close($client);
}


sub send_raw {
  my $socket = shift;

  foreach ( @_ ) {
    print $socket $_;
  }

  return;
}


sub send_data {
  my $client = shift;

  @_ = map {
    $_ . "\r\n";
  } @_;

  send_raw( $client, @_ );
}


sub send_data_chunked {
  my $client = shift;

  @_ = map {
    my $len = sprintf("%X", length $_);
    $len, $_;
  } @_;

  send_data( $client, @_ );
}

