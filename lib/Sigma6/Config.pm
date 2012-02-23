package Sigma6::Config;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: The Sigma6 Plugin Configuration System

requires qw(get_section_config);

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
    my %seen        = ();
    my $seen_plugin = sub {
        my $class = "Sigma6::Plugin::$_[0]";
        return if $self->find_plugin( sub { blessed($_) eq $class } );
        return if $seen{$class}++;
        return $class;
    };

    my $load_class = sub { Class::MOP::load_class("Sigma6::Plugin::$_") };

    my $new_plugin = sub {
        my $cfg   = $self->get_section_config($_);
        my $class = "Sigma6::Plugin::\u$_";
        $class->new( config => $self, %$cfg );
    };

    my @output = map { $new_plugin->($_) }
        grep { $load_class->($_) }
        grep { $seen_plugin->($_) } map { ucfirst $_ } @input;

    $self->$next(@output);
};

sub plugins_with {
    my ( $self, $name ) = @_;
    $name =~ s/^-/Sigma6::Plugin::API::/;
    return $self->find_plugin( sub { $_->does($name) } );
}

sub first_from_plugin_with {
    my ( $self, $role, $test ) = @_;
    my @plugins = $self->plugins_with($role);
    confess "No plugins found for $role" unless @plugins;
    for my $plugin (@plugins) {
        my $value = $plugin->$test;
        next unless $value;
        return $value;
    }
}

1;
__END__

=head1 NAME 

Sigma6::Config

=head1 SYNOPSIS

    package Sigma6::Config::Awesome;
    use Moose
    with qw(Sigma6::Config);

    sub get_section_config { ... }
    
    1;
    __END__

=head1 DESCRIPTION

C<Sigma6::Config> is a Role that defines the API for the config system, and by
extension the plugin system.

=head1 METHODS

=over 

=item plugins 

Return an ArrayRef of plugins currently registered

=item find_plugin($CodeRef) 

Grep through the plugin list for a plugin list for a plugin that causes
CodeRef to return true

=item add_plugins ($name)

Expand $name into a plugin name, then load and create a new instance of the
plugin.

=item plugins_with ($Role)

Returns a list of plugins that match Role

=item first_from_plugin_wtih ($role, $CodeRef)

Iterates through the plugins that do $role and returns the first true value
for $CodeRef. The $CodeRef is called as a method on the plugin. 

=back
