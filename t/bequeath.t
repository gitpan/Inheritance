BEGIN { $| = 1; print "1..5\n" }
END { print "not ok 1\n" unless defined $loaded }

use vars qw(@BEQUEST);
use Inheritance qw(&bequeath);

$loaded = 1;
print "ok 1\n";

@BEQUEST = qw(foo bar this that);

$self = new Inheritance;
bequeath $self;

print "not " unless exists $$self{'foo'} && exists $$self{'bar'} &&
    exists $$self{'this'} && exists $$self{'that'} && !exists $$self{'undef'};
print "ok 2\n";

undef $self;

@foo::BEQUEST = ();
@foo::BEQUEST = qw(key foo);

$self = new Inheritance;
bequeath $self, 'foo';

print "not " unless exists $$self{'foo'} && !exists $$self{'bar'} &&
    exists $$self{'key'};
print "ok 3\n";

undef $self;

$self = new Inheritance;
bequeath $self, { 'foo' => 10, 'this' => 'Whoa!' };

print "not " unless exists $$self{'foo'} && exists $$self{'bar'} &&
    exists $$self{'this'} && exists $$self{'that'} && !$$self{'bar'} &&
    $$self{'foo'} == 10 && $$self{'this'} eq 'Whoa!' && !$$self{'that'};
print "ok 4\n";

undef $self;

$self = new Inheritance;
bequeath $self, 'foo', { 'foo' => 'bar' };

print "not " unless exists $$self{'foo'} && $$self{'foo'} eq 'bar' &&
    !exists $$self{'this'} && exists $$self{'key'};
print "ok 5\n";
