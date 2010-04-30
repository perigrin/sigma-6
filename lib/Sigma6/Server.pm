package Sigma6::Server;
use Moose 1.01;
our $VERISON = '0.01';
use namespace::autoclean 0.09;
use Sigma6::Web;
use aliased 'Sigma6::Config';

resource '/' => (
    get  => \&get_index,
    post => \&post_index,
);

sub get_index {
    my $engine = Config->engine->status;
    my $pkg    = __PACKAGE__;
    return qq[
<html>
    <head><title>$pkg</title></head>
    <body>
        <h1>$$engine{status}</h1>
        <form method="POST" action=""><input type='submit' value='Build Now!'/></form>
        <pre>$$engine{build_status}</pre>
    </body>
</html>    
    ]
}

sub post_index {
    my $response = new_response;
    Config->engine->start_build;
    $response->redirect('/');
    $response->finalize;
}

sub run_psgi { run }

1;
__END__
