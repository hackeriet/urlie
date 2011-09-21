#!/usr/bin/env perl
use strict;
use warnings;

use POE
  qw(Component::IRC  Component::IRC::Plugin::WWW::GetPageTitle  Component::IRC::Plugin::Connector);

our $CHAN   = '#oslohackerspace';
our $NICK   = 'urlie';
our $SERVER = 'irc.freenode.net';

$0 = $NICK . $CHAN . '@' . $SERVER;

my $irc = POE::Component::IRC->spawn(
    nick         => $NICK,
    server       => $SERVER,
    port         => 6667,
    ircname      => 'sjn owns this bot',
    plugin_debug => 1,
);

POE::Session->create( package_states => [ main => [qw(_start irc_001)], ], );

$poe_kernel->run;

sub _start {
    $irc->yield( register => 'all' );

    $irc->plugin_add(
        'Connector' => POE::Component::IRC::Plugin::Connector->new() );

    $irc->plugin_add(
        'get_page_title' => POE::Component::IRC::Plugin::WWW::GetPageTitle->new(
            auto           => 1,
            response_event => 'irc_get_page_title',
            response_types => {
                public  => 'notice',
                privmsg => 'privmsg',
                notice  => 'notice',
            },
            banned    => [],
            addressed => 0,
            triggers  => {
                public  => qr/^/i,
                notice  => qr/^/i,
                privmsg => qr/^/i,
            },
            listen_for_input => [qw(notice public privmsg)],
            eat              => 1,
            debug            => 1,
            max_uris         => 2,
            find_uris        => 1,
            addressed        => 0,
        )
    );

    $irc->yield( connect => {} );
}

sub irc_001 {
    $_[KERNEL]->post( $_[SENDER] => join => '#oslohackerspace' );
}

