
# This module is used to require all the project modules at once.

# Generated by:
# find . | perl -nE 'chomp; if(s/\.pm\z//){s{^\./}{};s{/}{::}g; say "require Sidef::$_ if [caller]->[0] ne q{Sidef::$_};"}'

use 5.014;
use strict;
use warnings;

use lib '..';

require Sidef::Convert::Convert if [caller]->[0] ne q{Sidef::Convert::Convert};
require Sidef::Base if [caller]->[0] ne q{Sidef::Base};
require Sidef::Init if [caller]->[0] ne q{Sidef::Init};
require Sidef::Utils::Regex if [caller]->[0] ne q{Sidef::Utils::Regex};
require Sidef::Types::Byte::Bytes if [caller]->[0] ne q{Sidef::Types::Byte::Bytes};
require Sidef::Types::Byte::Byte if [caller]->[0] ne q{Sidef::Types::Byte::Byte};
require Sidef::Types::Hash::Hash if [caller]->[0] ne q{Sidef::Types::Hash::Hash};
require Sidef::Types::Array::Array if [caller]->[0] ne q{Sidef::Types::Array::Array};
require Sidef::Types::Char::Chars if [caller]->[0] ne q{Sidef::Types::Char::Chars};
require Sidef::Types::Char::Char if [caller]->[0] ne q{Sidef::Types::Char::Char};
require Sidef::Types::Glob::Dir if [caller]->[0] ne q{Sidef::Types::Glob::Dir};
require Sidef::Types::Glob::File if [caller]->[0] ne q{Sidef::Types::Glob::File};
require Sidef::Types::Glob::Pipe if [caller]->[0] ne q{Sidef::Types::Glob::Pipe};
require Sidef::Types::Glob::FileHandle if [caller]->[0] ne q{Sidef::Types::Glob::FileHandle};
require Sidef::Types::Glob::PipeHandle if [caller]->[0] ne q{Sidef::Types::Glob::PipeHandle};
require Sidef::Types::Block::Code if [caller]->[0] ne q{Sidef::Types::Block::Code};
require Sidef::Types::Nil::Nil if [caller]->[0] ne q{Sidef::Types::Nil::Nil};
require Sidef::Types::Number::Integer if [caller]->[0] ne q{Sidef::Types::Number::Integer};
require Sidef::Types::Number::Number if [caller]->[0] ne q{Sidef::Types::Number::Number};
require Sidef::Types::Number::Float if [caller]->[0] ne q{Sidef::Types::Number::Float};
require Sidef::Types::String::Double if [caller]->[0] ne q{Sidef::Types::String::Double};
require Sidef::Types::String::String if [caller]->[0] ne q{Sidef::Types::String::String};
require Sidef::Types::Bool::Bool if [caller]->[0] ne q{Sidef::Types::Bool::Bool};
require Sidef::Types::Bool::Ternary if [caller]->[0] ne q{Sidef::Types::Bool::Ternary};
require Sidef::Types::Regex::Regex if [caller]->[0] ne q{Sidef::Types::Regex::Regex};
require Sidef::Exec if [caller]->[0] ne q{Sidef::Exec};
require Sidef::Parser if [caller]->[0] ne q{Sidef::Parser};
require Sidef::Variable::Variable if [caller]->[0] ne q{Sidef::Variable::Variable};



1;
