use inc::Module::Install;

# Define metadata
name 'Hackeriet-Urlie';
abstract q(Hackeriets IRC bot);
author q(Salve J. Nilsen <sjn@cpan.org>);
version '0.001_000';
perl_version '5.010_001';
repository 'git@gitorious.org:urlie/urlie.git';

# Specific dependencies
requires 'POE::Component::IRC' => 0,
    'POE::Component::IRC::Plugin::WWW::GetPageTitle' => 0,
    'Data::Dumper::Concise' => 0,
    'Config::File' => 0;

recommends 'IO::Socket::SSL' => 0;
# install_script 'bin/urlie.pl';
# install_script 'bin/proxie.pl';

license 'gplv3';

WriteAll;

