package Sigma6::Web::PSGI::App;
use Moose;

sub import {
    my $class = shift;
    my %args  = @_;

    if ( $args{'-app'} ) {
        my $app  = $args{'-app'};
        my $pkg  = caller(0);
        my $code = join "\n",
          "package $pkg;",
          "use overload '&{}' => sub { \$_[0]->$app }, fallback => 1;",
          "sub isa {",
          "    return 1 if \$_[1] eq 'Sigma6::Web::PSGI::App';",
          "    shift->SUPER::isa(\@_);",
          "}";

        eval $code;
        Carp::croak("Failed to create isa method: $@") if $@;
    }
}

1;

__END__
