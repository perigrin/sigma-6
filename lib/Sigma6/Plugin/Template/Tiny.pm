package Sigma6::Plugin::Template::Tiny;
use Moose;
use namespace::autoclean;
use Template::Tiny;

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::RenderHTML);

sub render_build {
    my ( $self, $r, $builds ) = @_;
    my $vars = { o => $self, b => $builds->[0] };
    Template::Tiny->new->process(
        ( $self->build_template, $vars ) => \( my $output ) );
    return $output;
}

sub render_all_builds {
    my ( $self, $builds ) = @_;
    my $vars = { o => $self, builds => $builds };
    Template::Tiny->new->process(
        ( $self->all_builds_template, $vars ) => \( my $output ) );
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

sub build_template {
    return \qq[
    <!DOCTYPE html>
    <html>
        <head>
            <title>Sigma6</title>
        </head>
        <body>
            <h1>[% o.target_name %]</h1>
            <h2>Build [% b.id %]</h2>
    	    <p><i>[% b.description %]</i></p>
            <form action="/" method="POST"><input type="submit" value="Build"/></form>
            <div><pre><code>[% b.status %]</code></pre></div>
        </body>
    </html>
    ];
}

sub all_builds_template {
    return \qq[
<!DOCTYPE html>
<html>
    <head>
        <title>Sigma6</title>
    </head>
    <body>
    <h1>[% o.target_name %]</h1>
    [% UNLESS builds.count %]
        <p>Nothing Built Yet</p>
    [% ELSE %]
    [% FOREACH b IN builds %]
        <h2>Build [% b.id %]</h2>
	    <p><i>[% b.description %]</i></p>
        <form action="/" method="POST"><input type="submit" value="Build"/></form>
        <div><pre><code>[% b.status %]</code></pre></div>
    [% END %]
    [% END %]
    </body>
</html>
]
}

1;
__END__
