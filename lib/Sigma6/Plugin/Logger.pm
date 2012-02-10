package Sigma6::Plugin::Logger;
use Moose;
use namespace::autoclean;

# ABSTRACT: Turn baubles into trinkets
use Log::Log4perl;
use Moose::Util::TypeConstraints;

extends qw(Sigma6::Plugin);

has config => (
    is  => 'ro',
    isa => 'Str',
);

has logger => (
    is      => 'ro',
    isa     => 'Log::Log4perl::Logger',
    lazy    => 1,
    builder => '_build_logger',
    handles => {
        debug  => 'debug',
        notice => 'info',
        warn   => 'warn',
        die    => 'logconfess',
    },
);

sub _build_logger {
    Log::Log4perl->init( shift->config );
    Log::Log4perl->get_logger('Sigma6');
}

with qw(Sigma6::Plugin::API::Logger);

__PACKAGE__->meta->make_immutable;
1;
__END__
