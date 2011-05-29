package Sigma6;
our $VERISON = '0.01';
use Plack 0.9979;

sub _404 {
    return [
        404,
        [ "Content-Type", "text/plain" ],
        ["Sorry we're not sure how to handle that request"],
    ];
}

sub _GET_index {
    my $r = shift;
    return 1 if $r->path eq '/' && $r->method eq 'GET';
    return 0;
}

sub _POST_build {
    my $r = shift;
    return 1 if $r->path eq '/build' && $r->method eq 'POST';
    return 0;
}

sub run_psgi {
    my $self = shift;
    return sub {
        my $r = Plack::Request->new(shift);
        return $self->index($r) if _GET_index($r);
        return $self->build($r) if _POST_build($r);
        return $self->_404($r);
      }
}

1;
__END__
