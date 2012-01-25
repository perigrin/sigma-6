package Sigma6::Config;
use 5.10.1;
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

use DDP;

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

    #    warn p @output;
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

=head1 METHODS

=over 

=item plugins 

return an ArrayRef of plugins currently registered

=item find_plugin(CodeRef) 

greps through the plugin list for a plugin list for a plugin that causes
CodeRef to return true

=item add_plugins (ShortName)

loads plugins matching ShortName from disk into the Plugin list

=item plugins_with (PluginType)

returns a list of plugins that match PluginType

=item first_from_plugin_wtih (PluginType, CodeRef(Plugin))

iterates through the plugins that perform PluginType and returns the first
true value for CodeRef 

=back
