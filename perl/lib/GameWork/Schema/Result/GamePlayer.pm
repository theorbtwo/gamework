package GameWork::Schema::Result::GamePlayer;
use strictures 1;
use base 'DBIx::Class::Core';

#__PACKAGE__->load_components('Ordered');
__PACKAGE__->table('game_players');
__PACKAGE__->add_columns(
                         game_id => {
                                     data_type => 'integer',
                                    },
                         player_id => {
                                       data_type => 'integer',
                                      },
                         position => {
                                      data_type => 'integer',
                                     },
                         has_accepted => {
                                          data_type => 'boolean',
                                         },
                         # The user's score for this game.  null when the game is still ongoing.
                         score => {
                                   data_type => 'float',
                                   is_nullable => 1,
                                  },
                        );
__PACKAGE__->set_primary_key('game_id', 'player_id');
#__PACKAGE__->grouping_column('game_id');
#__PACKAGE__->position_column('position');

__PACKAGE__->belongs_to('game', 'GameWork::Schema::Result::Game', 'game_id');
__PACKAGE__->belongs_to('player', 'GameWork::Schema::Result::Player', 'player_id');

'I had the strangest dream ... and you were there, and you, and you...';
