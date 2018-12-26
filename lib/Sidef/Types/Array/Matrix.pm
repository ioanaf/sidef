package Sidef::Types::Array::Matrix {

    use utf8;
    use 5.016;

    use parent qw(Sidef::Types::Array::Array);

    require List::Util;

    my %array_like = (
                      'Sidef::Types::Array::Array'  => 1,
                      'Sidef::Types::Array::Matrix' => 1,
                      'Sidef::Types::Array::Pair'   => 1,
                     );

    sub new {
        my (undef, @rows) = @_;
        bless [map { bless [@$_], 'Sidef::Types::Array::Array' } @rows];
    }

    *call = \&new;

    sub build {
        my (undef, $n, $m, $block) = @_;

        $n = CORE::int($n);

        if (ref($m) eq 'Sidef::Types::Block::Block') {
            ($m, $block) = ($n, $m);
        }
        else {
            $m = CORE::int($m);
        }

#<<<
        bless [
            map {
                my $i = Sidef::Types::Number::Number->_set_uint($_);
                bless([map {
                    $block->run(
                        $i, Sidef::Types::Number::Number->_set_uint($_)
                    );
                } 0 .. $m-1], 'Sidef::Types::Array::Array')
            } 0 .. $n-1
        ];
#>>>
    }

    sub identity {
        my (undef, $n) = @_;

        $n = CORE::int($n);

        bless [
            map {
                bless(
                      [(Sidef::Types::Number::Number::ZERO) x ($_ - 1),
                       Sidef::Types::Number::Number::ONE,
                       (Sidef::Types::Number::Number::ZERO) x ($n - $_)
                      ],
                      'Sidef::Types::Array::Array'
                     )
              } 1 .. $n
        ];
    }

    *I = \&identity;

    sub zero {
        my (undef, $n, $m) = @_;

        $n = CORE::int($n);
        $m = defined($m) ? CORE::int($m) : $n;

#<<<
        bless [
            map {
                bless([(Sidef::Types::Number::Number::ZERO) x $m], 'Sidef::Types::Array::Array')
            } 1 .. $n
        ];
#>>>
    }

    sub rand {
        my (undef, $n, $m) = @_;

        $n = CORE::int($n);
        $m = defined($m) ? CORE::int($m) : $n;

#<<<
        bless [
            map {
                bless([map {
                    (Sidef::Types::Number::Number::ONE)->rand
                } 1 .. $m], 'Sidef::Types::Array::Array')
            } 1 .. $n
        ];
#>>>
    }

    sub scalar {
        my (undef, $n, $value) = @_;

        $n = CORE::int($n);

        bless [
            map {
                bless(
                      [(Sidef::Types::Number::Number::ZERO) x ($_ - 1),
                       $value,
                       (Sidef::Types::Number::Number::ZERO) x ($n - $_)
                      ],
                      'Sidef::Types::Array::Array'
                     )
              } 1 .. $n
        ];
    }

    sub row_vector {
        my (undef, @list) = @_;
        bless [bless(\@list, 'Sidef::Types::Array::Array')];
    }

    sub column_vector {
        my (undef, @list) = @_;
        bless [map { bless([$_], 'Sidef::Types::Array::Array') } @list];
    }

    *col_vector = \&column_vector;

    sub diagonal {
        my (undef, @diag) = @_;

        my $n = scalar(@diag);

        bless [
            map {
                bless(
                      [(Sidef::Types::Number::Number::ZERO) x ($_ - 1),
                       CORE::shift(@diag),
                       (Sidef::Types::Number::Number::ZERO) x ($n - $_)
                      ],
                      'Sidef::Types::Array::Array'
                     )
              } 1 .. $n
        ];
    }

    sub rows {
        my (undef, @rows) = @_;

        bless [map { bless([@$_], 'Sidef::Types::Array::Array') } @rows];
    }

    sub columns {
        my (undef, @cols) = @_;

        my $max = List::Util::max(map { scalar(@$_) } @cols);

        bless [
            map {
                my $i = $_;
                bless [map { $_->[$i] } @cols], 'Sidef::Types::Array::Array'
              } 0 .. $max - 1
        ];
    }

    *cols = \&columns;

    sub neg {
        my ($m1) = @_;
        bless($m1->scalar_operator('neg'));
    }

    sub abs {
        my ($m1) = @_;
        bless($m1->scalar_operator('abs'));
    }

    sub add {
        my ($m1, $m2) = @_;

        if (exists $array_like{ref($m2)}) {
            return bless($m1->wise_operator('+', $m2));
        }

        bless($m1->scalar_operator('+', $m2));
    }

    sub sub {
        my ($m1, $m2) = @_;

        if (exists $array_like{ref($m2)}) {
            return bless($m1->wise_operator('-', $m2));
        }

        bless($m1->scalar_operator('-', $m2));
    }

    sub div {
        my ($m1, $m2) = @_;

        if (exists $array_like{ref($m2)}) {
            return $m1->mul($m2->inv);
        }

        bless($m1->scalar_operator('/', $m2));
    }

    sub mul {
        my ($m1, $m2) = @_;

        if (not exists $array_like{ref($m2)}) {
            return bless($m1->scalar_operator('*', $m2));
        }

        my @a = map { [@$_] } @$m1;
        my @b = map { [@$_] } @$m2;

        my @c;

        my $a_rows = $#a;
        my $b_rows = $#b;
        my $b_cols = $#{$b[0]};

        foreach my $i (0 .. $a_rows) {
            foreach my $j (0 .. $b_cols) {
                foreach my $k (0 .. $b_rows) {

                    my $t = $a[$i][$k]->mul($b[$k][$j]);

                    if (!defined($c[$i][$j])) {
                        $c[$i][$j] = $t;
                    }
                    else {
                        $c[$i][$j] = $c[$i][$j]->add($t);
                    }
                }
            }
        }

        bless($_, 'Sidef::Types::Array::Array') for @c;
        bless \@c;
    }

    sub map {
        my ($A, $block) = @_;

        my %indices;

        my @new;
        foreach my $i (0 .. $#{$A}) {

            my @row;
            my $r = $A->[$i];

            $indices{$i} //= Sidef::Types::Number::Number->_set_uint($i);

            foreach my $j (0 .. $#{$A->[$i]}) {
                $indices{$j} //= Sidef::Types::Number::Number->_set_uint($j);
                push @row, $block->run($r->[$j], $indices{$i}, $indices{$j});
            }

            CORE::push(@new, bless(\@row, 'Sidef::Types::Array::Array'));
        }

        bless \@new;
    }

    sub sum {
        my ($A, $block) = @_;
        Sidef::Math::Math->sum(map { $_->SUPER::sum($block) } @$A);
    }

    sub prod {
        my ($A, $block) = @_;
        Sidef::Math::Math->prod(map { $_->SUPER::prod($block) } @$A);
    }

    sub pow {
        my ($A, $pow) = @_;

        $pow = CORE::int($pow);
        my $neg = ($pow < 0);
        $pow = CORE::int(CORE::abs($pow));

        return $A->inv if ($neg and $pow == 1);

#<<<
        my $n = $#$A;
        my $B = bless [map {
            my $i = $_;
            (bless [map {
                $i == $_
                    ? Sidef::Types::Number::Number::ONE
                    : Sidef::Types::Number::Number::ZERO
            } 0 .. $n], 'Sidef::Types::Array::Array')
        } 0 .. $n];
#>>>

        return $B if ($pow == 0);

        while (1) {
            $B = $B->mul($A) if ($pow & 1);
            $pow >>= 1 or last;
            $A = $A->mul($A);
        }

        $neg ? $B->inv : $B;
    }

    # Code translated from Wikipedia (+ minor tweaks):
    #   https://en.wikipedia.org/wiki/LU_decomposition#C_code_examples

    sub _LUP_decompose {
        my ($self) = @_;

        my @A = map { [@$_] } @$self;
        my $N = $#A;
        my @P = (0 .. $N + 1);

        foreach my $i (0 .. $N) {

            my $maxA = Sidef::Types::Number::Number::ZERO;
            my $imax = $i;

            foreach my $k ($i .. $N) {
                my $absA = ($A[$k][$i] // return ($N, \@A, \@P))->abs;

                if ($absA->gt($maxA)) {
                    $maxA = $absA;
                    $imax = $k;
                }
            }

            if ($imax != $i) {

                @P[$i, $imax] = @P[$imax, $i];
                @A[$i, $imax] = @A[$imax, $i];

                ++$P[$N + 1];
            }

            foreach my $j ($i + 1 .. $N) {

                if ($A[$i][$i]->is_zero) {
                    return ($N, \@A, \@P);
                }

                $A[$j][$i] = $A[$j][$i]->div($A[$i][$i]);

                foreach my $k ($i + 1 .. $N) {
                    $A[$j][$k] = $A[$j][$k]->sub($A[$j][$i]->mul($A[$i][$k]));
                }
            }
        }

        return ($N, \@A, \@P);
    }

    sub solve {
        my ($self, $vector) = @_;

        my ($N, $A, $P) = $self->_LUP_decompose;

        my @x = map { $vector->[$P->[$_]] } 0 .. $N;

        foreach my $i (1 .. $N) {
            foreach my $k (0 .. $i - 1) {
                $x[$i] = $x[$i]->sub($A->[$i][$k]->mul($x[$k]));
            }
        }

        for (my $i = $N ; $i >= 0 ; --$i) {
            foreach my $k ($i + 1 .. $N) {
                $x[$i] = $x[$i]->sub($A->[$i][$k]->mul($x[$k]));
            }
            $x[$i] = $x[$i]->div($A->[$i][$i]);
        }

        bless(\@x, 'Sidef::Types::Array::Array');
    }

    sub invert {
        my ($self) = @_;

        my ($N, $A, $P) = $self->_LUP_decompose;

        my @I;

        foreach my $j (0 .. $N) {
            foreach my $i (0 .. $N) {

                $I[$i][$j] = (
                              ($P->[$i] == $j)
                              ? Sidef::Types::Number::Number::ONE
                              : Sidef::Types::Number::Number::ZERO
                             );

                foreach my $k (0 .. $i - 1) {
                    $I[$i][$j] = $I[$i][$j]->sub($A->[$i][$k]->mul($I[$k][$j]));
                }
            }

            for (my $i = $N ; $i >= 0 ; --$i) {
                foreach my $k ($i + 1 .. $N) {
                    $I[$i][$j] = $I[$i][$j]->sub($A->[$i][$k]->mul($I[$k][$j]));
                }

                $I[$i][$j] = $I[$i][$j]->div($A->[$i][$i] // return bless [bless([], 'Sidef::Types::Array::Array')]);
            }
        }

        bless($_, 'Sidef::Types::Array::Array') for @I;
        bless \@I;
    }

    *inv     = \&invert;
    *inverse = \&invert;

    sub determinant {
        my ($self) = @_;

        my ($N, $A, $P) = $self->_LUP_decompose;

        my $det = $A->[0][0] // return Sidef::Types::Number::Number::ONE;

        foreach my $i (1 .. $N) {
            $det = $det->mul($A->[$i][$i]);
        }

        if (($P->[$N + 1] - $N) % 2 == 0) {
            $det = $det->neg;
        }

        return $det;
    }

    *det = \&determinant;

    # Reduced row echelon form
    sub rref {
        my ($self) = @_;

        my @m = map { [@$_] } @$self;

        @m || return bless [];

        my ($j, $rows, $cols) = (0, scalar(@m), scalar(@{$m[0]}));

      OUTER: foreach my $r (0 .. $rows - 1) {

            $j < $cols or last;

            my $i = $r;

            while ($m[$i][$j]->is_zero) {
                ++$i == $rows or next;
                $i = $r;
                ++$j == $cols and last OUTER;
            }

            @m[$i, $r] = @m[$r, $i];

            my $mr  = $m[$r];
            my $mrj = $mr->[$j];

            foreach my $k (0 .. $cols - 1) {
                $mr->[$k] = $mr->[$k]->div($mrj);
            }

            foreach my $i (0 .. $rows - 1) {

                $i == $r and next;

                my $mr  = $m[$r];
                my $mi  = $m[$i];
                my $mij = $mi->[$j];

                foreach my $k (0 .. $cols - 1) {
                    $mi->[$k] = $mi->[$k]->sub($mij->mul($mr->[$k]));
                }
            }

            ++$j;
        }

        bless($_, 'Sidef::Types::Array::Array') for @m;
        bless \@m;
    }

    *reduced_row_echelon_form = \&rref;

    sub gauss_jordan_invert {
        my ($self) = @_;

        my $n = $#$self;

        my @I = map {
            [(Sidef::Types::Number::Number::ZERO) x $_,
             Sidef::Types::Number::Number::ONE,
             (Sidef::Types::Number::Number::ZERO) x ($n - $_)
            ]
        } 0 .. $n;
        my @A = map { [@{$self->[$_]}, @{$I[$_]}] } 0 .. $n;

        my $r = rref(\@A);
        @A = map { bless([@{$_}[$n + 1 .. $#$_]], 'Sidef::Types::Array::Array') } @$r;
        bless \@A;
    }

    sub gauss_jordan_solve {
        my ($self, $vector) = @_;

        my @A = map { [@{$self->[$_]}, $vector->[$_]] } 0 .. $#$vector;

        my $r = rref(\@A);
        bless([map { $_->[-1] } @$r], 'Sidef::Types::Array::Array');
    }

    sub det_bareiss {
        my ($self) = @_;

        my @m = map { [@$_] } @$self;

        my $neg   = 0;
        my $pivot = Sidef::Types::Number::Number::ONE;
        my $end   = $#m;

        foreach my $k (0 .. $end) {
            my @r = ($k + 1 .. $end);

            my $prev_pivot = $pivot;
            $pivot = $m[$k][$k] // return Sidef::Types::Number::Number::ONE;

            if ($pivot eq Sidef::Types::Number::Number::ZERO) {
                my $i = List::Util::first(sub { $m[$_][$k] }, @r) // return Sidef::Types::Number::Number::ZERO;
                @m[$i, $k] = @m[$k, $i];
                $pivot = $m[$k][$k];
                $neg ^= 1;
            }

            foreach my $i (@r) {
                foreach my $j (@r) {
                    $m[$i][$j] = $m[$i][$j]->mul($pivot);
                    $m[$i][$j] = $m[$i][$j]->sub($m[$i][$k]->mul($m[$k][$j]));
                    $m[$i][$j] = $m[$i][$j]->div($prev_pivot);
                }
            }
        }

        $neg ? $pivot->neg : $pivot;
    }

    sub transpose {
        my ($matrix) = @_;
        bless($matrix->SUPER::transpose);
    }

    *t   = \&transpose;
    *not = \&transpose;

    sub set_row {
        my ($A, $k, $row) = @_;
        $k = CORE::int($k);
        $A->[$k] = bless([@$row], 'Sidef::Types::Array::Array');
        $A;
    }

    sub set_column {
        my ($A, $k, $col) = @_;

        $k = CORE::int($k);

        foreach my $i (0 .. $#{$col}) {
            $A->[$i][$k] = $col->[$i];
        }

        $A;
    }

    *set_col = \&set_column;

    sub column_count {
        my ($A) = @_;
        @$A || return Sidef::Types::Number::Number::ZERO;
        Sidef::Types::Number::Number->_set_uint(scalar @{$A->[0]});
    }

    *column_len  = \&column_count;
    *column_size = \&column_count;
    *col_size    = \&column_count;
    *col_count   = \&column_count;
    *col_len     = \&column_count;

    sub row_count {
        my ($A) = @_;
        Sidef::Types::Number::Number->_set_uint(scalar @$A);
    }

    *row_len  = \&row_count;
    *row_size = \&row_count;

    {
        no strict 'refs';

        *{__PACKAGE__ . '::' . '*'}  = \&mul;
        *{__PACKAGE__ . '::' . '**'} = \&pow;
        *{__PACKAGE__ . '::' . '+'}  = \&add;
        *{__PACKAGE__ . '::' . '-'}  = \&sub;
        *{__PACKAGE__ . '::' . '/'}  = \&div;
        *{__PACKAGE__ . '::' . '÷'}  = \&div;
    }
};

1
