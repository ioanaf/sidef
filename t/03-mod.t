#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 4;

use Sidef;

my $o = 'Sidef::Types::Number::Number';

my $m = $o->new(5);
my $x = ($o->new(100)->fac->add($m));
my $y = $o->new(23);

{
    my $r = $o->new('1234.45')->mod($o->new('43.56'));
    is($r->as_frac->get_value, '1477/100');
}

{
    my $r = $o->new('-1234.45')->mod($o->new('-43.56'));
    is($r->as_frac->get_value, '-1477/100');
}

{
    my $r = $o->new('1234.45')->mod($o->new('-43.56'));
    is($r->as_frac->get_value, '-2879/100');
}

{
    my $r = $o->new('-1234.45')->mod($o->new('43.56'));
    is($r->as_frac->get_value, '2879/100');
}

##################################################
# extreme

#~ my $inf  = $o->inf;
#~ my $nan  = $o->nan;
#~ my $ninf = $o->ninf;

#~ is($x->mod($inf),            $x);
#~ is($x->neg->mod($inf),       $inf);
#~ is($x->mod($ninf),           $ninf);
#~ is($x->neg->mod($ninf),      $x->neg);
#~ is($inf->mod($x),            $nan);
#~ is($ninf->mod($x),           $nan);
#~ is($inf->mod($inf),          $nan);
#~ is($ninf->mod($inf),         $nan);
#~ is($ninf->mod($ninf),        $nan);
#~ is($inf->mod($nan),          $nan);
#~ is($ninf->mod($nan),         $nan);
#~ is($nan->mod($inf),          $nan);
#~ is($x->mod($o->new(0)),      $nan);
#~ is($y->neg->mod($o->new(0)), $nan);
