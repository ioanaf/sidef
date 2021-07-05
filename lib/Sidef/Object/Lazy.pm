package Sidef::Object::Lazy {

    use utf8;
    use 5.016;
    ##use overload q{""} => \&to_a;

    sub new {
        my (undef, %opt) = @_;
        bless {
               calls => [],
               %opt,
              },
          __PACKAGE__;
    }

    sub _xs {
        my ($self, $callback) = @_;

        my $iter = $self->{obj}->iter;

      ITEM: for (; ;) {
            my @arg = ($iter->run() // last);
            foreach my $call (@{$self->{calls}}) {
                @arg = $call->(@arg);
                @arg || next ITEM;
            }
            last if $callback->(@arg);
        }
    }

    sub to_a {
        my ($self) = @_;
        my @arr;
        $self->_xs(sub { push @arr, @_; 0 });
        Sidef::Types::Array::Array->new(\@arr);
    }

    sub each {
        my ($self, $block) = @_;
        $self->_xs(sub { $block->run(@_); 0 });
        $self;
    }

    sub iter {
        my ($self) = @_;

        my $iter = $self->{obj}->iter;

        Sidef::Types::Block::Block->new(
            code => sub {
              ITEM: {
                    my $item = $iter->run() // return undef;
                    my @arg  = ($item);
                    foreach my $call (@{$self->{calls}}) {
                        @arg = $call->(@arg);
                        @arg || redo ITEM;
                    }
                    $arg[0];
                }
            }
        );
    }

    sub first {
        my ($self, $n) = @_;

        if (!defined($n)) {
            my @arr;
            $self->_xs(sub { push(@arr, @_); 1; });
            return $arr[0];
        }

        if (ref($n) eq 'Sidef::Types::Block::Block') {
            return $self->first_by($n);
        }

        $n = CORE::int($n);
        $n > 0 || return Sidef::Types::Array::Array->new([]);

        my @arr;

        $self->_xs(
            sub {
                push @arr, @_;
                @arr >= $n;
            }
        );

        Sidef::Types::Array::Array->new(\@arr);
    }

    sub nth {
        my ($self, $n) = @_;

        my @arr;
        $n = CORE::int($n);
        $n > 0 || return undef;

        $self->_xs(
            sub {
                push @arr, @_;
                @arr >= $n;
            }
        );

        $arr[$n - 1];
    }

    sub first_by {
        my ($self, $block) = @_;
        $self->grep($block)->first(1)->[0];
    }

    #
    ## Functional methods
    #

    sub grep {
        my ($self, $block) = @_;
        __PACKAGE__->new(
            obj   => $self->{obj},
            calls => [
                @{$self->{calls}},
                sub {
                    $block->run($_[0]) ? $_[0] : ();
                },
            ],
        );
    }

    *select = \&grep;

    sub while {
        my ($self, $block) = @_;

        my @arr;

        $self->_xs(
            sub {
                $block->run(@_) ? do { push(@arr, @_); 0 } : 1;
            }
        );

        Sidef::Types::Array::Array->new(\@arr);
    }

    sub map {
        my ($self, $block) = @_;
        __PACKAGE__->new(
            obj   => $self->{obj},
            calls => [
                @{$self->{calls}},
                sub {
                    $block->run($_[0]);
                }
            ],
        );
    }

    *collect = \&map;

    sub lazy {
        my ($self) = @_;
        $self;
    }
}

1;
