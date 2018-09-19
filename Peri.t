#!/usr/bin/perl

# Modified from http://jasmine.github.io/2.4/introduction.html

use strict;
use warnings;
no warnings qw/redefine/;

package main;
use Peri;

describe 'A suite' => sub {
    it("contains spec with an expectation", sub {
        expect(1)->toBe(1);
    });
};

describe 'A suite is just a function' => sub {
    my $x;

    it("and so is a spec", sub {
        $x = 1;
        expect($x)->toBe(1);
    });

};

describe 'The "toBe" matcher, only works for ref or single variable,' => sub {
    it("has a positive case", sub {
        expect(1)->toBe(1);
    });

    it("and can have a negative case", sub {
        expect(0)->not->toBe(1);
    });
};

describe 'The "toEqual" matcher' => sub {

    it('works for simple literals and variables just as "toBe"', sub {
        my $x = 12;
        expect($x)->toEqual(12);
    });

    it("should work for objects", sub {
        my $foo = {
            a => 12,
            b => 34
        };
        my $bar = {
            a => 12,
            b => 34
        };
        expect($foo)->toEqual($bar);
    });
};

describe "The 'toMatch' matcher " => sub {
    it( "is for regular expressions" => sub {
        my $message = "foo bar baz";

        expect( $message )->toMatch( qr/bar/ );
        expect( $message )->toMatch( qr/^f[aeiou]{2,}/ );
        expect( $message )->toMatch( "bar" );
        expect( $message )->toMatch( "bazi?" );
        expect( $message )->not->toMatch( qr/quux/ );
    } );
};

describe "The 'toBeDefined' matcher " => sub {
    it( "compares against `undef`" => sub {
        my $x = {
            foo => "foo"
        };

        expect( $x->{foo} )->toBeDefined();
        expect( $x->{bar} )->not->toBeDefined();
    } );
};

describe "The `toBeUndefined` matcher " => sub {
    it( "compares against `undef`" => sub {
        my $x = {
            foo => "foo"
        };

        expect( $x->{foo} )->not->toBeUndefined();
        expect( $x->{bar} )->toBeUndefined();
    } );
};

describe "The 'toContain' matcher, checks if the expecting ref contains the value(s)," => sub {

    # This is not in the original Jasmine spec.
    # For hash, Devs may directly name the hash key and check its value with toBe

    my $x = {
        foo => "foo",
        bar => "bar",
        gg  => undef
    };
    my $y = [ "foo", "bar" ];
    my $z = [ { a => 1 }, { b => 2 } ];

    describe 'when expects hashref,' => sub {
        it ("passes when the keys and values both matches" => sub {
            expect( $x )->toContain( { foo => "foo" } );
            expect( $x )->not->toContain( { foo => "abc" } );
            expect( $x )->not->toContain( { bar => "foo" } );
            expect( $x )->toContain( { gg => undef } );
        });

        describe 'and of course,' => sub {
            it ('can take a sub hash for comparsion' => sub{
                expect( $x )->toContain( { foo => "foo" , bar => "bar" } );
            });
        };

        it ("works even when key is not found" => sub {
            expect( $x )->not->toContain( { xyz => "1234" } );
        });
    };

    describe 'for expecting hashref, when expect it to contain arrayref,' => sub {
        it ('checks if the hashref contains all keys in the arrayref' => sub {
            expect( $x )->toContain([ 'foo', 'gg' ]);
            expect( $x )->not->toContain([ 'baaz', 'liteyea' ]);
        });
        it ("appying 'not' means none of the keys are found" => sub {
            expect( $x )->toContain([ 'foo', 'gg' ]);
            expect( $x )->not->toContain([ 'baaz', 'liteyea' ]);
        });
    };

    it ("passes a test when the values are found in an array ref" => sub {
        # similar to expect({})->toContain({}), this supports expect([])->toContain([]) syntax

        # checking against only 1 element without [ ] is deprecated
        # expect( $y )->toContain( "foo" );
        # instead, use this:
        expect( $y )->toContain( ["foo"] );

        # This DOES NOT work.  This will only check the first element.
        # expect( $y )->toContain( "foo", "bar" );
        # instead, use this:
        expect( $y )->toContain( ["foo", "bar"] );
        expect( $z )->toContain( { a => 1 } );
    });

    it ("while applying 'not' means none of the values are in the array ref" => sub {
        expect( $y )->not->toContain( ["beer", "baaz"] );
    });

    it ("only compares with the keys when string is provided instead of ref" => sub {
        expect( $x )->toContain( "bar" );
        expect( $y )->toContain( "bar" );
        expect( $y )->not->toContain("quux");
    });

    it ("checks substring" => sub {
        expect( "foo" )->toContain( "o" );
        expect( "foo" )->toContain( "foo" );
        expect( "foo bar" )->toContain( "foo" );
        expect( "bar" )->not->toContain( "foo" );
        expect( "array" )->not->toContain( ["array"] );
        expect( "hash" )->not->toContain( {"hash"=>"hash"} );
    });
};

xdescribe "The 'toBeNull' matcher is same as 'toBeUndefined'. xit / xdescribe to skip." => sub {
    fail('Oh xdescribe is not working!');
};

describe "The 'toBeTruthy' matcher is for boolean casting testing," => sub {
    it( "works for undef, 0, and strings" => sub {
        my $x = undef;
        my $y = 0;
        my $foo = "foo";

        expect( $foo )->toBeTruthy();
        expect( $x )->not->toBeTruthy();
        expect( $y )->not->toBeTruthy();
    } );
};

describe "The 'toBeFalsy' matcher is for boolean casting testing" => sub {
    my $x = undef;
    my $y = 0;
    my $foo = "foo";

    it ("in fact just toggle the 'not' and run toBeTruthy" => sub {
        expect( $x )->toBeFalsy();
        expect( $y )->toBeFalsy();
        expect( $foo )->not->toBeFalsy();
    });
};

describe "The 'toBeLessThan' matcher is for mathematical comparisons" => sub {
    my $pi = 3.1415926,
    my $e = 2.78;

    it ("it cannot be equal" => sub {
        expect( $e )->toBeLessThan( $pi )
            ->and->not->toBeLessThan( 2.78 );
        expect( $pi )->not->toBeLessThan( $e );
    });
};

describe "The 'toBeGreaterThan' matcher is for mathematical comparisons" => sub {
    my $pi = 3.1415926,
    my $e = 2.78;

    it ("it cannot be equal" => sub {
        expect( $pi )->toBeGreaterThan( $e );
        expect( $e )->not->toBeGreaterThan( $pi );
    });
};

describe "The 'toBeCloseTo' matcher is for precision math comparison" => sub {
    my $pi = 3.1415926,
    my $e = 2.78;

    it ("It would round 2.5 to 3" => sub {

        expect($pi)->not->toBeCloseTo($e, 2);
        expect($pi)->toBeCloseTo($e, 0);
    });
};

xit("beforeAll, afterAll will be implemented upon request.");

describe "A spy" => sub {
    our $bar = '';
    sub setBar {
        $bar = shift;
    };
    sub someFunction {
        $bar = shift;
    };

    setBar(1999);
    it('before spying, expects bar to be set to 1999' => sub {
        expect($bar)->toBe(1999);
    });

    spyOn('main::setBar');
    spyOn('main::someFunction');

    setBar(123);
    setBar(456, 'another param');
    setBar({a=>1});

    it('tracks that the spy was called' => sub {
        expect('main::setBar')->toHaveBeenCalled();
    });

    it('tracks that the spy was not called' => sub {
        expect('main::someFunction')->not->toHaveBeenCalled();
    });

    it('tracks that the spy was called x times' => sub {
        expect('main::setBar')
            ->toHaveBeenCalledTimes(3)
            ->and->not->toHaveBeenCalledTimes(2);
    });

    it("tracks all the arguments of its calls" => sub {
        expect('main::setBar')
            ->toHaveBeenCalledWith(123)
            ->and->toHaveBeenCalledWith(456, 'another param')
            ->and->toHaveBeenCalledWith({a=>1});
        # Not a must to chain them up.  Chain it for readability purposes
        expect('main::setBar')->not->toHaveBeenCalledWith({a=>2});
    });

    it("stops all execution on a function", sub {
        expect($bar)->toBe(1999);
    });
};

describe "A spy, when configured to call through" => sub {
    our $bar = '';
    our $fetchedBar = '';
    sub setBar {
        $bar = shift;
    };
    sub getBar {
        return $bar;
    };

    spyOn('main::setBar')->and->callThrough();

    setBar(123);
    $fetchedBar = getBar();

    it('tracks that the spy was called' => sub {
        expect('main::setBar')->toHaveBeenCalled();
    });

    it("should not affect other functions" => sub {
        expect($bar)->toEqual(123);
    });

    it("when called returns the requested value" => sub {
        expect($fetchedBar)->toEqual(123);
    });
};

describe "A spy, when configured to fake a return value" => sub {
    our $bar = '';
    our $fetchedBar = '';
    sub setBar {
        $bar = shift;
    };
    sub getBar {
        return $bar;
    };

    spyOn('main::getBar')->and->returnValue(745);

    setBar(123);
    $fetchedBar = getBar();

    it('tracks that the spy was called' => sub {
        expect('main::getBar')->toHaveBeenCalled();
    });

    it("should not affect other functions" => sub {
        expect($bar)->toEqual(123);
    });

    it("when called returns the requested value" => sub {
        expect($fetchedBar)->toEqual(745);
    });

    spyOn('main::getBar')->and->returnValue(answer => 2);
    my %fetchedHash = getBar();

    it("should be able to return Hash value" => sub {
        expect($fetchedHash{'answer'})->toEqual(2);
        expect($fetchedHash{'answer'})->not->toEqual(1);
    });
};

describe "A spy, when configured to fake a series of return values" => sub {
    our $bar = '';
    sub setBar {
        $bar = shift;
    };
    sub getBar {
        return $bar;
    };

    spyOn('main::getBar')->and->returnValues(["fetched first"], ["fetched second"], ["array", "values"], ["hash key" => "value"]);

    setBar(123);

    it("should not affect other functions" => sub {
        expect($bar)->toEqual(123);
    });

    it("when called multiple times returns the requested values in order" => sub {
        expect(getBar())->toEqual("fetched first");
        expect(getBar())->toEqual("fetched second");
        expect([getBar()])->toEqual(["array", "values"]);
        expect({getBar()})->toEqual({"hash key" => "value"});
        expect(getBar())->toBeUndefined();
    });

    it('tracks that the spy was called' => sub {
        expect('main::getBar')->toHaveBeenCalledTimes(5);
    });
};

describe "A spy, when configured to return the input" => sub {
    our $bar = '';
    our $fetchedBar = '';
    sub setBar {
        $bar = shift;
    };
    sub getBar {
        return $bar;
    };

    spyOn('main::getBar')->and->returnInput();

    setBar(123);
    $fetchedBar = getBar(456);

    it('tracks that the spy was called' => sub {
        expect('main::getBar')->toHaveBeenCalled();
    });

    it("should not affect other functions" => sub {
        expect($bar)->toEqual(123);
    });

    it("when called returns the inputted value" => sub {
        expect($fetchedBar)->toEqual(456);
    });

    it("when called inline, still returns the input value" => sub {
        expect(getBar(765))->toEqual(765);
    });

    it("when called, returns the 1st input value in scalar context" => sub {
        my $sample = getBar(1,2,3);
        expect($sample)->toEqual(1);
    });

    it("when called, returns array in array context" => sub {
        my @sample = getBar(11,12,13);
        expect(scalar @sample)->toEqual(3);
        expect($sample[2])->toEqual(13);
    });

    it("when called, returns hash in hash context" => sub {
        my %sample = getBar(4,3,2,1);
        expect(scalar keys %sample)->toEqual(2);
        expect($sample{4})->toEqual(3);
    });
};

describe "A spy, when configured with an alternate implementation" => sub {
    our $bar = '';
    our $fetchedBar = '';
    sub setBar {
        $bar = shift;
    };
    sub getBar {
        return $bar;
    };

    spyOn('main::getBar')->and->callFake(sub {
        return 1001;
    });

    setBar(123);
    $fetchedBar = getBar();

    it('tracks that the spy was called' => sub {
        expect('main::getBar')->toHaveBeenCalled();
    });

    it("should not affect other functions" => sub {
        expect($bar)->toEqual(123);
    });

    it("when called returns the requested value" => sub {
        expect($fetchedBar)->toEqual(1001);
    });

    spyOn('main::setBar')->and->callFake(sub {
        $bar = $_[0] + 1;
    });

    spyOn('main::getBar')->and->callThrough();
    setBar(123);

    it('and fake function calls work well' => sub {
        expect($bar)->toEqual(124);
        expect(getBar())->toEqual(124);
    });
};

describe "A spy", sub {
    our $bar = undef;
    sub setBar {
        $bar = shift;
    };

    my $setBarSpy = spyOn('main::setBar')->and->callThrough();

    it("can call through and then stub in the same spec", sub {
        setBar(123);
        expect($bar)->toEqual(123);

        $setBarSpy->and->stub();
        $bar = undef;

        setBar(123);
        expect($bar)->toBeUndefined;
    });
};

describe "Data provider", sub {
    sub functionToBeTested {
        my ($arg1, $arg2) = ( shift // 0, shift // 0 );
        return $arg1 + $arg2;
    };

    sub testProvider {
        return {
            'data for case 1' => [ 5, 1, 4  ],
            'data for case 2' => [ 2, 2 ],
        };
    };

    my $mySpy = spyOn('main::functionToBeTested')->and->callThrough();
    using(\&testProvider,
        sub {
            my ($expectedResult, @params) = @_;

            my $returnValue = functionToBeTested(@params);

            it ('substitutes parameters accordingly' => sub {
                expect($returnValue)->toBe($expectedResult);
            });
        }
    );

    it ('should run the test for 2 times' => sub {
        expect( 'main::functionToBeTested' )->toHaveBeenCalledTimes( 2 );
    });
    it ('should run with correct argruments' => sub {
        expect($mySpy->calls->argsFor(0))->toEqual([1, 4]);
        expect($mySpy->calls->argsFor(1))->not->toEqual([2, 0]);
        expect($mySpy->calls->argsFor(1))->toEqual([2]);
    });
};

describe "Before and after each", sub {
    my $foo;

    beforeEach(sub {
        $foo = 0;
        $foo += 1;
    });

    afterEach(sub {
        $foo = 0;
    });

    it("is just a function, so it can contain any code", sub {
        expect($foo)->toEqual(1);
    });

    my $bar = $foo;
    it("can have more than one expectation", sub {
        expect($foo)->toEqual(1);
        expect($bar)->toEqual(0);
    });
};

describe "Multiple spies, when created manually", sub {
    my $tape = Peri::createSpyObj('tape', ['play', 'pause', 'stop', 'rewind']);

    $tape->play();
    $tape->pause();
    $tape->rewind(0);
    $tape->rewind('key1'=>'value1', 'key2'=>'value2');
    $tape->rewind(123, 'abc');

    it("creates spies for each requested function", sub {
            expect($tape, 'play'  )->toBeDefined();
            expect($tape, 'pause' )->toBeDefined();
            expect($tape, 'rewind')->toBeDefined();
            expect($tape, 'stop'  )->toBeDefined();
        });

    it("can have more than one expectation", sub {
            expect($tape, 'play'  )->toHaveBeenCalled();
            expect($tape, 'pause' )->toHaveBeenCalled();
            expect($tape, 'rewind')->toHaveBeenCalled();
            expect($tape, 'stop'  )->not->toHaveBeenCalled();
        });

    it("tracks all the arguments of its calls", sub {
            expect($tape, 'rewind')->toHaveBeenCalledTimes(3);
            expect($tape, 'rewind')->toHaveBeenCalledWith(0);
            expect($tape, 'rewind')->toHaveBeenCalledWith('key1'=>'value1', 'key2'=>'value2');
            expect($tape, 'rewind')->toHaveBeenCalledWith(123, 'abc');
        });

    it("tracks the arguments of its calls by specified calls", sub {
        expect($tape->{rewind}->calls->argsFor(0))->toEqual([0]);
        expect($tape->{rewind}->calls->argsFor(1))->toEqual(['key1', 'value1', 'key2', 'value2']);
        expect($tape->{rewind}->calls->argsFor(2))->toEqual([123, 'abc']);
        expect($tape->{rewind}->calls->mostRecent())->toEqual({'object'=>$tape, 'args'=>[123, 'abc']});
    });

    it("tracks the arguments of its calls by specified calls second time", sub {
        expect($tape->{rewind}->calls->argsFor(0))->toEqual([0]);
        expect($tape->{rewind}->calls->argsFor(1))->toEqual(['key1', 'value1', 'key2', 'value2']);
        expect($tape->{rewind}->calls->argsFor(2))->toEqual([123, 'abc']);
        expect($tape->{rewind}->calls->mostRecent())->toEqual({'object'=>$tape, 'args'=>[123, 'abc']});
    });

    it("tracks the arguments of its calls by specified calls with hash args", sub {
        my %hashArgs = @{$tape->{rewind}->calls->argsFor(1)};
        expect(\%hashArgs)->toEqual({'key1'=>'value1', 'key2'=>'value2'});
    });
};

describe "Multiple spies, define methods on objects from the same class", sub {
    my $tape1 = Peri::createSpyObj('tape', ['play', 'rewind']);
    my $tape2 = Peri::createSpyObj('tape', ['play']);

    it("can have more than one expectation - tape 1", sub {
        expect($tape1, 'play'  )->toBeDefined();
        expect($tape1, 'rewind')->toBeDefined();
    });

    it("creates spies for each requested function - tape 2", sub {
        expect($tape2->{play})->toBeDefined();
        expect($tape2->{rewind})->not->toBeDefined();
    });
};

describe "Multiple spies, call methods on objects from the same class", sub {
    my $tape1 = Peri::createSpyObj('tape', ['rewind']);
    my $tape2 = Peri::createSpyObj('tape', ['rewind']);

    $tape2->rewind('Abc');
    $tape1->rewind(0);
    $tape2->rewind(1, 'Ab');

    it("tracks all the arguments of its calls - tape 1", sub {
        expect($tape1, 'rewind')->toHaveBeenCalledTimes(1);
        expect($tape1, 'rewind')->toHaveBeenCalledWith(0);
    });

    it("tracks all the arguments of its calls - tape 2", sub {
        expect($tape2, 'rewind')->toHaveBeenCalledTimes(2);
        expect($tape2, 'rewind')->toHaveBeenCalledWith('Abc');
        expect($tape2, 'rewind')->toHaveBeenCalledWith(1, 'Ab');
    });

    it("tracks the arguments of its calls by specified calls - tape 1", sub {
        expect($tape1->{rewind}->calls->argsFor(0))->toEqual([0]);
    });

    it("tracks the arguments of its calls by specified calls - tape 2", sub {
        expect($tape2->{rewind}->calls->argsFor(0))->toEqual(['Abc']);
        expect($tape2->{rewind}->calls->argsFor(1))->toEqual([1, 'Ab']);
    });
};

describe "Multiple spies, return values on objects from the same class", sub {
    my $tape1 = Peri::createSpyObj('tape', ['play', 'rewind']);
    my $tape2 = Peri::createSpyObj('tape', ['play', 'rewind']);

    spyOn($tape1, 'play')->and->returnValue('play 1');
    spyOn($tape2, 'play')->and->returnValue('play 2');

    spyOn($tape1, 'rewind')->and->returnValues(['rewind 1']);
    spyOn($tape2, 'rewind')->and->returnValues(['rewind 2a'], ['rewind 2b']);

    my $tape2_play_return = $tape2->play();
    my $tape2_rewind_return1 = $tape2->rewind('Abc');

    my $tape1_play_return = $tape1->play();
    my $tape1_rewind_return = $tape1->rewind(0);

    my $tape2_rewind_return2 = $tape2->rewind(1, 'Ab');

    it("expect return values - tape 1", sub {
        expect( $tape1_play_return )->toEqual( 'play 1' );
        expect( $tape1_rewind_return )->toEqual( 'rewind 1' );
    });
    it("expect return values - tape 2", sub {
        expect($tape2_play_return)->toEqual('play 2');
        expect($tape2_rewind_return1)->toEqual('rewind 2a');
        expect($tape2_rewind_return2)->toEqual('rewind 2b');
    });
};

describe "A spy, return value on method called from an object", sub {
    my $obj = bless({}, 'MyObject');
    spyOn('MyObject::method')->and->returnValue('something');

    spyOn($obj, 'method')->and->returnValue('mocked');

    my $result  = $obj->method();

    it("expect return values - tape 2", sub {
        expect($result)->toEqual('mocked');
    });

    my $obj2 = Peri::createSpyObj('MyObject2', ['method']);
    spyOn('MyObject2::method');

    $obj2->method;

    it("counts calls correctly" => sub {
       expect('MyObject::method')->toHaveBeenCalled;
#       expect('MyObject2::method')->toHaveBeenCalled;
    });
};

done_testing();

