package Sigma6::Config::Simple;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Simple Hash Based Config for Sigma6

has config => (
    traits   => ['Hash'],
    isa      => 'HashRef',
    is       => 'ro',
    required => 1,
    handles  => {
        sections           => 'keys',
        get_section_config => 'get',
    }
);

with qw(Sigma6::Config);

around BUILDARGS => sub {
    my ( $next, $self ) = splice @_, 0, 2;
    if ( @_ == 1 && ref $_[0] eq 'HASH' ) {
        return $self->$next( config => shift );
    }
    my %p = @_;
    return $self->$next( config => \%p ) unless exists $p{config};
    return $self->$next(%p);

};

sub BUILD { $_[0]->add_plugins( $_[0]->sections ) }

1;
__END__

=head1 NAME 

Sigma6::Config::Simple

=head1 SYNOPSIS

    Sigma6::Config::Simple->new(
        'BuildManager::Kioku' => { dsn    => 'dbi:SQLite::memory:' },
        'Logger'              => { config => 'logger.conf' },
        'JSON'                => {},
        'Test::Queue'         => {},
        'TestSmoker'          => {
            workspace      => tempdir(),
            smoker_command => 'bin/smoker.pl --config etc/sigma6.ini',
        },
        'Git'  => { },
        'Dzil' => {
            deps_command  => 'cpanm -L perl5 --installdeps Makefile.PL',
            build_command => 'prove -I perl5/lib/perl5 -lwrv t/'
        },
    );

=head1 DESCRIPTION

This is a simple L<Sigma6::Config> implementation that takes it's
configuration from a Perl hash. It was built to simplify writing the tests.

