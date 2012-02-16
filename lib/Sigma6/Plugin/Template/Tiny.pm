package Sigma6::Plugin::Template::Tiny;
use Moose;
use namespace::autoclean;
use Template::Tiny;
use Try::Tiny;
use File::ShareDir qw(dist_file);

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::RenderHTML);

has template => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_template',
);

sub _build_template {
    my $file = try { dist_file( 'Sigma6', 'root/src/index.tt' ) }
    catch {'share/root/src/index.tt'};
    return do { local $/; open my $fh, '<', $file; <$fh> };
}

sub render {
    my ( $self, $res, $builds ) = @_;
    $res->content_type('text/html');
    my $vars = { o => $self, builds => $builds };
    Template::Tiny->new->process(
        ( \$self->template, $vars ) => \( my $output ) );
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
