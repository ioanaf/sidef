package Sidef::Object::Object {

    use 5.016;
    use Scalar::Util qw();

    use Sidef;
    use Sidef::Types::Bool::Bool;

    use overload
      q{~~}   => \&{__PACKAGE__ . '::' . '~~'},
      q{bool} => sub {
        if (defined(my $sub = UNIVERSAL::can($_[0], 'to_b'))) {
            @_ = ($_[0]);
            goto $sub;
        }
        $_[0];
      },
      q{0+} => sub {
        if (defined(my $sub = UNIVERSAL::can($_[0], 'to_n'))) {
            @_ = ($_[0]);
            goto $sub;
        }
        $_[0];
      },
      q{""} => sub {
        if (defined(my $sub = UNIVERSAL::can($_[0], 'to_s'))) {
            @_ = ($_[0]);
            goto $sub;
        }
        $_[0];
      },
      q{cmp} => sub {
        my ($obj1, $obj2, $swapped) = @_;

        if (    ref($obj1) eq ref($obj2)
            and ref($obj1) ne 'Sidef::Types::Number::Number'
            and Scalar::Util::refaddr($obj1) == Scalar::Util::refaddr($obj2)) {
            return 0;
        }

        if ($swapped) {
            ($obj1, $obj2) = ($obj2, $obj1);
        }

        if (   CORE::ref($obj1) && UNIVERSAL::isa($obj1, CORE::ref($obj2))
            or CORE::ref($obj2) && UNIVERSAL::isa($obj2, CORE::ref($obj1))) {
            if (defined(my $sub = UNIVERSAL::can($obj1, '<=>'))) {
                @_ = ($obj1, $obj2);
                goto $sub;
            }
        }

#<<<
        (CORE::ref($obj1) ? Scalar::Util::refaddr($obj1) : ('-inf' + 0)) <=>
        (CORE::ref($obj2) ? Scalar::Util::refaddr($obj2) : ('-inf' + 0));
#>>>
      },
      q{eq} => sub {
        my ($obj1, $obj2) = @_;

        if (    ref($obj1) eq ref($obj2)
            and ref($obj1) ne 'Sidef::Types::Number::Number'
            and Scalar::Util::refaddr($obj1) == Scalar::Util::refaddr($obj2)) {
            return 1;
        }

#<<<
        (
             UNIVERSAL::isa($obj1, CORE::ref($obj2) || return 0) ||
             UNIVERSAL::isa($obj2, CORE::ref($obj1) || return 0)
        ) || return 0;
#>>>

        if (defined(my $sub = UNIVERSAL::can($obj1, '=='))) {
            @_ = ($obj1, $obj2);
            goto $sub;
        }

        !CORE::int($obj1 cmp $obj2);
      };

    sub new {
        bless {}, __PACKAGE__;
    }

    sub say {
        (CORE::say @_)
          ? (Sidef::Types::Bool::Bool::TRUE)
          : (Sidef::Types::Bool::Bool::FALSE);
    }

    *println = \&say;

    sub print {
        (CORE::print @_)
          ? (Sidef::Types::Bool::Bool::TRUE)
          : (Sidef::Types::Bool::Bool::FALSE);
    }

    sub lazy {
        my ($self) = @_;
        Sidef::Object::Lazy->new(obj => $self);
    }

    sub method {
        my ($self, $method, @args) = @_;
        Sidef::Object::LazyMethod->new({obj => $self, method => "$method", args => \@args});
    }

    sub object_id {
        my ($self) = @_;
        Sidef::Types::Number::Number->new(Scalar::Util::refaddr($self));
    }

    *refaddr = \&object_id;

    sub object_type {
        my ($self) = @_;
        Sidef::Types::String::String->new(Scalar::Util::reftype($self));
    }

    *reftype = \&object_type;

    sub class {
        my ($obj) = @_;
        my $ref = CORE::ref($obj) || $obj;

        my $rindex = rindex($ref, '::');
        Sidef::Types::String::String->new($rindex == -1 ? $ref : substr($ref, $rindex + 2));
    }

    sub ref {
        my ($obj) = @_;
        Sidef::Types::String::String->new(CORE::ref($obj) || $obj);
    }

    sub bless {
        my ($obj, $arg) = @_;
        CORE::bless($arg, (CORE::ref($obj) || $obj));
    }

    sub clone {
        my ($obj) = @_;

        my $class   = CORE::ref($obj);
        my $reftype = Scalar::Util::reftype($obj);

        if ($reftype eq 'HASH') {
            CORE::bless {%$obj}, $class;
        }
        elsif ($reftype eq 'ARRAY') {
            CORE::bless [@$obj], $class;
        }
        else {
            $obj;
        }
    }

    sub dclone {
        my %addr;    # keeps track of cloned objects

        sub {
            my ($obj, $reftype) = @_;

            my $refaddr = Scalar::Util::refaddr($obj);

            exists($addr{$refaddr})
              and return $addr{$refaddr};

            my $class = Scalar::Util::blessed($obj);

            if (defined($class) and not UNIVERSAL::isa($class, 'Sidef::Object::Object')) {
                $addr{$refaddr} = $obj;
                return $obj;
            }

            if ($reftype eq 'HASH') {
                my $o = defined($class) ? CORE::bless({}, $class) : {};
                $addr{$refaddr} = $o;
                %$o = (
                    map {
                        my $v = $obj->{$_};
                        my $r = Scalar::Util::reftype($v);
                        ($_ => ($r eq 'HASH' || $r eq 'ARRAY' ? __SUB__->($v, $r) : $v))
                      } CORE::keys(%{$obj})
                );
                $o;
            }
            elsif ($reftype eq 'ARRAY') {
                my $o = defined($class) ? CORE::bless([], $class) : [];
                $addr{$refaddr} = $o;
                @$o = (
                    map {
                        my $r = Scalar::Util::reftype($_);
                        $r eq 'ARRAY' || $r eq 'HASH' ? __SUB__->($_, $r) : $_
                      } @{$obj}
                );
                $o;
            }
            else {
                $obj;
            }
          }
          ->($_[0], Scalar::Util::reftype($_[0]));
    }

    sub respond_to {
        my ($self, $method) = @_;
        UNIVERSAL::can($self, "$method")
          ? (Sidef::Types::Bool::Bool::TRUE)
          : (Sidef::Types::Bool::Bool::FALSE);
    }

    sub is_a {
        my ($self, $obj) = @_;
        UNIVERSAL::isa($self, "$obj")
          ? (Sidef::Types::Bool::Bool::TRUE)
          : (Sidef::Types::Bool::Bool::FALSE);
    }

    *is_an   = \&is_a;
    *kind_of = \&is_a;

    sub parent_classes {
        my ($obj) = @_;

        no strict 'refs';

        my %seen;
        my $extract_parents;
        $extract_parents = sub {
            my ($ref) = @_;

            my @parents = @{${$ref . '::'}{ISA}};

            if (@parents) {
                foreach my $parent (@parents) {
                    next if $seen{$parent}++;
                    push @parents, $extract_parents->($parent);
                }
            }

            @parents;
        };

        Sidef::Types::Array::Array->new([map { Sidef::Types::String::String->new($_) } $extract_parents->(CORE::ref($obj))]);
    }

    sub interpolate {
        my $self = shift(@_);
        $self->new(CORE::join('', @_));
    }

    sub dump {
        my %addr;    # keep track of dumped objects

        my $sub = sub {
            my ($obj) = @_;

            my $refaddr = Scalar::Util::refaddr($obj);

            exists($addr{$refaddr})
              and return $addr{$refaddr};

            my $type = Sidef::normalize_type(CORE::ref($obj) ? CORE::ref($obj) : $obj);
            Scalar::Util::reftype($obj) eq 'HASH' or return $type;
            my @keys = CORE::sort CORE::keys(%{$obj});

            my $str = Sidef::Types::String::String->new($type . "(#`($refaddr)...)");
            $addr{$refaddr} = $str;

            $$str = (
                "$type(" . CORE::join(
                    ', ',
                    map {
                        my $str = UNIVERSAL::can($obj->{$_}, 'dump') ? $obj->{$_}->dump : "$obj->{$_}";
                        "$_: $str";
                      } @keys
                  )
                  . ')'
            );

            $str;
        };

        local *Sidef::Object::Object::dump = $sub;
        $sub->($_[0]);
    }

    {
        no strict 'refs';

        sub def_method {
            my ($self, $name, $block) = @_;
            *{(CORE::ref($self) ? CORE::ref($self) : $self) . '::' . $name} = sub {
                $block->call(@_);
            };
            $self;
        }

        sub undef_method {
            my ($self, $name) = @_;
            delete ${(CORE::ref($self) ? CORE::ref($self) : $self) . '::'}{$name};
            $self;
        }

        sub alias_method {
            my ($self, $old, $new) = @_;

            my $ref = (CORE::ref($self) ? CORE::ref($self) : $self);
            my $to = \&{$ref . '::' . $old};

            if (not defined &$to) {
                die "[ERROR] Can't alias the nonexistent method '$old' as '$new'!";
            }

            *{$ref . '::' . $new} = $to;
        }

        sub methods {
            my ($self) = @_;

            my %alias;
            my %methods;
            my $ref = CORE::ref($self);
            foreach my $method (grep { $_ !~ /^[(_]/ and defined(&{$ref . '::' . $_}) } keys %{$ref . '::'}) {
                $methods{$method} = (
                                     $alias{\&{$ref . '::' . $method}} //=
                                       Sidef::Object::LazyMethod->new(
                                                                      {
                                                                       obj    => $self,
                                                                       method => $method,
                                                                      }
                                                                     )
                                    );
            }

            Sidef::Types::Hash::Hash->new(%methods);
        }

        # Logical AND
        *{__PACKAGE__ . '::' . '&&'} = sub {
            $_[0] ? $_[1] : $_[0];
        };

        # Logical OR
        *{__PACKAGE__ . '::' . '||'} = sub {
            $_[0] ? $_[0] : $_[1];
        };

        # Logical XOR
        *{__PACKAGE__ . '::' . '^'} = sub {
            ($_[0] xor $_[1])
              ? (Sidef::Types::Bool::Bool::TRUE)
              : (Sidef::Types::Bool::Bool::FALSE);
        };

        # Defined-OR
        *{__PACKAGE__ . '::' . '\\\\'} = sub {
            defined($_[0]) ? $_[1] : $_[0];
        };

        # Smart match operator
        *{__PACKAGE__ . '::' . '~~'} = sub {
            my ($first, $second, $swapped) = @_;

            if ($swapped) {
                ($first, $second) = ($second, $first);
            }

            # First is String
            if (UNIVERSAL::isa($first, 'Sidef::Types::String::String')) {

                # String ~~ RangeString
                if (UNIVERSAL::isa($second, 'Sidef::Types::Range::RangeString')) {
                    return $second->contains($first);
                }

                # String ~~ String
                if (CORE::ref($first) eq CORE::ref($second)) {
                    return $second->eq($first);
                }
            }

            # First is Number
            if (UNIVERSAL::isa($first, 'Sidef::Types::Number::Number')) {

                # Number ~~ RangeNumber
                if (UNIVERSAL::isa($second, 'Sidef::Types::Range::RangeNumber')) {
                    return $second->contains($first);
                }
            }

            # First is RangeNumber
            if (UNIVERSAL::isa($first, 'Sidef::Types::Range::RangeNumber')) {

                # RangeNumber ~~ Number
                if (UNIVERSAL::isa($second, 'Sidef::Types::Number::Number')) {
                    return $first->contains($second);
                }
            }

            # First is RangeString
            if (UNIVERSAL::isa($first, 'Sidef::Types::Range::RangeString')) {

                # RangeString ~~ String
                if (UNIVERSAL::isa($second, 'Sidef::Types::String::String')) {
                    return $first->contains($second);
                }
            }

            # First is Array
            if (UNIVERSAL::isa($first, 'Sidef::Types::Array::Array')) {

                # Array ~~ Array
                if (CORE::ref($first) eq CORE::ref($second)) {
                    return $first->eq($second);
                }

                # Array ~~ Regex
                if (UNIVERSAL::isa($second, 'Sidef::Types::Regex::Regex')) {
                    return $first->match($second);
                }

                # Array ~~ Hash
                if (UNIVERSAL::isa($second, 'Sidef::Types::Hash::Hash')) {
                    return $second->keys->contains_all($first);
                }

                # Array ~~ Any
                if (!UNIVERSAL::isa($second, 'Sidef::Types::Array::Array')) {
                    return $first->contains($second);
                }
            }

            # First is Hash
            if (UNIVERSAL::isa($first, 'Sidef::Types::Hash::Hash')) {

                # Hash ~~ Array
                if (UNIVERSAL::isa($second, 'Sidef::Types::Array::Array')) {
                    return $second->contains_all($first->keys);
                }

                # Hash ~~ Hash
                if (CORE::ref($first) eq CORE::ref($second)) {
                    return $second->eq($first->keys);
                }

                # Hash ~~ Regex
                if (UNIVERSAL::isa($second, 'Sidef::Types::Regex::Regex')) {
                    return $first->keys->match($second);
                }

                # Hash ~~ Any
                if (!UNIVERSAL::isa($second, 'Sidef::Types::Hash::Hash')) {
                    return $first->exists($second);
                }
            }

            # First is Regex
            if (UNIVERSAL::isa($first, 'Sidef::Types::Regex::Regex')) {

                # Regex ~~ Regex
                if (CORE::ref($first) eq CORE::ref($second)) {
                    return $first->eq($second);
                }

                # Regex ~~ Array
                if (UNIVERSAL::isa($second, 'Sidef::Types::Array::Array')) {
                    return $second->match($first);
                }

                # Regex ~~ Hash
                if (UNIVERSAL::isa($second, 'Sidef::Types::Hash::Hash')) {
                    return $second->keys->match($first);
                }

                # Regex ~~ Any
                if (!UNIVERSAL::isa($second, 'Sidef::Types::Regex::Regex')) {
                    return $first->match($second)->is_successful;
                }
            }

            # Second is Array
            if (UNIVERSAL::isa($second, 'Sidef::Types::Array::Array')) {

                # Any ~~ Array
                return $second->contains($first);
            }

            # Second is Hash
            if (UNIVERSAL::isa($second, 'Sidef::Types::Hash::Hash')) {

                # Any ~~ Hash
                return $second->exists($first);
            }

            # Second is Regex
            if (UNIVERSAL::isa($second, 'Sidef::Types::Regex::Regex')) {
                return $second->match($first)->is_successful;
            }

            my $bool = $first eq $second;
#<<<
            CORE::ref($bool) ? $bool : (
                       $bool ? Sidef::Types::Bool::Bool::TRUE
                             : Sidef::Types::Bool::Bool::FALSE
            );
#>>>
        };

        # Negation of smart match
        *{__PACKAGE__ . '::' . '!~'} = sub {
            state $method = '~~';
            $_[0]->$method($_[1])->neg;
        };
    }
}

1;
