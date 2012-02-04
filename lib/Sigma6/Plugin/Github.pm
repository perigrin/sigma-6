package Sigma6::Plugin::Github;
use Moose;
use namespace::autoclean;

# ABSTRACT: Turn baubles into trinkets

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::BuildData);

sub build_data {
	my ($self, $data) = @_;
	$data = $data->{payload};
	return {
		'Git.target' => $data->{repository}{url},
	}
}

__PACKAGE__->meta->make_immutable;
1;
__END__
