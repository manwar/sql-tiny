#!/usr/bin/perl

use warnings;
use strict;
use 5.010;

use Test::More tests => 4;

use SQL::Tiny ':all';

test_select(
    [
        'users',
        [qw( userid name )],
        { status => 'X', code => [ 2112, 5150, 90125 ] },
        { order_by => [qw( name state )] },
    ],

    'SELECT userid,name FROM users WHERE code IN (?,?,?) AND status=? ORDER BY name,state',
    [ 2112, 5150, 90125, 'X' ]
);


test_select(
    [
        'users',
        [ 'COUNT(*)' ],
        { status => [qw( X Y Z )] },
    ],

    'SELECT COUNT(*) FROM users WHERE status IN (?,?,?)',
    [ 'X', 'Y', 'Z' ]
);


test_select(
    [
        'users',
        [qw( foo )],
        {}
    ],

    'SELECT foo FROM users',
    []
);


test_select(
    [
        'users',
        [qw( foo )],
        { source => 'S', timestamp => \'SYSDATE()', width => [ 12, 47 ] },
        { order_by => 'name' },
    ],

    'SELECT foo FROM users WHERE source=? AND timestamp=SYSDATE() AND width IN (?,?) ORDER BY name',
    [ 'S', 12, 47 ]
);

done_testing();

exit 0;

sub test_select {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $args           = shift;
    my $expected_sql   = shift;
    my $expected_binds = shift;

    return subtest "Expecting: $expected_sql" => sub {
        plan tests => 2;

        my ($sql,$binds) = sql_select( $args->[0], $args->[1], $args->[2], $args->[3] );
        is( $sql, $expected_sql, 'SQL matches' );
        is_deeply( $binds, $expected_binds, 'Binds match' );
    };
}
