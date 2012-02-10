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

        my $app = sub {
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

sub GET {
    my ( $self, $r ) = @_;
    my $renderer = HTTP::Negotiate::choose(
        [   [ '-RenderJSON', 1.000, 'application/json', ],
            [ '-RenderHTML', 1.000, 'text/html', ],
        ],
        $r->headers
    );

    my $build_id = ( split m|/|, $r->path_info )[-1];
    $r->logger->(
        { level => 'warn', message => "found build_id: $build_id" } )
        if $build_id;
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
