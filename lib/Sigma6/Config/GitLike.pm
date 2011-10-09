package Sigma6::Config::GitLike;
use Moose;
use namespace::autoclean;

extends qw(Config::GitLike);

use File::Spec;
use Moose::Util::TypeConstraints;
use File::Temp qw(tempdir);

has '+confname' => ( default => 'sigma6.ini' );

sub dir_file {
    my $self = shift;
    return $self->confname;
}

sub user_file {
    my $self = shift;
    my $name = $self->confname;
    $name =~ s/.ini$//;
    return File::Spec->catfile( $ENV{'HOME'}, ".$name" );
}

around 'define' => sub {
    my $next = shift;
    my $self = shift;
    my %args = (
        section => undef,
        name    => undef,
        value   => undef,
        origin  => undef,
        @_,
    );
    $self->add_plugins( $args{section} ) if $args{section};
    $self->$next(%args);
};

has plugins => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => ['Array'],
    lazy    => 1,
    builder => '_build_plugins',
    handles => {
        '_plugins_with' => 'grep',
        'add_plugins'   => 'push',
    }
);

sub _build_plugins { [] }

sub plugins_with {
    my ( $self, @plugins ) = @_;
    my @output;
    for my $role (@plugins) {
        $role =~ s/^-/Sigma6::Plugin::/;
        push @output, $self->_plugins_with( sub { $_->does($role) } );
    }
    return @output;
}

my %seen_plugin = ();

around add_plugins => sub {
    my ( $next, $self ) = ( shift, shift );
    my @plugins = map { $_->new( config => $self ) }
        grep { Class::MOP::load_class($_) }
        grep { not $seen_plugin{$_}++ }
        map  { 'Sigma6::Plugin::' . ucfirst $_ }
        grep { $_ !~ qr/web|smoke|api/ } @_;
    $self->$next(@plugins);
};

has smoker_command => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_smoker_command'
);

sub _build_smoker_command {
    shift->get( key => 'build.smoker_command' )
        || 'bin/smoker.pl --config sigma6.ini';
}

has temp_dir => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_temp_dir'
);

sub _build_temp_dir {
    my $self = shift;
    $self->get( key => 'build.temp_dir' )
        || tempdir( CLEANUP => 1 ) . '/sigma6';
}

has build_target => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_build_target'
);

sub _build_build_target {
    shift->get( key => 'build.target' );
}

with qw(Sigma6::Config);

1;
__END__
