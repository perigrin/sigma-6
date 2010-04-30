package Sigma6::Web::Routes;
use Moose;
use Encode ();
use Router::Simple;
use Plack::Util::Accessor qw(encoding);

has rs => (
    isa     => 'Router::Simple',
    is      => 'ro',
    default => sub { Router::Simple->new },
    handles => [qw(connect submapper routematch)]
);

has encoding => ( isa => 'Str', is => 'ro', default => 'utf-8' );

sub get { $_[0]->connect( $_[1], $_[2], { method => [ 'GET', 'HEAD' ] } ) }
sub post { $_[0]->connect( $_[1], $_[2], { method => ['POST'] } ) }
sub put  { $_[0]->connect( $_[1], $_[2], { method => ['PUT'] } ) }

sub any {
    my $self = shift;
    my $method = ref $_[0] eq 'ARRAY' ? shift : undef;
    $self->connect( $_[0], $_[1], $method ? { method => $method } : {} );
}

sub on {
    $_[0]->connect( $_[2], $_[3], { method => $_[1] } );
}

sub match {
    my ( $self, $env ) = @_;

    my ( $match, $route ) = $self->routematch($env);
    return unless $match;

    # magic path_info
    if ( exists $match->{path_info} ) {
        if ( $env->{PATH_INFO} =~ s!^(.*?)(/?)\Q$match->{path_info}\E$!! ) {
            $env->{SCRIPT_NAME} .= $1;
            $env->{PATH_INFO} = $2 . $match->{path_info};
        }
        else {
            confess "Path '$$env{PATH_INFO}' does not end with path_info: "
              . "'$$match{path_info}'";
        }
    }

    if ( $self->{encoding} ) {
        for my $k ( keys %$match ) {
            if ( $match->{$k} =~ /[^[:ascii:]]/ ) {
                $match->{$k} =
                  Encode::decode( $self->{encoding}, $match->{$k} );
            }
        }
    }

    $env->{'Sigma6.routing_args'}  = $match;
    $env->{'Sigma6.routing_route'} = $route;

    return $match;
}

1;

__END__
