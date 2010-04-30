package Sigma6::Web;
use Moose 1.01;
our $VERSION = '0.01';
use namespace::autoclean 0.09;

# Most of this package was stole from Miyagawa's Tigger

use Try::Tiny;
use Moose::Util::TypeConstraints;
use Plack::Request;
use Sigma6::Web::Routes;
use Plack::Middleware::HTTPExceptions;

Moose::Exporter->setup_import_methods( as_is => [qw(resource run new_response)],
);

my $rs = Sigma6::Web::Routes->new;

sub new_response { Plack::Response->new(@_) }

sub resource {
    my ( $path, %methods ) = @_;
    for my $name qw(get put post) {
        next unless exists $methods{$name};
        my $method = $methods{$name};
        $rs->$name( $path, { cb => psgify($method) }, $_[2] );
    }
}

sub run {
    my $self = shift;
    return sub {
        my $env = shift;
        if ( my $match = $rs->match($env) ) {
            return $match->{cb}->($env);
        }
        else {
            return [
                404,
                [ "Content-Type", "text/plain" ],
                ["Sorry we're not sure how to handle that request"],
            ];
        }
    };
}

class_type 'Sigma6::Web::PSGI::App';

sub psgify {
    my ($app) = @_;
    match_on_type $app => (
        'Sigma6::Web::PSGI::App' => sub { return $app },
        'Any'                    => sub {
            my $wrapped = sub {
                my $env = shift;
                my $req = Plack::Request->new($env);

                my $res =
                  try { $app->($req) }
                catch { return $env->{'Sigma6::Web.exception.caught'} = $_ };

                die $res if $env->{'Sigma6.exception.caught'};

                match_on_type $res => (
                    'Sigma6::Web::PSGI::App' => sub {
                        return $res->($env);
                    },
                    'ArrayRef|CodeRef' => sub {
                        return $res;
                    },
                    'Str' => sub {
                        my $body = $res;
                        $res = $req->new_response(200);
                        $res->content_type('text/html');
                        $res->content_length( length $body );
                        $res->content($body);
                        return $res->finalize;
                    }
                );
            };
            Plack::Middleware::HTTPExceptions->wrap($wrapped);
        }
    );
}
1;
__END__
