# Copyright (C) 1997 Ashley Winters <jql@accessone.com>. All rights reserved.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.

package Inheritance;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);

use Tie::Hash::Overlay qw(&overlay);
use Tie::Hash::Static;
require Exporter;

@ISA = qw(Exporter Tie::Hash::Overlay);

@EXPORT_OK = qw(&inherit &bequeath &overlay);

$VERSION = '0.01';

sub inherit {
    my $self = shift;
    my $class = (!@_ || ref $_[0]) ? (caller())[0] : shift;
    my @ANCESTORS;

#    no strict 'refs';
#    @ANCESTORS = @{$class . "::ANCESTORS"};
#    use strict 'refs';

#    my $stash = \%::;                         # This is black magic
#    foreach(split /::/, $class) {
#	$stash = exists $$stash{$_ . '::'} ? \%{$$stash{$_ . '::'}} : {};
#    }

    my $stash = fetch_stash($class);  # just a little experiment, chill out
    @ANCESTORS = 
	exists $$stash{'ANCESTORS'} && defined @{$$stash{'ANCESTORS'}} ?
	    @{$$stash{'ANCESTORS'}} : ();

    my $ignore = @_ ? $_[0] : [];
    my $ancestor;
    foreach $ancestor (@ANCESTORS) {
	next if grep {$_ eq $ancestor} @$ignore;
	push @$ignore, $ancestor;

	unless($ancestor eq $class) {
	    inherit($self, $ancestor, $ignore);
	    bequeath($self, $ancestor);
	} else {
	    my $tiedhash = {};
	    tie(%{$tiedhash}, $ancestor, $self);
	    bequeath($self, $ancestor, $tiedhash);
	}
    }
}

sub bequeath {
    my $self = shift;
    my $caller = (!@_ || ref $_[0]) ? (caller)[0] : shift;
    my $stash = fetch_stash($caller);
    my @elements = ();
    my @BEQUEST;

    if(exists $$stash{'BEQUEST'} && defined @{$$stash{'BEQUEST'}}) {
	@BEQUEST = @{$$stash{'BEQUEST'}};
    } else { @BEQUEST = qw(@PUBLIC @PROTECTED) }

    foreach(@BEQUEST) {
	if(/^\@/) {
	    my $name = $';
	    my @elems = exists $$stash{$name} && defined @{$$stash{$name}} ?
		@{$$stash{$name}} : next;
	    @elements = (@elements, @elems);

#	    if(@elements) {
#		splice @elements, -1, 1, $elements[$#elements], @elems;
#	    } else { @elements = @elems }
	} else { push @elements, $_ }
    }
    overlay($self, new Tie::Hash::Static(\@elements, @_));
}

sub fetch_stash {	# Fetch a stash for sinister purposes.
    my $class = shift;  # Low-level knowledge of Perl should probably
    my $stash = \%::;	# never be used in this way. Oh well.

    foreach(split('::', $class)) {
        $stash = exists $$stash{$_ . '::'} ? \%{$$stash{$_ . '::'}} : {};
    }

    return $stash;
}

1;
__END__

=head1 NAME

Inheritance - Perl module for OO data inheritance

=head1 SYNOPSIS

  use Inheritance qw(&bequeath &inherit);

  $self = new Inheritance;
  inherit($self [, $classname] [, $ignore]);
  bequeath($self [, $classname] [, $overlay]);

=head1 DESCRIPTION

This is meant to be the class by which all future Perl data inheritance
is carried out. I hope it will be to data inheritance what Exporter is
to data/function exporting. This module has a minimal amount of coding
for the maximal amount of usefulness.

The Inheritance class is derived from Tie::Hash::Overlay, and the constructor
function is not overridden, so see L<Tie::Hash::Overlay(3)> for the format
of new().

The inherit() function reads the @ANCESTORS array in the class and runs
inherit() and bequeath() for each element. The first argument should be
the object to be modified (which had been previously returned by
new Inheritance). If you pass $classname, it will be used as the name of the
class to retrieve @ANCESTORS from instead of the value returned by
C<(caller())[0]>. The $ignore parameter should be an array ref containing a
list of classes that should not be accessed if found in an @ANCESTORS array.
This argument is modified, to prevent infinite recursion within inherit().
If a class' own name is found in its @ANCESTORS array, 
C<tie(%hash, $class, $self);> is run, with \%hash being passed as the
third argument to bequeath().

The bequeath() function has the important job. It reads the @BEQUEST array
and uses the elements as the names of the other arrays that should be searched
to find the names of the member variables. If no @BEQUEST variable is
defined in the class, it is defaulted to C<qw(@PUBLIC @PROTECTED)>. If an array
element in @BEQUEST isn't an array-name, it is assumed to be the name of a
member variable.

If the $classname argument is passed, it will be used as the class-name to
be worked on instead of C<(caller())[0]>. The $overlay argument is a hash
that will be accessed to gain the value of member variables. The $overlay
argument is passed directly to the Tie::Hash::Static constructor, so read
L<Tie::Hash::Static(3)>.

=head1 AUTHOR

Ashley Winters <jql@accessone.com>

=head1 SEE ALSO

perl(1), perltie(1), perlref(1), Tie::Hash::Static(3), Tie::Hash::Overlay(3).

=cut
