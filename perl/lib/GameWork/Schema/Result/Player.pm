package GameWork::Schema::Result::Player;
use strictures 1;
use base 'DBIx::Class::Core';
use Data::Dump::Streamer 'Dump', 'Dumper';
use Digest::SHA;
use Authen::Passphrase::SaltedDigest;

__PACKAGE__->load_components(qw(InflateColumn::Authen::Passphrase));
__PACKAGE__->table('players');
__PACKAGE__->add_columns(
                         id => {
                                data_type => 'integer',
                                is_auto_increment => 1,
                               },
                         # Note: this is filled with email addresses,
                         # not friendly usernames.  Use of the column
                         # name 'username' is just to appease
                         # CatalystX::SimpleLogin
                         username => {
                                      data_type => 'text',
                                     },
                         # Similarly, these aren't actually passwords,
                         # these are actually hashes of passwords.
                         password => {
                                      data_type => 'text',
                                      inflate_passphrase => 'rfc2307'
                                     }
                        );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint('username' => ['username']);
__PACKAGE__->has_many('game_players', 'GameWork::Schema::Result::GamePlayer', 'player_id');
# Might have various credentials -- android devices, iOS devices, email/pass, openids...

sub check_password {
  my ($self, $password) = @_;

  return $self->password->match($password);
}

sub notify {
  my ($player, $note) = @_;

  print STDERR "FIXME: Send notification to player with email ", $player->username, "\n";
  print STDERR Dumper($note);
}

sub hash_password {
  my ($self, $pass) = @_;
  
  return Authen::Passphrase::SaltedDigest->new(
                                               # FIXME: sha1 isn't considered terribly secure these days.
                                               algorithm => 'SHA-1',
                                               salt_random => 20,
                                               passphrase => $pass
                                              );
}

'And who might *you* be, little girl?';
