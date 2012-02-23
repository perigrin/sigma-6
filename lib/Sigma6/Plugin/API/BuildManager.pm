package Sigma6::Plugin::API::BuildManager;
use Moose::Role;
use namespace::autoclean;

with qw(
    Sigma6::Plugin::API::CheckBuild
    Sigma6::Plugin::API::StartBuild
    Sigma6::Plugin::API::StoreBuild
);

1;
__END__

=head1 SYNOPSIS

    package Sigma6::Plugin::BuildManager::Simple;
    use Moose;
    use namespace::autoclean;

    extends qw(Sigma6::Plugin);
    
    has builds => (
        isa     => 'HashRef',
        traits  => ['Hash'],
        handles => {
            get_build    => 'get',
            builds       => 'elements',
            store_build  => 'set',
            update_build => 'set',
            clear_build  => 'delete',
        },
    );
    
    with qw( Sigma6::Plugin::API::BuildManager );

    sub check_all_builds {
        my $self  = shift;
        my $scope = $self->model->new_scope;
        $self->log( trace => 'BuildManager checking all builds' );
        return map { $self->check_build($_) } $self->builds->all;
    }

    sub check_build {
        my ( $self, $build ) = @_;
        $self->log( trace => 'BuildManager checking build' );
        $build->status(
            $self->first_from_plugin_with(
                '-CheckSmoker' => sub { $_[0]->check_smoker($build) }
            )
        );
        $self->update_build($build);
        return $build;
    }

    sub start_build {
        my ( $self, $build ) = @_;

        $self->first_from_plugin_with(
            '-EnqueueBuild' => sub { $_[0]->push_build($build) } );
            
        $self->first_from_plugin_with(
            '-StartSmoker' => sub { $_[0]->start_smoker() } );

        return $build;
    }

=head1 DESCRIPTION

The BuildManager Plugins store and manage the builds. They can keep track of
existing builds as well as start new builds in the system.

=head1 SEE ALSO

=over 4

=item L<Sigma6::Plugin::API::CheckBuild>

=item L<Sigma6::Plugin::API::StartBuild>

=item L<Sigma6::Plugin::API::StoreBuild>

=back