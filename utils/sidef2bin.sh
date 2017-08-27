#!/bin/bash

# Package Sidef as a binary executable
# Requires: App::Packer::PAR

/usr/bin/site_perl/pp --execute --unicode --lib=../lib -M Sidef::Types::Bool::Bool -M Sidef -M Sidef::Parser -M Sidef::Optimizer -M Sidef::Object::Object -M Sidef::Types::Number::Number -M Sidef::Deparse::Perl -M Sidef::Types::Block::Block -M Memoize -M Sidef::Types::Number::Complex -M Sidef::Types::Array::Array -M Sidef::Types::Hash::Hash -M Sidef::Perl::Perl -M Sidef::Sys::Sys -M Sidef::Math::Math -M Sidef::Types::String::String -M Sidef::Types::Range::RangeNumber -M Sidef::Types::Range::RangeString -M Sidef::Types::Glob::File -M Sidef::Types::Glob::Dir -M Sidef::Types::Glob::FileHandle -M Sidef::Types::Glob::DirHandle -M Sidef -M Sidef::Types::Regex::Regex -M Sidef::Types::Regex::Match -M Sidef::Module::Func -M Sidef::Module::OO -M Sidef::Sys::Sig -M Sidef::Time::Time -M Sidef::Time::Localtime -M Sidef::Time::Gmtime -M Sidef::Object::LazyMethod -M Sidef::Variable::NamedParam -M Sidef::Convert::Convert -M Sidef::Types::Null::Null -M Sidef::Types::Glob::Backtick -M Sidef::Types::Glob::Pipe -M Sidef::Types::Glob::Socket -M Sidef::Types::Glob::SocketHandle -M Sidef::Types::Glob::Stat -M Sidef::Types::Block::Fork -M Sidef::Types::Block::Try -M Sidef::Types::Array::Pair -M Sidef::Types::Array::MultiArray -M Sidef::Deparse::Sidef -M experimental -M base -M File::Spec -M File::Temp -M File::Basename -M File::Compare -M Cwd -M Time::HiRes -M Scalar::Util -M Socket -M Encode -M Fcntl -M POSIX -M File::Find -M File::Copy -M File::Path -M utf8 -M List::Util -M Math::MPFR -M Math::GMPz -M Math::GMPq -M Math::MPC -M Sidef::Object::Lazy -M Sidef::Object::Enumerator -M charnames -M bytes -M Data::Dump -M Data::Dump::Filtered -M Sidef::Types::Range::Range -M Getopt::Long -M Term::ReadLine -M Term::ReadLine::Gnu::XS -M Digest::MD5 -M Digest::SHA -M Algorithm::Combinatorics -M Algorithm::Loops -o sidef.out -z 9 -c ../bin/sidef
