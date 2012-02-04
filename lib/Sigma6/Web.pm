package Sigma6::Web;
use v5.10;
use Moose;

# ABSTRACT: A small web front-end for Sigma6

use Sigma6::Config;
use Plack::Request;
use Plack::Response;
use Try::Tiny;
use HTTP::Negotiate;

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
    my ( $self, $r ) = @_;
    my $data       = $r->parameters->as_hashref;
    my $build_data = try {
        $self->first_from_plugin_with(
            '-BuildData' => sub { shift->build_data($data) } );
    }
    catch {$data};
    my $build = $self->first_from_plugin_with( '-StartBuild',
        sub { $_[0]->start_build($build_data) } );

    my $res = Plack::Response->new();
    $res->redirect("/$build->{id}");
    return $res;
}

sub GET {
    my ( $self, $r ) = @_;
    my $build_id = ( split m|/|, $r->path_info )[-1];
    my $renderer = HTTP::Negotiate::choose(
        [   [ '-RenderJSON', 1.000, 'application/json', ],
            [ '-RenderHTML', 1.000, 'text/html', ],
        ],
        $r->headers
    );

    my $builds
        = $build_id
        ? [
        $self->first_from_plugin_with(
            '-CheckBuild' => sub { $_[0]->get_build($build_id) }
        )
        ]
        : [ map { $_->check_all_builds } $self->plugins_with('-CheckBuild') ];

    my $output = $self->first_from_plugin_with(
        $renderer => sub { $_[0]->render_all_builds( $r, $builds ) } );

    my $res = Plack::Response->new(200);
    $res->body($output);
    return $res;
}

1;
__END__
