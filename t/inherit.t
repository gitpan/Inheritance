BEGIN { $| = 1; print "1..5\n" }
END { print "not ok 1\n" unless defined $loaded }

use vars qw(@ANCESTORS);
use Inheritance qw(&inherit);
$loaded = 1;
print "ok 1\n";

@ANCESTORS = qw(foo bar);

@foo::PUBLIC = @foo::PROTECTED = @bar::BEQUEST = @bar::VOYAGER = @baz::PUBLIC =
    @bar::ANCESTORS = ();

@foo::PUBLIC = qw(that);
@foo::PROTECTED = qw(this);
@bar::BEQUEST = qw(@VOYAGER Janeway);
@bar::VOYAGER = qw(Chakotay Paris Kim etc...);
@bar::ANCESTORS = qw(baz fake);
@baz::PUBLIC = qw(some keys);

$self = new Inheritance;
inherit($self);

print "not " unless scalar(keys %{$self}) == 9;
print "ok 2\n";

undef $self;

$self = new Inheritance;
inherit($self, 'bar');
print "not " unless scalar(keys %{$self}) == 2;
print "ok 3\n";

undef $self;

$self = new Inheritance;
inherit($self, [ 'baz' ]);
print "not " unless scalar(keys %{$self}) == 7;
print "ok 4\n";

undef $self;

$self = new Inheritance;
inherit($self, 'main', [ 'foo' ]);
print "not " unless scalar(keys %{$self}) == 7;
print "ok 5\n";