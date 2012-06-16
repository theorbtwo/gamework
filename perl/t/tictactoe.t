#!/usr/bin/perl
use strictures 1;
use Test::More;
use Test::Exception;

require_ok('GameWork::Rules::TicTacToe');

my $g = GameWork::Rules::TicTacToe->new;
isa_ok($g, 'GameWork::Rules::TicTacToe');

is($g->at([2,2]), -1);
$g->grid->[2][2] = 0;
is($g->at([2,2]), 0);

my $ser = $g->serialize();
#diag($ser);

my $clone = GameWork::Rules::TicTacToe->deserialize($ser);
$clone->grid->[0][0] = 1;
$clone->current_turn(1);
dies_ok {$g->valid_move($clone)} 'Wrong player moved';

$clone = GameWork::Rules::TicTacToe->deserialize($ser);
$clone->grid->[0][0] = 0;
$clone->current_turn(1);
is $g->valid_move($clone), 1, 'Good move';

dies_ok {$clone->valid_move($g)} "Backward";

$clone = GameWork::Rules::TicTacToe->deserialize($ser);
dies_ok {$g->valid_move($clone)} "Current player didn't change";

is($g->pretty, <<END);
...
...
..X
Currently player 0's turn

END

is($g->score, undef);

$g->grid->[0] = [1,0,-1];
$g->grid->[1] = [0,1,0];
$g->grid->[2] = [0,0,1];
is_deeply($g->score, [0, 1]);

$g->grid->[0] = [0,-1,-1];
$g->grid->[1] = [0,-1,-1];
$g->grid->[2] = [0,-1,-1];
is_deeply($g->score, [1, 0]);

$g->grid->[0] = [1,0,1];
$g->grid->[1] = [1,1,0];
$g->grid->[2] = [0,0,-1];
is_deeply($g->score, undef);

$g->grid->[0] = [1,0,1];
$g->grid->[1] = [1,1,0];
$g->grid->[2] = [0,1,0];
is_deeply($g->score, [.5, .5]);



done_testing;
