package Peri;
use strict;
use warnings FATAL => 'all';
no warnings 'redefine';

use Test::More;
use Test::Deep 'eq_deeply';
use Term::ANSIColor 'color';
use MonkeyPatch;

BEGIN {
    use Exporter();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
    @ISA = qw(Exporter);
    @EXPORT = qw(
        describe xdescribe fdescribe
        it xit fit

        expect

        spyOn

        done_testing note explain diag pass fail

        using xusing afterEach beforeEach

        createSpyObj
        );
    @EXPORT_OK = @EXPORT;
}

our %MOCK_DATA = (
    'DUMMY_CLASS_NAME' => 'Peri::Dummy',
    'PREFIX' => [],
    'SPY_OBJECT_COUNTER' => 0,
    'STORED_TESTS' => [],
    'TESTS' => [],
    'SPIES' => {},
);

sub using {
    my ($dataProvider, $providerContent) = @_;
    my $testCase = $MOCK_DATA{TESTS}->[-1];
    my $providerData = $dataProvider->();

    for my $key (sort keys %{$providerData}) {
        $testCase->{currentProviderName} = $key;
        $providerContent->(@{$providerData->{$key}});
    }

    $testCase->{currentProviderName} = undef;
}

sub xusing {}

sub afterEach {
    my ($sub) = @_;
    $MOCK_DATA{TESTS}->[-1]->{afterEach} = (ref($sub) eq 'CODE'? $sub : undef);
}

sub beforeEach {
    my ($sub) = @_;
    $MOCK_DATA{TESTS}->[-1]->{beforeEach} = (ref($sub) eq 'CODE'? $sub : undef);
}

#@returns Peri::Spy
sub createSpyObj {
    my ($className, $methodArrays) = @_;

    my $classFullName = $MOCK_DATA{DUMMY_CLASS_NAME}.'::Obj'.($MOCK_DATA{SPY_OBJECT_COUNTER}++).'::'.$className;

    my %calls = ();
    for my $method (@{$methodArrays}) {
        $calls{$method} = spyOn($classFullName.'::'.$method);
    }
    return bless(\%calls, $classFullName);
}

sub describe {
    my ($suiteName, $suiteContent) = @_;

    if (scalar @{$MOCK_DATA{TESTS}}) {
        push @{$MOCK_DATA{PREFIX}}, $suiteName;
        $suiteContent->();
        pop @{$MOCK_DATA{PREFIX}};
    }
    else {
        push @{$MOCK_DATA{STORED_TESTS}},
            {
                'name'    => $suiteName,
                'content' => $suiteContent
            };
    }
}

sub xdescribe {

}

sub fdescribe {
    my ($suiteName, $suiteContent) = @_;
    push @{$MOCK_DATA{STORED_TESTS}},
        {
            'name'    => $suiteName,
            'content' => $suiteContent,
            'focused' => 1
        };
    fail 'fdescribe is not supported for nested structure' if (scalar @{$MOCK_DATA{TESTS}});
}

sub it {
    my ($testName, $testContent) = @_;
    my $testCase = $MOCK_DATA{TESTS}->[-1];
    my $providerName = $testCase->{currentProviderName};

    my $prefix = (join ' / ', @{$MOCK_DATA{PREFIX}});
    push @{ $testCase->{tests} },
        {
            'name' =>  ( $prefix ? $prefix.' ': '' ) .
                $testName .
                (defined($providerName) ? ' / '.$providerName : ''),
        };

    if (ref($testCase->{beforeEach}) eq 'CODE') {
        $testCase->{beforeEach}->();
    }
    $testContent->();
    if (ref($testCase->{afterEach}) eq 'CODE') {
        $testCase->{afterEach}->();
    }
}

sub xit {

}

sub fit {
    fail 'fit is not supported.';
}

#@returns Peri
sub expect {
    my $actual = shift;
    my $check = bless { 'actual' => $actual, 'not' => 0, 'name' => $MOCK_DATA{TESTS}->[-1]->{tests}->[-1]->{name} }, 'Peri';
    #    push @{ $TEMP->{checks} }, $check;

    if (defined $actual) {
        my $testData = {
            name => $MOCK_DATA{TESTS}->[-1]->{tests}->[-1]->{name},
            not => 0,
            type => ''
        };

        if (ref($actual) eq 'Peri::Spy') {
            $actual->{test} = $testData;
            return $actual;
        }

        if (index(ref($actual), $MOCK_DATA{DUMMY_CLASS_NAME}) == 0) {
            my $method = shift;
            $testData->{object} = $actual;
            $actual->{$method}->{test} = $testData;
            return $actual->{$method};
        }

        if ( defined($MOCK_DATA{SPIES}->{$actual}) ) {
            $MOCK_DATA{SPIES}->{$actual}->{test} = $testData;
            return $MOCK_DATA{SPIES}->{$actual};
        }
    }

    return $check;
}

#@returns Peri
sub and {
    my $self = shift;
    return $self;
}

#@returns Peri
sub not {
    my $self = shift;
    $self->{not} = !$self->{not};
    return $self;
}

#@returns Peri
sub toBe {
    my $self = shift;
    my $expected = shift;

    fail('Please use ARRAYREF in `expect` and put only 1 REF / scalar in `toBe` for matching') if scalar @_;

    $self->{'expected'} = $expected;
    $self->{'type'} = 'toBe';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeDefined {
    my $self = shift;
    $self->{'expected'} = 1;
    $self->{'type'} = 'toBeDefined';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeLessThan {
    my $self = shift;
    my $expected = shift;
    $self->{'expected'} = $expected;
    $self->{'type'} = 'toBeLessThan';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeGreaterThan {
    my $self = shift;
    my $expected = shift;
    $self->{'expected'} = $expected;
    $self->{'type'} = 'toBeGreaterThan';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeCloseTo {
    my $self = shift;
    my $expected = shift;
    my $precision = shift;
    $self->{'expected'} = $expected;
    $self->{'type'} = 'toBeCloseTo';
    $self->{'params'} = $precision;
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeTruthy {
    my $self = shift;
    $self->{'type'} = 'toBeTruthy';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeFalsy {
    my $self = shift;
    $self->{'not'} = !$self->{'not'};
    $self->{'type'} = 'toBeTruthy';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeUndefined {
    my $self = shift;
    $self->{'expected'} = 0;
    $self->{'type'} = 'toBeDefined';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toBeNull {
    return toBeUndefined @_;
}

#@returns Peri
sub toContain {
    my $self = shift;
    my $expected = shift;
    $self->{'expected'} = $expected;
    $self->{'type'} = 'toContain';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri
sub toEqual {
    return toBe @_;
}

#@returns Peri
sub toMatch {
    my $self = shift;
    my $expected = shift;
    $expected = qr/$expected/ if (ref($expected) ne 'regex');
    $self->{'expected'} = $expected;
    $self->{'type'} = 'toMatch';
    Peri::Runner::run($self);
    return $self;
}

#@returns Peri::Spy
sub spyOn {
    my $name = shift;

    if (scalar(@_) == 1) {
        my $method = shift;
        if (index(ref($name), $MOCK_DATA{DUMMY_CLASS_NAME}) == 0) {
            return $name->{$method};
        } elsif(ref($name) !~ m/^(CODE|GLOB|HASH|ARRAY|REF|SCALAR)$/) {
            $name = ref($name).'::'.$method;
        }
    }

    return Peri::Spy->new($name);
}

# Spy Functions

#@returns Peri::Spy
sub toHaveBeenCalled {
    my $self = shift;
    fail ( "$self->{name}: You have not Spied on $self->{actual}.\nPlease spyOn it before checking how it is called." );
    return $self;
}

#@returns Peri::Spy
sub toHaveBeenCalledTimes { toHaveBeenCalled @_; }

#@returns Peri::Spy
sub toHaveBeenCalledWith { toHaveBeenCalled @_; }

sub done_testing {
    my $devMode = shift || 0;
    Peri::Runner::__flush($devMode);
    Test::More::done_testing();
}

sub note { Test::More::note @_; }
sub explain { Test::More::explain @_; }
sub diag { Test::More::diag @_; }
sub pass(;$) { Test::More::pass(shift); }
sub fail(;$) { Test::More::fail(shift); }

package Peri::SpyCalls;

sub new {
    my $class = shift;
    my ($callsName, $callsReference) = @_;
    my $spyCalls = bless {
            'name' => $callsName,
            'calls' => $callsReference,
        }, $class;
    return $spyCalls;
}

sub mostRecent {
    my $self = shift;

    my $object = undef;
    my @args = @{$self->{calls}->[-1]};
    if (index($self->{name}, $Peri::MOCK_DATA{DUMMY_CLASS_NAME}) == 0 && index(ref($args[0]), $Peri::MOCK_DATA{DUMMY_CLASS_NAME}) == 0) {
        $object = splice(@args, 0, 1);
    }

    return {'object'=>$object, 'args' => [@args]};
}

sub argsFor {
    my $self = shift;
    my ($index) = @_;

    my @args = @{ $self->{calls}->[$index] };
    if (
           substr( $self->{name}, -5 ) eq '::new'
        || (
               index( $self->{name}, $Peri::MOCK_DATA{DUMMY_CLASS_NAME} ) == 0
            && index( ref($args[0]), $Peri::MOCK_DATA{DUMMY_CLASS_NAME} ) == 0
           )
    ) {
        @args = splice(@args, 1);
    }
    return [@args];
}

package Peri::Spy;
use Test::More;

#@returns Peri::Spy
sub new {
    my $class = shift;
    my $name = shift;
    my $spy = bless {
            'name' => $name,
            'called_times' => 0,
            'called_params' => [],
            'sub' => sub {},
            'return' => '',
        }, $class;
    $Peri::MOCK_DATA{SPIES}->{$name} = $spy;
    MonkeyPatch::patch(
        $name => sub {
            my $self = $Peri::MOCK_DATA{SPIES}->{$name};
            $self->{called_times}++;
            push @{$self->{called_params}}, [@_];
            return $self->{sub}->(@_);
        }
    );
    return $spy;
}

#@returns Peri::SpyCalls
sub calls {
    my $self = shift;
    return Peri::SpyCalls->new($self->{name}, $self->{called_params});
}

#@returns Peri::Spy
sub and {
    my $self = shift;
    return $self;
}

#@returns Peri::Spy
sub not {
    my $self = shift;
    $self->{test}->{not} = !$self->{test}->{not};
    return $self;
}

#@returns Peri::Spy
sub callFake {
    my $self = shift;
    my $sub = shift;
    $self->{sub} = sub {
        return $sub->(@_);
    };
    return $self;
}

#@returns Peri::Spy
sub callThrough {
    my $self = shift;
    my $name = $self->{name};
    $self->{sub} = sub {
        return MonkeyPatch::runOriginal($name, @_);
    };
    return $self;
}

#@returns Peri::Spy
sub returnInput {
    my $self = shift;
    return $self->callFake(sub{ wantarray ? @_ : $_[0] });
}

#@returns Peri::Spy
sub returnValue {
    my $self = shift;
    $self->{return} = [@_];

    my $name = $self->{name};
    $self->{sub} = sub {
        my $s = $Peri::MOCK_DATA{SPIES}->{$name};
        return wantarray ? @{$s->{return}} : $s->{return}->[0];
    };
    return $self;
}

#@returns Peri::Spy
sub returnValues {
    my $self = shift;
    $self->{return} = [@_];

    my $name = $self->{name};
    $self->{sub} = sub {
        my $s = $Peri::MOCK_DATA{SPIES}->{$name};
        my $returnValues = shift @{$s->{return}};
        return $returnValues ? (wantarray ? @{$returnValues} : $returnValues->[0]) : undef;
    };
    return $self;
}

#@returns Peri::Spy
sub stub {
    my $self = shift;
    $self->{sub} = sub { };
    return $self;
}

#@returns Peri::Spy
sub toBeDefined {
    my $self = shift;
    no strict 'refs';
    $self->{test}->{'actual'} = *{$self->{name}};
    use strict 'refs';
    $self->{test}->{'expected'} = 1;
    $self->{test}->{'type'} = 'toBeDefined';
    Peri::Runner::run($self->{test});
    return $self;
}

#@returns Peri::Spy
sub toHaveBeenCalled {
    my $self = shift;
    $self->{test}->{actual} = $self->{called_times};
    $self->{test}->{type} = 'toBeTruthy';
    Peri::Runner::run($self->{test});
    return $self;
}

#@returns Peri::Spy
sub toHaveBeenCalledTimes {
    my $self = shift;
    my $expected = shift;
    $self->{test}->{actual} = $self->{called_times};
    $self->{test}->{expected} = $expected;
    $self->{test}->{type} = 'toBe';
    Peri::Runner::run($self->{test});
    return $self;
}

#@returns Peri::Spy
sub toHaveBeenCalledWith {
    my $self = shift;
    my @expected = @_;

    if (index($self->{name}, $Peri::MOCK_DATA{DUMMY_CLASS_NAME}) == 0) {
        unshift @expected, $self->{test}->{object};
    }
    elsif ( substr($self->{name}, -5) eq '::new' ) {
        unshift @expected, substr($self->{name}, 0, -5);
    }

    $self->{test}->{actual} = $self->{called_params};
    $self->{test}->{type} = 'toContain';
    $self->{test}->{expected} = [[@expected]];
    Peri::Runner::run($self->{test});
    return $self;
}

package Peri::Runner;
use Test::More;

sub new {

}

sub __flush {
    my $devMode = shift;
    my @focused_tests = grep { $_->{focused} } @{$Peri::MOCK_DATA{STORED_TESTS}};
    my @tests = scalar @focused_tests? @focused_tests : @{$Peri::MOCK_DATA{STORED_TESTS}};
    for my $suite (@tests) {
        # convert to real tests
        push @{$Peri::MOCK_DATA{TESTS}},
            {
                'name'   => $suite->{name},
                'tests'  => [ ],
                'ftests'  => [ ],
                'beforeEach' => undef,
                'afterEach' => undef,
            };
        $suite->{tests} = [];
        $suite->{ftests} = [];
        MonkeyPatch::unpatchAll();
        unless ($devMode) {
            # Kill all unexpected queries
            MonkeyPatch::patch(
                'DBI::db::prepare' => sub {
                    shift;
                    fail('Calling unexpected query '.shift);
                },
            );
        }
        local $Test::Builder::Level = $Test::Builder::Level + 2;
        subtest $suite->{name} => sub { $suite->{content}->(); done_testing(); };
        #        __unpack ($suite);
    }
}

# no support for fit
#sub __unpack {
#    my $suite = $Peri::MOCK_DATA{TESTS}->[-1];
#    my @tests = scalar @{ $suite->{ftests} }? @{ $suite->{ftests} } : @{ $suite->{tests} } ;
#    for my $test (@tests) {
#        #        $TEMP = $test;
#        $test->{content}->();
#        #        __run ($test);
#    }
#}

my %mock_run = (
    toBe => sub {
        my ($name, $self) = (shift, shift);
        __switch ( $self->{not}, Test::Deep::eq_deeply($self->{actual}, $self->{expected}), $name,
            sub {
                sprintf( "Fail!\nReason: %sExpecting this:\n%s\n%sto equal this:\n%s",
                    Term::ANSIColor::color('cyan'),
                    explain $self->{actual} // 'undef',
                    Term::ANSIColor::color('cyan'),
                    explain $self->{expected} // 'undef'
                );
            },
            sub {
                sprintf( "Fail!\nReason: %sBoth values equal this:\n%s",
                    Term::ANSIColor::color('cyan'),
                    explain $self->{actual} // 'undef'
                );
            }
        );
        return $self;
    },
    toBeDefined => sub {
        my ($name, $self) = (shift, shift);
        __switch ($self->{not}, defined($self->{actual}) == $self->{expected}, $name);
        return $self;
    },
    toBeLessThan => sub {
        my ($name, $self) = (shift, shift);
        __switch(
            $self->{not},
            $self->{actual} < $self->{expected},
            $name
        );
    },
    toBeGreaterThan => sub {
        my ($name, $self) = (shift, shift);
        __switch(
            $self->{not},
            $self->{actual} > $self->{expected},
            $name
        );
    },
    toBeCloseTo => sub {
        my ($name, $self) = (shift, shift);
        my $p = $self->{params};
        __switch(
            $self->{not},
            sprintf( '%.'.$p.'g', $self->{actual} ) eq sprintf( '%.'.$p.'g', $self->{expected} ),
            $name
        );
    },
    toBeTruthy => sub {
        my ($name, $self) = (shift, shift);
        __switch ($self->{not}, $self->{actual}, $name);
        return $self;
    },
    toContain => sub {
        my ($name, $self) = (shift, shift);

        if ( ref($self->{actual}) eq '' ) {
            __switch( $self->{not}, index($self->{actual}, $self->{expected}) >= 0, $name,
                sub {
                    sprintf(
                        "Fail!\nReason: '%s' %sdoes not contain substring%s '%s'",
                        $self->{actual}   // 'undef',
                        Term::ANSIColor::color('cyan'),
                        Term::ANSIColor::color('reset'),
                        $self->{expected} // 'undef',
                    );
                },
                sub {
                    sprintf(
                        "Fail!\nReason: '%s' %scontains substring%s '%s'",
                        $self->{actual}   // 'undef',
                        Term::ANSIColor::color('cyan'),
                        Term::ANSIColor::color('reset'),
                        $self->{expected} // 'undef',
                    );
                }
            );
            return $self;
        }

        my @actual = ref($self->{actual}) eq 'ARRAY' ? @{$self->{actual}} : keys %{$self->{actual}};

        if ( ref( $self->{actual} ) eq 'HASH' && ref( $self->{expected} ) eq 'HASH' ) {
            my %flattened = %{$self->{expected}};
            my %actual = %{$self->{actual}};
            for my $targetKey (keys %flattened) {
                # There is a shortcut checking ref already in eq_deeply for optimization
                __switch ( $self->{not}, Test::Deep::eq_deeply($flattened{$targetKey}, $actual{$targetKey}), "$name - $targetKey",
                    sub {
                        if ( exists $actual{$targetKey} ) {
                            sprintf( "Fail!\nReason: %sExpecting Hash Key %s'%s'%s with value:\n%s\n%sDoes not equal expected value:\n%s",
                                Term::ANSIColor::color('cyan'),
                                Term::ANSIColor::color('reset'),
                                $targetKey,
                                Term::ANSIColor::color('cyan'),
                                explain $actual{$targetKey} // 'undef',
                                Term::ANSIColor::color('cyan'),
                                explain $flattened{$targetKey} // 'undef'
                            );
                        }
                        else {
                            sprintf(
                                "Fail!\nReason: %sExpecting Hash key %s'%s'%s does not exist for the expected Hashref",
                                Term::ANSIColor::color('cyan'),
                                Term::ANSIColor::color('reset'),
                                $targetKey,
                                Term::ANSIColor::color('cyan'),
                            );
                        }
                    },
                    sub {
                        sprintf( "Fail!\nReason: %sBoth Hashrefs' value for Hash Key %s'%s'%s equal value:\n%s",
                            Term::ANSIColor::color('cyan'),
                            Term::ANSIColor::color('reset'),
                            $targetKey,
                            Term::ANSIColor::color('cyan'),
                            explain $actual{$targetKey} // 'undef',
                        );
                    },
                );
            }
        }
        else {
            my @flattened = ref($self->{expected}) eq 'ARRAY' ? @{$self->{expected}} : $self->{expected};

            for my $target (@flattened) {
                # There is a shortcut checking ref already in eq_deeply for optimization
                my $count = scalar( grep { Test::Deep::eq_deeply($_,$target) } @flattened );
                __switch ( $self->{not}, scalar( grep { Test::Deep::eq_deeply($_,$target) } @actual ) >= $count, $name,
                    sub {
                        sprintf( "Fail!\nReason: %sExpecting Array (or Keys):\n%s%sTo contain Expected %s\n%s",
                            Term::ANSIColor::color('cyan'),
                            explain \@actual,
                            Term::ANSIColor::color('cyan'),
                            ref $target ? (ref $target)."REF:" : "element:",
                            explain $target // 'undef'
                        );
                    },
                    sub {
                        sprintf( "Fail!\nReason: %sExpecting Array (or Keys):\n%s%snot to contain Expected %s\n%s",
                            Term::ANSIColor::color('cyan'),
                            explain \@actual,
                            Term::ANSIColor::color('cyan'),
                            ref $target ? (ref $target)."REF:" : "element:",
                            explain $target // 'undef'
                        );
                    },
                );
            }
        }

        return $self;
    },
    toMatch => sub {
        my ($name, $self) = (shift, shift);
        __switchFn ($self->{not}, \&Test::More::like, \&Test::More::unlike, $self->{actual}, $self->{expected}, $name);
        return $self;
    },
);

my %spy_run = (
    #    toHaveBeenCalled => sub {
    #        my ($name, $self) = (shift, shift);
    #        $mock_run{toBeTruthy}->( $name, $self );
    #        return $self;
    #    },
    #    toHaveBeenCalledTimes => sub {
    #        my ($name, $self) = (shift, shift);
    #        $mock_run{toBe}->( $name, $self );
    #        return $self;
    #    },
    #    toHaveBeenCalledWith => sub {
    #        pass('hi');
    #    },
);

my %run = ( %mock_run, %spy_run );


#sub __run {
#    my $test = shift;
#    for my $check (@{ $test->{checks} }) {
#        $run{$check->{type}}->( $test->{name}, $check );
#    }
#}

sub run {
    my $check = shift;
    $run{$check->{type}}->( $check->{name}, $check );
}

sub __switch {
    local $Test::Builder::Level = $Test::Builder::Level + 4;
    my ( $not, $result, $name, $errY, $errN) = @_;
    $result = !$result if $not;

    if ($result) {
        pass $name;
    }
    else {
        fail $name;
        return note Term::ANSIColor::color('red').&$errY if $errY && !$not;
        note Term::ANSIColor::color('red').&$errN if $errN;
    }
}

sub __switchFn {
    local $Test::Builder::Level = $Test::Builder::Level + 4;
    my ( $not, $fnY, $fnN, @params ) = @_;

    if ($not) {
        $fnN->(@params);
    } else {
        $fnY->(@params);
    }
}

1;
