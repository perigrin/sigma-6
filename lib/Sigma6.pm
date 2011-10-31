package Sigma6;
use Moose;

# ABSTRACT: CIJoe is a Real American Hero ... Sigma6 continues the battle against Pyth^WCobra

use Sigma6::Config;
use Template::Tiny;

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

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
        exec( $self->smoker_command );
        exit;
    }
    else {                      # something funky happened
        confess "Could not fork: $!";
    }
}

sub GET {
    my $self = shift;
    my $repo = $self->_check_build;
    Template::Tiny->new->process(
        $self->_template,
        {   o => $self,
            r => $repo
        },
        \( my $output )
    );
    return [ 200, [ "Content-Type", "text/html" ], [$output], ];
}

sub _check_build {
    my $self = shift;
    my $ret = {
        map { %{ $_->check_build } } $self->plugins_with('-BuildTarget')
    };
    warn Data::Dumper::Dumper $ret;
    return $ret;
}

sub _template {
    return \qq[
<!DOCTYPE html>
<html>
    <head>
        <title>Sigma6: [% o.build_target %]</title>
    </head>
    <body>
        <h1>Build [% r.head_sha1 %]</h1>
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

=head1 NAME Sigma6

CIJoe is a Real American Hero ... Sigma6 continues the battle against Pyth^WCobra

=head1 SYNOPSIS

    > cat sigma6.ini
    [System]
    temp_dir       = /tmp/sigma6
    smoker_command = bin/smoker.pl;

    [Git]
    target        = git@github.com:perigrin/sigma-6.git

    [Dzil]
    deps_command  = dzil listdeps | cpanm -L perl5
    build_command = 'PERL5LIB="perl5/lib/perl5:$PERL5LIB" dzil smoke'
        
    > plackup app.psgi

=head1 DESCRIPTION

Sigma6 is a Continuous Integration application originally based upon
CIJoe. It should be self-hosting now but that hasn't really been pushed.
Additionally the tests are woefully lacking, and you're reading all of the
documentation there is. That said, it's 315 lines of code, you could
just read that.
