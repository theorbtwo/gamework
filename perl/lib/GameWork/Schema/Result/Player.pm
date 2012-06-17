package GameWork::Schema::Result::Player;
use strictures 1;
use base 'DBIx::Class::Core';
use Data::Dump::Streamer 'Dump', 'Dumper';

__PACKAGE__->load_components(qw(InflateColumn::Authen::Passphrase));
__PACKAGE__->table('players');
__PACKAGE__->add_columns(
                         id => {
                                data_type => 'integer',
                                is_auto_increment => 1,
                               },
                         email => {
                                   data_type => 'text',
                                  },
                         password_hash => {
                                           data_type => 'text',
                                           inflate_passphrase => 'rfc2307'
                                          }
                        );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('game_players', 'GameWork::Schema::Result::GamePlayer', 'player_id');
# Might have various credentials -- android devices, iOS devices, email/pass, openids...

sub notify {
  my ($player, $note) = @_;

  print STDERR "FIXME: Send notification to player with email ", $player->email, "\n";
  #print STDERR Dumper($note);
}

'And who might *you* be, little girl?';
