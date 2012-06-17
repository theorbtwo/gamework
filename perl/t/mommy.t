#!/usr/bin/perl
use strictures 1;
use HTTP::Request::Common;
use Test::More;
use GameWork::Schema;

my $sch;

BEGIN {
  $ENV{CATALYST_CONFIG_LOCAL_SUFFIX} = 'test';

  unlink 't/var/gamework.db';
  $sch = GameWork::Schema->connect('dbi:SQLite:t/var/gamework.db');
  $sch->deploy;
}

$sch->resultset('Player')->create({ id => 1, email => 'bob@example.com', password_hash => 'nonesuch' });
$sch->resultset('Player')->create({ id => 2, email => 'fred@example.com', password_hash => 'nonesuch'});

use Test::WWW::Mechanize::Catalyst 'GameWork::Web';

my $mech = Test::WWW::Mechanize::Catalyst->new;

my $resp = $mech->request(POST '/login', [email => 'bob@example.com']);

print $resp->as_string("\n");

is($resp->code, 200, 'login http success');
like($resp->decoded_content, qr/success/, 'login text says success');


$resp = $mech->get('/start_game_with/TicTacToe/2');
# Over-specified?
is($resp->decoded_content, '{"game_id":1}');


done_testing;
