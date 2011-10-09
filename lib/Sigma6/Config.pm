package Sigma6::Config;
use Moose::Role;
use namespace::autoclean;

requires qw(
    build_target
    smoker_command
    temp_dir
    plugins_with
);

1;
__END__
