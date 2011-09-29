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
    return $self->HTTP_404 unless $env->{'sigma6.path'} eq '/';
    if ( my $method = $self->can( $env->{REQUEST_METHOD} ) ) {
        return $self->$method($env);
    }
    return $self->HTTP_501;
}

sub HTTP_501 {
    return [
        501,
        [ "Content-Type", "text/plain" ],
        ["Sorry that method is not implemented for this resource"],
    ];

}

sub HTTP_404 {
    return [
        404,
        [ "Content-Type", "text/plain" ],
        ["Sorry that resource can not be found."],
    ];
}

sub HTTP_302 {
    my ( $self, $url ) = @_;
    return [ 302, [ 'Location', $url ], [] ];
}

sub POST {
    my $self = shift;
    if ( my $pid = fork ) {    # return a 302 to GET /
        return $self->HTTP_302('/');
    }
    elsif ( defined $pid ) {    # kick off the build server
        exec( $self->{server}{smoker_command} );
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
    return [ 200, [ "Content-Type", "text/html" ], [$output], ];
}

sub _check_build {
    my $self = shift;
    unless ( -e $self->{build}{temp_dir} ) {

        $self->{repo}{head_sha1} = '[unknown]';
        $self->{status} = 'Repository work tree missing. Kick off a build.';
        return;
    }
    my $repo = Git::Repository->new( work_tree => $self->{build}{temp_dir} );
    $self->{status} = $repo->run( 'notes', 'show', 'HEAD' );
    $self->{repo}{head_sha1} = substr $repo->run( 'rev-parse' => 'HEAD' ), 0,
        6;
    $self->{repo}{description} = $repo->run( 'log', '--oneline', '-1' );
    $self->{status} ||= 'No smoke results.';
    return;
}

sub _template {
    return \qq[
<!DOCTYPE html>
<html>
    <head>
        <title>Sigma6: [% o.build.target %]</title>
    </head>
    <body>
        <h1>Build [% o.repo.head_sha1 %]</h1>
	<p><i>[% o.repo.description %]</i></p>
        <p>Building: <a href="[% o.build.target %]">[% o.build.target %]</a></p>
        <p>Dep Command: [% o.build.deps_command %]</p>
        <p>Build Command:  [% o.build.build_command %]</p>
        <form action="/" method="POST"><input type="submit" value="Build"/></form>
        <div><pre><code>[% o.status %]</code></pre></div>
    </body>
</html>
]
}

1;
__END__

=head1 NAME Sigma6

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

Sigma6 is a Continuous Integration application originally based upon
CIJoe. It should be self-hosting now but that hasn't really been pushed.
Additionally the tests are woefully lacking, and you're reading all of the
documentation there is. That said, it's under 200 lines of code, you should
just read that.

