package Sigma6::Plugin::Template::Tiny;
use Moose;
use namespace::autoclean;
use Template::Tiny;
use Try::Tiny;
use File::ShareDir qw(class_file);

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::RenderHTML);

has build_template => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_template',
);

sub _build_template {
    my $file = try { class_file( __PACKAGE__, 'root/src/build.tt' ) }
    catch {'share/root/src/build.tt'};
    return do { local $/; open my $fh, '<', $file; <$fh>};
}

has all_builds_template => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_all_builds_template',
);

sub _all_builds_template {
    my $file = try { class_file( __PACKAGE__, 'root/src/all_builds.tt' ) }
    catch {'share/root/src/all_builds.tt'};
    return do { local $/; open my $fh, '<', $file; <$fh>};
}

sub render_build {
    my ( $self, $r, $builds ) = @_;
    my $vars = { o => $self, b => $builds->[0] };
    Template::Tiny->new->process(
        ( \$self->build_template, $vars ) => \( my $output ) );
    return $output;
}

sub render_all_builds {
    my ( $self, $r, $builds ) = @_;
    my $vars = { o => $self, builds => $builds };
    Template::Tiny->new->process(
        ( \$self->all_builds_template, $vars ) => \( my $output ) );
    return $output;
}

sub workspace {
    my $self = shift;
    $self->first_from_plugin_with( '-Workspace', sub { shift->workspace } );
}

sub target {
    my $self = shift;
    $self->first_from_plugin_with( '-Repository', sub { shift->target } );
}

sub repo_plugins {
    my $self = shift;
    [ $self->plugins_with('-Repository') ];
}

1;
__END__
