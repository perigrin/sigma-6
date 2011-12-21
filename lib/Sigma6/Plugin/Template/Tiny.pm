package Sigma6::Plugin::Template::Tiny;
use Moose;
use namespace::autoclean;
use Template::Tiny;

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::RenderHTML);

sub render {
    my ( $self, $repo ) = @_;
    my $vars = { o => $self, repo => $repo };
    Template::Tiny->new->process( $self->_template, $vars, \( my $output ) );
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

sub target_name {
    my $self = shift;
    $self->first_from_plugin_with( '-Repository',
        sub { shift->target_name } );
}

sub _template {
    return \qq[
<!DOCTYPE html>
<html>
    <head>
        <title>Sigma6: [% o.target %]</title>
    </head>
    <body>
        <h1>[% o.target_name %]</h1>
        <h2>Build [% r.build_id %]</h2>
	<p><i>[% r.description %]</i></p>
        <p>Building: <a href="[% o.build.target %]">[% o.build_target %]</a></p>
        <form action="/" method="POST"><input type="submit" value="Build"/></form>
        <div><pre><code>[% r.status %]</code></pre></div>
    </body>
</html>
]
}

1;
__END__
