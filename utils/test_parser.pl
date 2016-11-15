#!/usr/bin/perl

use 5.010;
use strict;
use autodie;
use warnings FATAL => 'all';
use Test::More;

no warnings 'once';

use File::Find qw(find);
use List::Util qw(first);
use File::Spec::Functions qw(catfile catdir updir);

use lib catdir(updir(), 'lib');
require Sidef;

my $scripts_dir = catdir(updir(), 'scripts');

my @scripts;
find {
    no_chdir => 1,
    wanted   => sub {
        if (/\.sf\z/) {
            push @scripts, $_;
        }
    },
} => $scripts_dir;

plan tests => (scalar(@scripts) * 2);

foreach my $sidef_script (@scripts) {

    my $content = do {
        open my $fh, '<:utf8', $sidef_script;
        local $/;
        <$fh>;
    };

    my $sidef = Sidef->new(name => $sidef_script);
    my $ast = $sidef->parse_code($content);

    is(ref($ast), 'HASH', $sidef_script);

    my $optimizer = Sidef::Optimizer->new();
    my $oast      = $optimizer->optimize($ast);

    my $code = $sidef->compile_ast($oast, 'Perl');

    ok($code ne '', $sidef_script);
}