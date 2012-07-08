package GameWork::Web::Controller::API;
use Moose;
use namespace::autoclean;
use 5.10.0;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => 'api');

=head1 NAME

GameWork::Web::Controller::API - API Controller for GameWork::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

sub login :Path('login') {
  my ($self, $c) = @_;

  my $user = $c->req->param('email');
  my $pass = $c->req->param('pass');
  
  my $u = $c->find_user({ email => $user }, 'email_pass');
  $c->set_authenticated($u, 'email_pass');

  #if(!$c->authenticate({'email' => $user,
  #                  'password' => $pass }) {
  #  ## FAIL
  #}

  $c->stash(return => {success => 1});
}

sub start_game_with :Path('start_game_with') :Args(2) {
  my ($self, $c, $rules, $other_player_id) = @_;

  die unless $rules ~~ ['TicTacToe'];

  my $other_player = $c->model('DB::Player')->find({id => $other_player_id});

  my $rules_class = "GameWork::Rules::$rules";
  Class::MOP::load_class($rules_class);

  my $state = $rules_class->new;

  my $game;

  $c->model('DB')->schema->txn_do
    (sub {
       $game = $c->model('DB::Game')->create({rules => $rules, state => $state});
       $game->create_related('game_players', 
                             {
                              player_id => $c->user->obj->id,
                              # For now, the challenger is always player 0.
                              position => 0,
                              has_accepted => 1,
                             });
       
       $game->create_related('game_players', 
                             {
                              player_id => $other_player->id,
                              # For now, the challenger is always player 0.
                              position => 1,
                              has_accepted => 0,
                             });
       $game->notify;
     });

  $c->stash( current_view => 'JSON',
             return => {game_id => $game->id});
}


=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head1 AUTHOR

James Mastros,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#__PACKAGE__->meta->make_immutable;

1;
