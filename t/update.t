#!/usr/bin/perl

use warnings;
use strict;
use 5.010;

use Test::More tests => 3;

use SQL::Tiny qw( sql_update );

test_update(
    'users',
    {
        status     => 'X',
        lockdate   => undef,
    },
    {
        orderdate => \'SYSDATE()',
    },

    'UPDATE users SET lockdate=NULL, status=? WHERE orderdate=SYSDATE()',
    [ 'X' ],

    'Standard mish-mash'
);

test_update(
    'wipe',
    {
        finagle => 4,
    },
    {},

    'UPDATE wipe SET finagle=?',
    [ 4 ],

    'No WHERE restrictions'
);

test_update(
    'fishy',
    {
        bingo => 'bongo',
    },
    {
        status => [qw( A B C )],
        width  => [ 5, 6 ],
    },

    'UPDATE fishy SET bingo=? WHERE status IN (?,?,?) AND width IN (?,?)',
    [ 'bongo', 'A', 'B', 'C', 5, 6 ],

    'WHERE clause has INs',
);


done_testing();

exit 0;

sub test_update {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $table          = shift;
    my $values         = shift;
    my $where          = shift;
    my $expected_sql   = shift;
    my $expected_binds = shift;
    my $msg            = shift;

    return subtest "$msg: $expected_sql" => sub {
        plan tests => 2;

        my ($sql,$binds) = sql_update( $table, $values, $where );
        is( $sql, $expected_sql, 'SQL matches' );
        is_deeply( $binds, $expected_binds, 'Binds match' );
    };
}
