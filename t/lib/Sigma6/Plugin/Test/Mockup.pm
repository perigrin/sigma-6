package Sigma6::Plugin::Test::Mockup;
use Moose;
use namespace::autoclean;

has [qw(build workspace results)] => ( is => 'ro', required => 1, );

with qw(
    Sigma6::Plugin::API::Queue
    Sigma6::Plugin::API::RecordResults
    Sigma6::Plugin::API::Repository
    Sigma6::Plugin::API::Smoker
    Sigma6::Plugin::API::Workspace

);

sub fetch_build { ::pass('fetch_build'), shift->build }

sub push_build {
    ::is_deeply $_[1], shift->build, 'push_build got build';
}

sub setup_workspace { ::ok -e shift->workspace, "setup workspace" }

sub teardown_workspace {
    ::ok -e shift->workspace, "teardown workspace";
}

sub record_results {
    ::is_deeply $_[1], $_[0]->build,   'record_results got build';
    ::is_deeply $_[2], $_[0]->results, 'record_results got pass';
}
sub run_smoke { ::is_deeply $_[1], shift->build, 'run_smoke got build'; }

sub setup_smoker {
    ::is_deeply $_[1], shift->build, 'setup_smoker got build';
}

sub check_smoker {
    ::is_deeply $_[1], $_[0]->build, 'setup_smoker got build';
    $_[0]->results;
}

sub smoker_command       {...}
sub start_smoker         {...}
sub revision_description {...}
sub revision             {...}
sub revision_status      {...}
sub repository           {...}
sub target               {...}
sub repository_directory {...}

sub teardown_smoker {
    ::is_deeply $_[1], shift->build, 'teardown_smoker got build';
}

sub setup_repository {
    ::is_deeply $_[1], shift->build, 'setup_repository got build';
}

sub teardown_repository {
    ::is_deeply $_[1], shift->build, 'teardown_repository got build';
}

1;
__END__
