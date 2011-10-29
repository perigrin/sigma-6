package Sigma6::Config;
use Moose::Role;
use namespace::autoclean;

use File::Temp qw(tempdir);

has plugins => (
    isa    => 'ArrayRef',
    is     => 'ro',
    traits => ['Array'],

    #    lazy    => 1,
    builder => '_build_plugins',
    handles => {
        'find_plugin' => 'grep',
        'add_plugins' => 'push',
    }
);

sub _build_plugins { [] }

around add_plugins => sub {
    my ( $next, $self, @input ) = @_;
    my @output;
    for my $name (@input) {
        $name = 'Sigma6::Plugin::' . ucfirst($name);
        next if $self->find_plugin( sub { $_->isa($name) } );
        next unless Class::MOP::load_class($name);
        push @output, $name->new( config => $self );
    }
    $self->$next(@output);
};

sub plugins_with {
    my ( $self, @plugins ) = @_;
    my @output = ();
    for my $plugin (@plugins) {
        $plugin =~ s/^-/Sigma6::Plugin::API::/;
        push @output, $self->find_plugin( sub { $_->does($plugin) } );
    }
    return @output;
}

sub temp_dir {
    tempdir( CLEANUP => 1 ) . '/sigma6';
}

sub build_target {
    my $self    = shift;
    my @plugins = $self->plugins_with('-BuildTarget');
    my ($build_target) = map { $_->build_target } @plugins;
    return $build_target;
}

sub smoker_command {
    'bin/smoker.pl --config sigma6.ini';
}

1;
__END__
