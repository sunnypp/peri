#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use MonkeyPatch;

package main;

%VAR::HASH_VALUES = (KEY1 => 'V1');

sub getGlobal {
    return %VAR::HASH_VALUES;
}

subtest 'monkey patch by name' => sub {

        is ( $VAR::HASH_VALUES{KEY1}, 'V1', 'Initial setup' );
        is ( { getGlobal( "HASH_VALUES" ) }->{KEY1}, 'V1', 'getGlobal should be working');
        is ( { MonkeyPatch::runOriginal( 'main::getGlobal', "HASH_VALUES" ) }->{KEY1}, 'V1',
                'Run Original possible before patch');

        MonkeyPatch::patch( 'main::getGlobal', sub {return (KEY1 => 'hi');} );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY1}, 'hi', 'Successful MonkeyPatch');

        MonkeyPatch::patch( 'main::getGlobal', sub {return (KEY1 => 'hello');} );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY1}, 'hello', 'Successful Second MonkeyPatch');

        is ( { MonkeyPatch::runOriginal( 'main::getGlobal', "HASH_VALUES" ) }->{KEY1}, 'V1', 'Run Original');
        is ( { getGlobal( "HASH_VALUES" ) }->{KEY1}, 'hello', 'Run Original does not affect MonkeyPatch');

        MonkeyPatch::unpatch( 'main::getGlobal' );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY1}, 'V1', 'Gets original result after unpatch');

        MonkeyPatch::patch( 'main::getGlobal', sub {return (KEY1 => 'hi');} );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY1}, 'hi', 'Successful MonkeyPatch');

        MonkeyPatch::unpatchAll();

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY1}, 'V1', 'Gets original result after unpatchAll');

        done_testing();
    };


subtest 'monkey patch by code reference' => sub {
        %VAR::HASH_VALUES = (KEY2 => 'V2');

        is ( $VAR::HASH_VALUES{KEY2}, 'V2', 'Initial setup' );
        is ( { getGlobal( "HASH_VALUES" ) }->{KEY2}, 'V2', 'getGlobal should be working');
        is ( { MonkeyPatch::runOriginal( \&main::getGlobal, "HASH_VALUES" ) }->{KEY2}, 'V2',
                'Run Original possible before patch');

        MonkeyPatch::patch( \&main::getGlobal, sub {return (KEY2 => 'hi');} );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY2}, 'hi', 'Successful MonkeyPatch');

        MonkeyPatch::patch( \&main::getGlobal, sub {return (KEY2 => 'hello');} );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY2}, 'hello', 'Successful Second MonkeyPatch');

        is ( { MonkeyPatch::runOriginal( \&main::getGlobal, "HASH_VALUES" ) }->{KEY2}, 'V2', 'Run Original');
        is ( { getGlobal( "HASH_VALUES" ) }->{KEY2}, 'hello', 'Run Original does not affect MonkeyPatch');

        MonkeyPatch::unpatch( \&main::getGlobal );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY2}, 'V2', 'Gets original result after unpatch');

        MonkeyPatch::patch( \&main::getGlobal, sub {return (KEY2 => 'hi');} );

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY2}, 'hi', 'Successful MonkeyPatch');

        MonkeyPatch::unpatchAll();

        is ( { getGlobal( "HASH_VALUES" ) }->{KEY2}, 'V2', 'Gets original result after unpatchAll');

        done_testing();
    };

done_testing();


