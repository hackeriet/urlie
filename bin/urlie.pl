#!/usr/bin/env perl

use 5.010_001;
use strict;
use warnings;

use Config::File qw(read_config_file);
use Data::Dumper::Concise;
use Bot::BasicBot::Pluggable;

my $configuration_file = $ARGV[0] // "$ENV{HOME}/.urlierc";
my $config             = Config::File::read_config_file($configuration_file);

my $DEBUG = $ENV{URLIE_DEBUG} || $config->{DEBUG} || 0;
warn Dumper($config) if $DEBUG;

our $NICK     = $config->{Server}{Nick}     // 'urlie_' . $$ % 1000;
our $IRCNAME  = $config->{Server}{IRCName}  // q(urlie is sjn's bot);
our $CHAN     = $config->{Server}{Chan}     // '#testbot_' . $$ % 1000;
our $SERVER   = $config->{Proxy}{Host}      // 'irc.freenode.net';
our $PORT     = $config->{Proxy}{Port}      // 6667;
our $PASSWORD = $config->{Proxy}{Password}  // '';

# Set process name, so we can recognize it with ps(1)
$0 = $0 . '/' . $NICK . $CHAN . '@' . $SERVER . ':' . $PORT;

my $bot = Bot::BasicBot::Pluggable->new(
    channels     => [ $CHAN ],
    server       => $SERVER,
    port         => $PORT,
    nick         => $NICK,
    altnicks     => [ "${NICK}_", "${NICK}__" ],
    username     => "sjn_bot",
    name         => $IRCNAME,
    password     => $PASSWORD,
    plugin_debug => $DEBUG,
);

my $auth_module    = $bot->load("Auth");
$auth_module->set( password_admin => $PASSWORD );
my $chanop_module  = $bot->load("ChanOp");
my $dns_module     = $bot->load("DNS");
my $infobot_module = $bot->load("Infobot");
my $join_module    = $bot->load("Join");
my $karma_module   = $bot->load("Karma");
my $loader_module  = $bot->load("Loader");
my $seen_module    = $bot->load("Seen");
my $title_module   = $bot->load("Title");
$title_module->set( user_be_rude => 1 );
my $vars_module    = $bot->load("Vars");



say "Starting $NICK on $CHAN\@$SERVER";

$bot->run;
