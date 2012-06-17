package GameWork::Schema::Result::Game;
use strictures 1;
use GameWork::Rules;
use base 'DBIx::Class::Core';

__PACKAGE__->table('games');
__PACKAGE__->add_columns(
                         id => {
                                data_type => 'integer',
                                is_auto_increment => 1,
                               },
                         # TicTacToe, Go, Chess, etc?
                         rules => {
                                  data_type => 'TEXT',
                                 },
                         state => {
                                   data_type => 'TEXT',
                                  },
                        );

__PACKAGE__->inflate_column('state',
                            {
                             inflate => sub {
                               my ($json) = @_;

                               return GameWork::Rules->deserialize($json);
                             },
                             deflate => sub {
                               shift->serialize;
                             },
                            });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('game_players', 'GameWork::Schema::Result::GamePlayer', 'game_id');

sub notify {
  my ($game) = @_;

  my $game_players_rs = $game->game_players;
  my $found_unaccepted;
  while (my $gp = $game_players_rs->next) {
    next if $gp->has_accepted;

    # This GamePlayer hasn't yet accepted, so we should notify them.
    # ...with bob?
    $gp->player->notify({
                         type => 'invitation',
                         game => $game,
                        });
    $found_unaccepted++;
  }

  # If we've got users who have not accepted, we're done; a notification will go to the user who'se turn it is later, after people have accepted.
  return if $found_unaccepted;

  die;
}

"Would you like to play a game of Global Thermonuclear War?";
