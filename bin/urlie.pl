#!/usr/bin/env perl

package POE::Component::IRC::Plugin::WWW::GetPageTitle::ToChannel;
use base 'POE::Component::IRC::Plugin::WWW::GetPageTitle';
use NEXT;

# Override the "public" command so it always sends a notice to the channel
sub S_public {
    my ( $self, $irc ) = splice @_, 0, 2;
    my $who     = ${ $_[1] }->[0];    # We reply to channel, not person
    my $channel = ${ $_[1] }->[0];
    my $message = ${ $_[2] };
    return $self->_parse_input( $irc, $who, $channel, $message, 'notice' );
}

package main;

use strict;
use warnings;
use Config::File qw(read_config_file);
use POE qw( Component::IRC
  Component::IRC::Plugin::WWW::GetPageTitle
  Component::IRC::Plugin::Connector );
use Data::Dumper::Concise;

my $DEBUG = 1;

my $configuration_file = "$ENV{HOME}/.urlierc";
my $config             = Config::File::read_config_file($configuration_file);

warn Dumper($config) if $DEBUG;

our $NICK     = $config->{Server}{Nick};
our $IRCNAME  = $config->{Server}{IRCName};
our $CHAN     = $config->{Server}{Chan};
our $SERVER   = $config->{Proxy}{Host};
our $PORT     = $config->{Proxy}{Port};
our $PASSWORD = $config->{Proxy}{Password};

$0 = 'urlie_' . $NICK . $CHAN . '@' . $SERVER;

my $irc = POE::Component::IRC->spawn(
    nick         => $NICK,
    ircname      => $IRCNAME,
    server       => $SERVER,
    port         => $PORT,
    password     => $PASSWORD,
    plugin_debug => $DEBUG,
);

POE::Session->create(
    package_states => [ main => [qw(_start irc_001)], ],
    heap           => { irc  => $irc },
);

$poe_kernel->run;

sub _start {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
    my $irc = $heap->{irc};

    $irc->yield( register => 'all' );

    $irc->plugin_add(
        'Connector' => POE::Component::IRC::Plugin::Connector->new() );

    $irc->plugin_add(
        'get_page_title' =>
          POE::Component::IRC::Plugin::WWW::GetPageTitle::ToChannel->new(
            auto             => 1,
            addressed        => 0,
            find_uris        => 1,
            max_uris         => 2,
            banned           => [],
            eat              => 1,
            debug            => $DEBUG,
            listen_for_input => [qw(public privmsg notice)],
            response_event   => 'irc_get_page_title',
            response_types   => {
                public  => 'public',
                privmsg => 'privmsg',
                notice  => 'notice',
            },
            trigger => qr/^/i,
          )
    );

    $irc->yield( connect => {} );
}

sub irc_001 {
    print "";
    $_[KERNEL]->post( $_[SENDER] => join => $CHAN );
}

