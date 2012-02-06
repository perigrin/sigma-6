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
            path => qr{^/static/},
            root => $self->assets_directory . '/root/',
        );
        my $app = sub {
            my $env = shift;
            my $r   = Plack::Request->new($env);
            my $res;
            if ( my $method = $self->can( $env->{REQUEST_METHOD} ) ) {
                $res = $self->$method($r);
            }
            else {
                $res = $self->HTTP_501;
            }
            $res->finalize;
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
    my $data       = $r->parameters->as_hashref;
    $data->{target} ||= delete $data->{'builds[target]'};
    my $build_data = try {
        $self->first_from_plugin_with(
            '-BuildData' => sub { shift->build_data($data); } );
    }
    catch {
        warn $_;
    };
    confess "No Build Data" unless $build_data;
    my $build = $self->first_from_plugin_with( '-StartBuild',
        sub { $_[0]->start_build($build_data) } );

    my $res = Plack::Response->new();
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
