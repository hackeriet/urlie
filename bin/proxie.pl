#!/usr/bin/env perl

use strict;
use warnings;
use Config::File qw(read_config_file);
use POE qw( Component::IRC::State
  Component::IRC::Plugin::Proxy
  Component::IRC::Plugin::Connector );

my $configuration_file = "$ENV{HOME}/.urlierc";
my $config             = Config::File::read_config_file($configuration_file);

our $SERVER   = $config->{Server}{Host};
our $NICK     = $config->{Server}{Nick};
our $PORT     = $config->{Proxy}{Port};
our $PASSWORD = $config->{Proxy}{Password};

$0 = $NICK . '@' . $SERVER;

my $irc = POE::Component::IRC::State->spawn( plugin_debug => 1, );

POE::Session->create(
    package_states => [ main => [qw(_start)], ],
    heap           => { irc  => $irc },
);

$poe_kernel->run();

sub _start {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];

    $heap->{irc}->yield( register => 'all' );

    $heap->{proxy} = POE::Component::IRC::Plugin::Proxy->new(
        bindport => $PORT,
        password => $PASSWORD,
    );

    $heap->{irc}->plugin_add(
        'Connector' => POE::Component::IRC::Plugin::Connector->new() );

    $heap->{irc}->plugin_add( 'Proxy' => $heap->{proxy} );

    $heap->{irc}->yield( connect => { Nick => $NICK, Server => $SERVER } );

    return;
}

