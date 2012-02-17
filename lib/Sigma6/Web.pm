package Sigma6::Web;
use v5.10;
use Moose;

# ABSTRACT: A small web front-end for Sigma6

use Sigma6::Config;
use Plack::Request;
use Plack::Response;
use Try::Tiny;
use HTTP::Negotiate;
use Plack::Builder;

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

has assets_directory => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        try { dist_dir('Sigma6') } catch {'share'};
    },
);

sub as_psgi {
    my $self = shift;
    return builder {
        enable 'Plack::Middleware::Static' => (
            path => qr{^/static/|.ico$},
            root => $self->assets_directory . '/root/',
        );

        enable '+Sigma6::Web::Middleware::Logger' => (    #
            config => $self->config,
        );
        mount '/' => Plack::App::File->new(
            file => $self->assets_directory . '/root/static/index.html',
            content_type => 'text/html',
        );
        mount '/builds' => sub {
            my $env = shift;

            my $r      = Plack::Request->new($env);
            my $method = $self->can( $env->{REQUEST_METHOD} );

            return $self->HTTP_501->finalize unless $method;
            return $self->$method($r)->finalize;
        };
    }
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
    my $data = $r->parameters->as_hashref;
    $data->{target} ||= delete $data->{'builds[target]'};
    my $build_data = try {
        $self->first_from_plugin_with(
            '-BuildData' => sub { shift->build_data($data); } );
    }
    catch {
        $r->logger->( { level => 'warn', message => $_ } );
    };
    $r->logger->( { level => 'die', message => 'No Build Data' } )
        unless $build_data;
    my $build = $self->first_from_plugin_with( '-StartBuild',
        sub { $_[0]->start_build($build_data) } );

    my $res = Plack::Response->new();
    $r->logger->( { level => 'notice', message => "202 /$build->{id}" } );
    $res->redirect( "/$build->{id}", 202 );
    return $res;
}

sub get_build {
    my ( $self, $r, $build_id ) = @_;
    $r->logger->(
        {   level   => 'warn',
            message => "found build_id: $build_id"
        }
    );
    my $build = $self->first_from_plugin_with(
        '-CheckBuild' => sub { $_[0]->get_build($build_id) } );
    return $self->render( $r, $build );
}

sub get_all_builds {
    my ( $self, $r ) = @_;
    my @builds
        = map { $_->check_all_builds } $self->plugins_with('-CheckBuild');
    return $self->render( $r, \@builds );
}

sub render {
    my ( $self, $r, $builds ) = @_;
    my $renderer = HTTP::Negotiate::choose(
        [   [ '-RenderJSON', 1.000, 'application/json', ],
            [ '-RenderHTML', 1.000, 'text/html', ],
        ],
        $r->headers
    );
    my $res = Plack::Response->new(200);

    my $output = $self->first_from_plugin_with(
        $renderer => sub { $_[0]->render( $res, $builds ) } );
    $res->body($output);
    return $res;
}

sub GET {
    my ( $self, $r ) = @_;

    my $build_id = ( split m|/|, $r->path_info )[-1];
    undef $build_id if defined $build_id && $build_id eq 'builds';

    return $self->get_build( $r, $build_id ) if $build_id;
    return $self->get_all_builds($r);
}

1;
__END__
