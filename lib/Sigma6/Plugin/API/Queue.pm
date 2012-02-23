package Sigma6::Plugin::API::Queue;
use Moose::Role;

with qw(
    Sigma6::Plugin::API::EnqueueBuild
    Sigma6::Plugin::API::DequeueBuild
);

1;
__END__

=head1 SYNOPSIS

    package Sigma6::Plugin::Queue::Simple;
    use Moose;
    
    extends qw(Sigma6::Plugin);
    
    with qw(Sigma6::Plugin::API::Queue);

    has queue => (
        isa     => 'ArrayRef',
        traits  => ['Array'],
        handles => {
            push_build  => 'push',
            fetch_build => 'shift'
        },
    );

=head1 DESCRIPTION

API for a Queue to feed between the front end process (typically the Web
Application) and the backend process (typically an instance of
Sigma6::Smoker).

=head1 SEE ALSO 

=over 4

=item L<Sigma6::Plugin::API::EnqueueBuild>

=item L<Sigma6::Plugin::API::DequeueBuild>

=back
