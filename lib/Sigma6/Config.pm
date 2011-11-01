package Sigma6::Config;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: The Sigma6 Plugin Configuration System

requires qw(get_config);

has plugins => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => ['Array'],
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

sub first_from_plugin_with {
    my ( $self, $role, $test ) = @_;
    my @plugins = $self->plugins_with($role);
    for my $plugin (@plugins) {
        my $value = $plugin->$test;
        next unless $value;
        return $value;
    }
}

1;
__END__

