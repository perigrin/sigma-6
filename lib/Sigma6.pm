package Sigma6;
use strict;
use warnings;

# ABSTRACT: like CIJoe but with 100% more Awesome

use Template::Tiny;
use HTTP::Tiny;

my $TEMPLATE = do { local $/; <DATA> };   # emulate state variables for perl 5.8

sub new {
    my $class = shift;
    my %p = ref $_[0] ? %{ $_[0] } : @_;
    $p{build} ||= 0;
    return bless \%p, $class;
}

sub _GET_index {
    my $env = shift;
    return unless $env->{REQUEST_METHOD} eq 'GET';
    return unless $env->{'sigma6.path'}  eq '/';
    return 1;
}

sub _POST_index {
    my $env = shift;
    return unless $env->{REQUEST_METHOD} eq 'POST';
    return unless $env->{'sigma6.path'}  eq '/';
    return 1;
}

sub run_psgi {
    my ( $self, $env ) = @_;
    $env->{'sigma6.path'} = $env->{PATH_INFO} || '/';
    return $self->_index if _GET_index($env);
    return $self->_build if _POST_index($env);
    return $self->_404;
}

sub _404 {
    return [
        404,
        [ "Content-Type", "text/plain" ],
        ["Sorry we're not sure how to handle that request"],
    ];
}

sub _build {
    my $self = shift;
    
    # start/queue build
    return [ 302, [ 'Location', '/' ], [] ];
}

sub _index {
    my $self = shift;
    $self->_check_build;
    Template::Tiny->new->process(
        \$TEMPLATE,
        { o => {%$self}, },
        \( my $output )
    );
    return [ 404, [ "Content-Type", "text/html" ], [$output], ];
}

sub _check_build {
    my $self = shift;
    $self->{status} = 'No Build Data';
}

1;
__DATA__
<!DOCTYPE html>
<html>
    <head>
        <title>Sigma6: [% o.build %]</title>
    </head>
    <body>
        <h1>Build [% o.build %]</h1>
        <p>Building: <a href="[% o.target %]">[% o.target %]</a>
        <form action="/build" method="POST"><input type="submit" value="Build"/></form>
        <p>[% o.status %]</p>
    </body>
</html>
