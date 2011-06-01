package Sigma6;
use strict;
use warnings;

# ABSTRACT: CIJoe is a Real American Hero ... Sigma6 continues the battle against Pyth^WCobra

use Carp qw(confess);
use Template::Tiny;
use Git::Repository;

sub new {
    my $class = shift;
    my %p = ref $_[0] ? %{ $_[0] } : @_;
    return bless \%p, $class;
}

sub run_psgi {
    my ( $self, $env ) = @_;
    $env->{'sigma6.path'} = $env->{PATH_INFO} || '/';
    return $self->_404 unless $env->{'sigma6.path'} eq '/';
    if ( my $method = $self->can( $env->{REQUEST_METHOD} ) ) {
        return $self->$method($env);
    }
    return $self->_501;
}

sub to_app {
    my $self = shift;
    return sub { $self->run_psgi(@_) };
}

sub _501 {
    return [
        501,
        [ "Content-Type", "text/plain" ],
        ["Sorry that method is not implemented for this resource"],
    ];

}

sub _404 {
    return [
        404,
        [ "Content-Type", "text/plain" ],
        ["Sorry that resource can not be found."],
    ];
}

sub POST {
    my $self = shift;
    if ( my $pid = fork ) {    # return a 302 to GET /
        return [ 302, [ 'Location', '/' ], [] ];
    }
    elsif ( defined $pid ) {    # kick off the build server
        exec( 'bin/smoke.pl', '--config', $self->{server}{smoker_config} );
        exit;
    }
    else {                      # something funky happened
        confess "Could not fork: $!";
    }
}

sub GET {
    my $self = shift;
    $self->_check_build;
    Template::Tiny->new->process(
        $self->_template,
        { o => {%$self}, },
        \( my $output )
    );
    return [ 404, [ "Content-Type", "text/html" ], [$output], ];
}

sub _check_build {
    my $self = shift;
    unless ( -e $self->{build}{dir} ) {
        $self->{repo}{head_sha1} = '[unknown]';
        $self->{status} = 'Repository work tree missing. Kick off a build.';
        return;
    }
    my $repo = Git::Repository->new( work_tree => $self->{build}{dir} );
    $self->{status} = $repo->run( 'notes', 'show', 'HEAD' );
    $self->{repo}{head_sha1} = substr $repo->run( 'rev-parse' => 'HEAD' ), 0, 6;

    $self->{status} ||= 'No smoke results.';
    return;
}

sub _template {
    return \qq[
<!DOCTYPE html>
<html>
    <head>
        <title>Sigma6: [% o.repo.head_sha1 %]</title>
    </head>
    <body>
        <h1>Build [% o.repo.head_sha1 %]</h1>
        <p>Building: <a href="[% o.build.target %]">[% o.build.target %]</a>
        <form action="/" method="POST"><input type="submit" value="Build"/></form>
        <div><pre><code>[% o.status %]</code></pre></div>
    </body>
</html>
]
}

1;
__END__

=head1 Sigma6

CIJoe is a Real American Hero ... Sigma6 continues the battle against Pyth^WCobra

=head1 SYNOPSIS

    > cat sigma6.ini
    [server]
    smoker_command = /Users/perigrin/dev/perigrin/sigma-6/bin/smoke.pl
    smoker_config = sigma6.ini

    [build]
    target        = git@github.com:perigrin/sigma-6.git
    dir           = /tmp/sigma6
    deps_command  = dzil listdeps | cpanm -L perl5 
    build_command = dzil smoke --automated
        
    > plackup app.psgi

=head1 DESCRIPTION

Sigma6 is a Continuous Integration Application originally based upon CIJoe
(https://github.com/defunkt/cijoe). At the moment we're still worrying about
getting it to self-host.

