package String::Sortable;

use 5.006;

use strict;
use warnings FATAL => 'all';

our $VERSION = '0.00_02';

$VERSION = eval $VERSION;

use constant NONSORT_CC   => chr(172); # ¬
use constant SORT_CC      => '@';
use constant EMPTY_STRING => q{};

use overload fallback => 1,
  '""'  => 'display',
  'cmp' => 'compare',
  'eq'  => 'equals',
  'ne'  => sub { ! shift->equals(shift) };



#
#  constructor
#

sub new {
  my $class = shift;
  unshift @_, 'raw' if @_ % 2;
  my %param = @_;
  bless \%param, $class;
}



#
#  public methods
#

sub display {
  my $self = shift;
  return exists $self->_parse->{display} ? $self->{display} : $self->{raw};
}



sub sortify {
  my $self = shift;
  return exists $self->_parse->{sortified} ? $self->{sortified} :
    exists $self->{display} ? lc $self->{display} : lc $self->{raw};
}



sub compare {
  my ($self, $other, $reversed) = @_;
  my $result = $self->sortify cmp
    ( eval { $other->isa(__PACKAGE__) } ? $other->sortify : $other );
  return $reversed ? $result * -1 : $result;
}



sub equals {
  my ($self, $other) = @_;
  return $self->display eq
    ( eval { $other->isa(__PACKAGE__) } ? $other->display : $other );
}



#
#  private methods
#

{
  my %_cache;

  sub _parse {
    my $self = shift;
    return $self if $self->{_parsed}++;

    if (! defined(my $raw = $self->{raw}) ) {
      $self->{display} = EMPTY_STRING;
    }
    else {
      my $nonsort_cc = $self->{nonsort} unless defined(my $sort_cc = $self->{sort});

      unless (defined $sort_cc) {
        my $cc = defined $nonsort_cc ? $nonsort_cc : NONSORT_CC;

        if (index($raw, $cc) > -1) {
          my $pattern = $_cache{$cc} ||= do {
            $cc = quotemeta $cc;
            qr{
              $cc
              ( [[:alnum:]]*    # any alphanumerical character
                [ .]?           # optional space or full stop
                (?:'(?=$cc))?   # optional apostrophe, if followed by the control character
              )
              (?: (?<=')$cc )?  # control character, if preceeded by apostrophe
              ( [^$cc]* )       # anything except the control character
            }x
          };

          my $display = my $sortified = EMPTY_STRING;
          while ($raw =~ s/$pattern//) {
            $display .= $1 . $2;
            $sortified .= $2;
          }
          $self->{display} = $display;
          $self->{sortified} = lc $sortified;
          return $self;
        }
      }

      unless (defined $nonsort_cc) {
        my $cc = defined $sort_cc ? $sort_cc : SORT_CC;

        if ((my $index = index $raw, $cc) > -1) {
          if ($index == 0) {
            $self->{display} = substr $raw, 1;
          }
          else {
            $self->{display} = substr($raw, 0, $index++) . substr $raw, $index;
            $self->{sortified} = lc substr $raw, $index;
          }
        }
      }


    }

    return $self
  }

} # end of scope of %_cache



1;

__END__

=head1 NAME

String::Sortable - Perl class for strings containing sorting information

=head1 SYNOPSIS

  use String::Sortable;

  my $sortable = String::Sortable->new( 'The @Title' );

  printf "Display: %s\n", $sortable->display;  # The Title
  printf "Sortify: %s\n", $sortable->sortify;  # title

  $sortable = String::Sortable->new( '¬The Title of ¬the Thing' );

  printf "Display: %s\n", $sortable->display;  # The Title of the Thing
  printf "Sortify: %s\n", $sortable->sortify;  # title of thing

=head1 DESCRIPTION

TODO.

=head1 CONSTRUCTOR

=over 4

=item $sortable = String::Sortable->new(%options);

Creates a new C<String::Sortable> object and returns it.

=item $sortable = String::Sortable->new($raw_string);

=item $sortable = String::Sortable->new($raw_string, %options);

=back

=head1 METHODS

=over 4

=item $display   = $sortable->display;

=item $sortified = $sortable->sortify;

=item $result    = $sortable->compare($thing);

=item $boolean   = $sortable->equals($thing);

=back

=head1 TODO

=over 4

=item * Documentation

=item * C<%options>

=back

=head1 AUTHOR

Henning Manske <hma@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2010 Henning Manske. All rights reserved.

This module is free software. You can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/>.

This module is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
