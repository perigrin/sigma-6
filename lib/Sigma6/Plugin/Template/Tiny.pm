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
    my ( $self, $r, $builds ) = @_;
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

sub repo_plugins {
    my $self = shift;
    [$self->plugins_with('-Repository')];
}

sub build_template {
    return \qq[
    <!DOCTYPE html>
    <html>
        <head>
            <title>Sigma6</title>
        </head>
        <body>
            <h1>[% o.target %]</h1>
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
    <h1>Sigma6 Builds</h1>
    [%- UNLESS builds.count %]
        <p>No Builds Yet</p>
    [%- ELSE -%]
        [% FOREACH b IN builds %]
            <h2>Build [% b.id %]</h2>
            <p><i>[% b.description %]</i></p>
            <form action="/" method="POST"><input type="submit" value="Build"/></form>
            <div><pre><code>[% b.status %]</code></pre></div>
        [% END %]
    [% END %]
    <form method='POST' action="/">
        <select name="some_name" id="some_name" onchange="" size="1">
            [%- FOREACH plugin IN o.repo_plugins %]
            <option value="[% plugin.name %]">[% plugin.name %]</option>
            [%- END %]
        </select>
        <input type="text" value="target" />
        <input type="submit">
    </form>
    </body>
</html>
]
}

1;
__END__
