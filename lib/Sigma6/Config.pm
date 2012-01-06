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
    my @output = map {
        my $cfg   = $self->get_section_config($_);
        my $class = "Sigma6::Plugin::\u$_";        
        $class->new(config => $self, %$cfg)
    }
    grep { Class::MOP::load_class("Sigma6::Plugin::\u$_") }
    grep {
        !$self->find_plugin( sub { blessed(shift) eq "Sigma6::Plugin::\u$_" }
            )
    } @input;
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
