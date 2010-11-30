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



{
  my $defaults = { nonsort => NONSORT_CC, clear => 1 };

  sub setup {
    my $params;
    for (@_) {
      if (ref eq 'HASH') {
        $defaults = _prepare($_);
        last;
      }
    }
    return $defaults;
  }
}

sub _prepare {
  my $in = shift;
  my %out;

  if ($in) {
    if (ref $in eq 'HASH') {
      %out = %$in;
    }
    elsif ($in eq 'sort') {
      $out{sort} = SORT_CC;
    }
    elsif ($in ne 'nonsort') {
      die "Unknown param: $in";
    }
  }

  my $defaults = setup;

  for (keys %$defaults) {
    $out{$_} = $defaults->{$_} unless exists $out{$_};
  }

  if (exists $out{nonsort}) {
    if (defined $out{sort}) {
      delete $out{nonsort};
    }
    elsif (!defined $out{nonsort}) {
      delete $out{nonsort};
      $out{sort} = SORT_CC;
    }
  }

  return \%out;
}



sub import {
  my $class = shift;
  return unless @_;

  while (@_) {
    my $name   = shift;
    my $params = shift;

    next unless defined $name;

    if ($name eq '-setup') {
      $class->setup($params);
    }
    else {
      my $caller = caller;
      $params = _prepare($params);

      no strict 'refs';
      *{$caller . '::' . $name} = sub { map { $class->new($_, %$params) } @_ };
    }
  }

}



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
      my ($cc, $sort);

      if (defined($cc = $self->{sort})) {
        $sort = 1;
      }
      else {
        unless (defined($cc = $self->{nonsort})) {
          my $defaults = $self->setup;
          if (defined($cc = $defaults->{sort})) {
            $sort = 1;
          }
          else {
            $cc = $defaults->{nonsort};
          }
        }
      }

      if ((my $index = index $raw, $cc) > -1) {
        if ($sort) {
          if ($index == 0) {
            $self->{display} = substr $raw, 1;
          }
          else {
            $self->{display} = substr($raw, 0, $index++) . substr $raw, $index;
            $self->{sortified} = lc substr $raw, $index;
          }
        }
        else {
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

  my $sortable = String::Sortable->new( '¬The Title of ¬the Thing' );

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
