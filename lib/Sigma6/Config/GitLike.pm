package Sigma6::Config::GitLike;
use Moose;
use namespace::autoclean;

# ABSTRACT: Config::Gitlike Configuration for Sigma6

extends qw(Config::GitLike);

with qw(Sigma6::Config);

use File::Spec;
use Moose::Util::TypeConstraints;

has '+confname' => ( default => 'sigma6.ini' );

has sections => (
    isa     => 'ArrayRef',
    traits  => ['Array'],
    default => sub { [] },
    handles => {
        add_section => 'push',
        sections    => 'elements',
    },
);

sub dir_file {
    my $self = shift;
    return $self->confname;
}

sub user_file {
    my $self = shift;
    my $name = $self->confname;
    $name =~ s/.ini$//;
    return File::Spec->catfile( $ENV{'HOME'}, ".$name" );
}

around 'define' => sub {
    my ( $next, $self, %args ) = @_;
    $self->add_section( $args{section} ) if $args{section};
    $self->$next(%args);
};

after load => sub { $_[0]->add_plugins( $_[0]->sections ) };

sub dump { Moose::Object::dump(@_) }

sub get_section_config {
    my ( $self, $key ) = @_;
    my $cfg = $self->get_regexp( key => qr/^$key/ );
    return {} unless $cfg;
    for ( keys %$cfg ) {
        ( my $k = $_ ) =~ s/^$key\.//;
        $cfg->{$k} = delete $cfg->{$_};
    }
    return $cfg;
}

### OVERRIDE ####

# Because Config::Gitlike isn't broken up enough in the way it parses config
# files, I have to override the parser and the get() method so that we can have
# uppercase section names passed to define

# This is an ugly ugly UGLY hack until I can think how to do this properly

sub parse_content {
    my $self = shift;
    my %args = (
        content  => '',
        callback => sub { },
        error    => sub { },
        @_,
    );
    my $c = $args{content};
    return if !$c;    # nothing to do if content is empty
    my $length = length $c;

    my $section_regex
        = $self->compatible
        ? qr/\A\[([0-9a-z.-]+)(?:[\t ]*"([^\n]*?)")?\]/im
        : qr/\A\[([^\s\[\]"]+)(?:[\t ]*"([^\n]*?)")?\]/im;

    my $key_regex
        = $self->compatible
        ? qr/\A([a-z][0-9a-z-]*)[\t ]*(?:[#;].*)?$/im
        : qr/\A([^\[=\n][^=\n]*?)[\t ]*(?:[#;].*)?$/im;

    my $key_value_regex
        = $self->compatible
        ? qr/\A([a-z][0-9a-z-]*)[\t ]*=[\t ]*/im
        : qr/\A([^\[=\n][^=\n]*?)[\t ]*=[\t ]*/im;

    my ( $section, $prev ) = ( undef, '' );
    while (1) {

        # drop leading white space and blank lines
        $c =~ s/\A\s*//im;

        my $offset = $length - length($c);

        # drop to end of line on comments
        if ( $c =~ s/\A[#;].*?$//im ) {
            next;
        }

       # [sub]section headers of the format [section "subsection"] (with
       # unlimited whitespace between) or [section.subsection] variable
       # definitions may directly follow the section header, on the same line!
       # - rules for sections: not case sensitive, only alphanumeric
       #   characters, -, and . allowed
       # - rules for subsections enclosed in ""s: case sensitive, can
       #   contain any character except newline, " and \ must be escaped
       # - rules for subsections with section.subsection alternate syntax:
       #   same rules as for sections
        elsif ( $c =~ s/$section_regex// ) {
            $section = $1;
            if ($2) {
                my $subsection = $2;
                my $check      = $2;
                $check =~ s{\\\\}{}g;
                $check =~ s{\\"}{}g;
                return $args{error}->(
                    content => $args{content},
                    offset  => $offset,

                    # don't allow quoted subsections to contain unescaped
                    # double-quotes or backslashes
                ) if $check =~ /\\|"/;

                $subsection =~ s{\\\\}{\\}g;
                $subsection =~ s{\\"}{"}g;
                $section .= ".$subsection";
            }

            $args{callback}->(
                section => $section,
                offset  => $offset,
                length  => ( $length - length($c) ) - $offset,
            );
        }

        # keys followed by a unlimited whitespace and (optionally) a comment
        # (no value)
        #
        # for keys, we allow any characters that won't screw up the parsing
        # (= and newline) in non-compatible mode, and match non-greedily to
        # allow any trailing whitespace to be dropped
        #
        # in compatible mode, keys can contain only 0-9a-z-
        elsif ( $c =~ s/$key_regex// ) {
            $args{callback}->(
                section => $section,
                name    => lc $1,
                offset  => $offset,
                length  => ( $length - length($c) ) - $offset,
            );
        }

        # key/value pairs (this particular regex matches only the key part and
        # the =, with unlimited whitespace around the =)
        elsif ( $c =~ s/$key_value_regex// ) {
            my $name  = lc $1;
            my $value = "";

            # parse the value
            while (1) {

                # comment or no content left on line
                if ( $c =~ s/\A([ \t]*[#;].*?)?$//im ) {
                    last;
                }

               # any amount of whitespace between words becomes a single space
                elsif ( $c =~ s/\A[\t ]+//im ) {
                    $value .= ' ';
                }

                # line continuation (\ character followed by new line)
                elsif ( $c =~ s/\A\\\r?\n//im ) {
                    next;
                }

                # escaped backslash characters is translated to actual \
                elsif ( $c =~ s/\A\\\\//im ) {
                    $value .= '\\';
                }

                # escaped quote characters are part of the value
                elsif ( $c =~ s/\A\\(['"])//im ) {
                    $value .= $1;
                }

                # escaped newline in config is translated to actual newline
                elsif ( $c =~ s/\A\\n//im ) {
                    $value .= "\n";
                }

                # escaped tab in config is translated to actual tab
                elsif ( $c =~ s/\A\\t//im ) {
                    $value .= "\t";
                }

               # escaped backspace in config is translated to actual backspace
                elsif ( $c =~ s/\A\\b//im ) {
                    $value .= "\b";
                }

                # quote-delimited value (possibly containing escape codes)
                elsif (
                    $c =~ s/\A"([^"\\]*(?:(?:\\\n|\\[tbn"\\])[^"\\]*)*)"//im )
                {
                    my $v = $1;

                    # remove all continuations (\ followed by a newline)
                    $v =~ s/\\\n//g;

                    # swap escaped newlines with actual newlines
                    $v =~ s/\\n/\n/g;

                    # swap escaped tabs with actual tabs
                    $v =~ s/\\t/\t/g;

                    # swap escaped backspaces with actual backspaces
                    $v =~ s/\\b/\b/g;

                    # swap escaped \ with actual \
                    $v =~ s/\\\\/\\/g;
                    $value .= $v;
                }

                # valid value (no escape codes)
                elsif ( $c =~ s/\A([^\t \\\n"]+)//im ) {
                    $value .= $1;

                    # unparseable
                }
                else {

                    # Note that $args{content} is the _original_
                    # content, not the nibbled $c, which is the
                    # remaining unparsed content
                    return $args{error}->(
                        content => $args{content},
                        offset  => $offset,
                    );
                }
            }
            $args{callback}->(
                section => $section,
                name    => $name,
                value   => $value,
                offset  => $offset,
                length  => ( $length - length($c) ) - $offset,
            );
        }

        # end of content string; all done now
        elsif ( not length $c ) {
            last;
        }

        # unparseable
        else {

            # Note that $args{content} is the _original_ content, not
            # the nibbled $c, which is the remaining unparsed content
            return $args{error}->(
                content => $args{content},
                offset  => $offset,
            );
        }
    }
}

use DDP;

sub get_regexp {
    my $self = shift;

    my %args = (
        key    => undef,
        filter => undef,
        as     => undef,
        @_,
    );

    $self->load unless $self->is_loaded;

    $args{key} = $args{key};

    my %results;
    for my $key ( keys %{ $self->data } ) {
        $results{$key} = $self->data->{$key} if lc $key =~ m/$args{key}/i;
    }
    if ( defined $args{filter} ) {
        if ( $args{filter} =~ s/^!// ) {
            map { delete $results{$_} if $results{$_} =~ m/$args{filter}/i }
                keys %results;
        }
        else {
            map { delete $results{$_} if $results{$_} !~ m/$args{filter}/i }
                keys %results;
        }
    }

    @results{ keys %results }
        = map { $self->cast( value => $results{$_}, as => $args{as} ); }
        keys %results;
    return wantarray ? %results : \%results;
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME 

Sigma6::Config::GitLike

=head1 DESCRIPTION

A subclass of L<Config::GitLike> that hooks into the L<Sigma6> plugin system.

