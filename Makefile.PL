use inc::Module::Install;

name 'Hackeriet-Urlie';
abstract q(Hackeriets IRC bot);
author q(Salve J. Nilsen <sjn@cpan.org>);
version '0.002_000';
perl_version '5.010_001';
repository 'git@gitorious.org:urlie/urlie.git';
license 'gplv3';

requires
    'Bot::BasicBot::Pluggable' => 0,
    'Data::Dumper::Concise' => 0,
    'Config::File' => 0;

recommends 'IO::Socket::SSL' => 0,
    'Bot::BasicBot::Pluggable::Module::RSS' => 0,
    'Bot::BasicBot::Pluggable::Module::NorskEngelsk' => 0,
    'Bot::BasicBot::Pluggable::Module::Retort' => 0,
    'Bot::BasicBot::Pluggable::Module::Tools' => 0;

install_script 'bin/urlie.pl',
    'bin/proxie.pl';

WriteAll;

