package Sigma6::Config;
use 5.010;
use strict;
our $VERISON = '0.01';
use Bread::Board 0.13;
use namespace::autoclean 0.09;

use Moose::Exporter;
Moose::Exporter->setup_import_methods( as_is => [qw(manager)] );

sub _container {
    state $c = container 'Sigma6' => as {

        service 'repo'         => $ENV{'Sigma6.repo'};
        service 'build_script' => 'script/build.sh';
        service 'status_file'  => '/tmp/sigma6.build.log';
        service 'build_dir'    => '/tmp';

        service 'Manager' => (
            class        => 'Sigma6::Manager',
            dependencies => {
                repo         => depends_on('repo'),
                build_script => depends_on('build_script'),
                build_dir    => depends_on('build_dir'),
                status_file  => depends_on('status_file'),
            }
        );

    };
}
sub manager { _container()->fetch('Manager')->get; }

1;
__END__
