package Sigma6::Config;
use Moose::Role;
use namespace::autoclean;

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

sub build_target {
    my $self    = shift;
    my @plugins = $self->plugins_with('-BuildTarget');
    my ($build_target) = map { $_->build_target } @plugins;
    return $build_target;
}

sub temp_dir {
    my $self    = shift;
    my @plugins = $self->plugins_with('-TempDir');
    my ($temp_dir) = map { $_->temp_dir } @plugins;
    return $temp_dir;
}

sub smoker_command {
    my $self    = shift;
    my @plugins = $self->plugins_with('-SmokerCommand');
    my ($smoker_command) = map { $_->smoker_command } @plugins;
    return $smoker_command;
}

1;
__END__
