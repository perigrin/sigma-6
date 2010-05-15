package Sigma6::Server;
use Moose 1.01;
our $VERISON = '0.01';
use namespace::autoclean 0.09;
use Sigma6::Web;
use Sigma6::Config;

use Sub::Exporter::ForMethods qw( method_installer );
use Data::Section { installer => method_installer },
  -setup => { default_name => 'index' };
use Template::Tiny;

resource '/' => (
    get  => \&get_index,
    post => \&post_index,
);

sub get_index {
    my $template = __PACKAGE__->section_data('index');
    my $conf     = {
        manager => manager->status,
        name    => __PACKAGE__,
    };
    Template::Tiny->new->process( $template, $conf, \my $output );
    return $output;
}

sub post_index {
    my $response = new_response;
    manager->start_build;
    $response->redirect('/');
    $response->finalize;
}

sub run_psgi { run }

1;
__DATA__
<html>
    <head><title>[% name %]</title></head>
    <body>
        <h1>[% manager.repo %]</h1>
        <h2>[% manager.status %]</h2>
        <form method="POST" action=""><input type='submit' value='Build Now!'/></form>
        <pre>[% manager.build_status %]</pre>
    </body>
</html>
