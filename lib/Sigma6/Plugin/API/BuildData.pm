package Sigma6::Plugin::API::BuildData;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Turne baubles into trinkets

sub build_data { return $_[1]  }

1;
__END__
