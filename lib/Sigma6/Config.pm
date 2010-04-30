package Sigma6::Config;
use strict;
our $VERISON = '0.01';
use Bread::Board 0.13;
use namespace::autoclean 0.09;

sub _container {
    state $c = container 'Sigma6' => as {

        service 'repo'         => 'repo';
        service 'build_script' => 'build_script';
        service 'status_file'  => '/tmp/build.txt';

        service 'Engine' => (
            class        => 'Sigma6::Engine',
            dependencies => {
                repo         => depends_on('repo'),
                build_script => depends_on('build_script'),
                status_file  => depends_on('status_file'),
            }
        );

    };
}
sub engine { _container()->fetch('Engine')->get; }

1;
__END__
