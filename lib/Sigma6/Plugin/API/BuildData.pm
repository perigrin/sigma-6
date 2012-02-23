package Sigma6::Plugin::API::BuildData;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: API for BuildData Plugins

sub build_data { return $_[1]  }

1;
__END__

=head1 SYNOPSIS 

    package Sigma6::Plugin::Git;
    use Moose;
    use namespace::autoclean;

    extends qw(Sigma6::Plugin);

    with qw(
        Sigma6::Plugin::API::BuildData
    );

    sub build_data {
        my ( $self, $data ) = @_;
        confess 'Not Valid Build Data'
            unless Scalar::Util::reftype $data eq 'HASH';
        
        return unless exists $data->{target};
        return unless $data->{target} =~ m/^git@|\.git/;

        return Sigma6::Model::Build->new(
            target => $data->{target},
            type   => 'git'
        );
    }

=head1 DESCRIPTION

BuildData plugins take the input parameters from the Web application and
return a configured Sigma6::Model::Build. This model can be a stub.

=head1 REQUIRED METHODS

=over 4

=item build_data ($HashRef) Sigma6::Model::Build

Takes a HashRef and returns a Sigma6::Model::Build.

=back

