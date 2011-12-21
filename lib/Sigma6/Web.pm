package Sigma6::Web;
use v5.10;
use Moose;

# ABSTRACT: A small web front-end for Sigma6

use Sigma6::Config;
use Plack::Request;
use Plack::Response;

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

sub run_psgi {
    return shift->as_psgi(shift)->(@_)->finalize;
}

sub as_psgi {
    my ( $self, $env ) = @_;
    return sub {
        my $r = Plack::Request->new($env);
        return $self->HTTP_404 unless $r->path eq '/';
        if ( my $method = $self->can( $env->{REQUEST_METHOD} ) ) {
            return $self->$method($r);
        }
        return $self->HTTP_501;
    };
}

sub HTTP_501 {
    my $res = Plack::Response->new(501);
    $res->content_type('text/plain');
    $res->body('Sorry that method is not implemented for this resource');
    return $res;
}

sub HTTP_404 {
    my $res = Plack::Response->new(404);
    $res->content_type('text/plain');
    $res->body('Sorry that resource can not be found.');
    return $res;
}

sub POST {
    my $self = shift;
    $_->start_smoker for $self->plugins_with('-StartSmoker');
    my $res = Plack::Response->new();
    $res->redirect('/');
    return $res;
}

sub GET {
    my $self = shift;
    my $builds
        = [ map { $_->check_builds } $self->plugins_with('-CheckBuilds') ];
    my $output;
    for my $html ( $self->plugins_with('-RenderHTML') ) {
        $output .= $html->render( $builds, $output );
    }
    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
    $res->body($output);
    return $res;
}

1;
__END__
