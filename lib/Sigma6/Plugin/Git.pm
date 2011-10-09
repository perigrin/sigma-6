package Sigma6::Plugin::Git;
use Moose;

use Git::Repository;

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::CheckBuild
);

sub check_build {
    my ( $self, $work_tree ) = @_;
    unless ( -e $work_tree ) {
        return {
            head_sha1 => '[unknown]',
            status    => 'Repository work tree missing. Kick off a build.',
        };
    }

    my $repo = Git::Repository->new( work_tree => $work_tree );
    return {
        head_sha1 => substr( $repo->run( 'rev-parse' => 'HEAD' ), 0, 6 ),
        status => $repo->run( 'notes', 'show', 'HEAD' ) || 'No smoke results',
        description => $repo->run( 'log', '--oneline', '-1' ),
    };
}

1;
__END__
