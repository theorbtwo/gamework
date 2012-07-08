package GameWork::Web::Controller::UserVisible;
use Moose;
use strictures 1;
use namespace::autoclean;
use Email::Valid;
use Try::Tiny;
use 5.10.0;

BEGIN {extends 'Catalyst::Controller::ActionRole';}

__PACKAGE__->config(namespace => 'hfe');

sub games :Path('games') :Does('NeedsLogin') :LoginRedirectMessage("Can't view your games if I don't know who you are.") {
  my ($self, $c) = @_;

  my $stash_info_ar = [];
  $c->stash->{games_info} = $stash_info_ar;

  my $my_games = $c->user->game_players->search_related('game');

  while (my $game = $my_games->next) {
    my $stash_info = {};
    push @$stash_info_ar, $stash_info;

    $stash_info->{id} = $game->id;
    $stash_info->{rules} = $game->rules;
    $stash_info->{completely_done} = 1;
    $stash_info->{current_position} = $game->state->current_turn;

    my $gps = $game->search_related('game_players', {}, {order_by => 'position'});
    while (my $gp = $gps->next) {
      push @{$stash_info->{players}}, {
                                       is_me => ($gp->player_id == $c->user->id),
                                       has_accepted => $gp->has_accepted,
                                       is_done => defined $gp->score,
				       email => $gp->player->username,
                                      };

      if (($gp->player_id == $c->user->id) and
	  !$gp->has_accepted
	 ) {
	$stash_info->{waiting_for_my_acceptance} = 1;
      }

      if (!$gp->has_accepted) {
        # How many players have not yet accepted the game -- if 0, we are ready to start.
        $stash_info->{waiting_for_acceptance}++;
      }

      if (defined $gp->score) {
        # How many players have stopped playing?
        $stash_info->{partly_done}++;
      }

      if (!defined $gp->score) {
        # True iff all players are done, and the game is over.
        $stash_info->{completely_done} = 0;
      }

      if ($gp->player_id == $c->user->id) {
        $stash_info->{my_position} = $gp->position;
      }

    }

    $stash_info->{current_player} = $game->current_player;
    $stash_info->{my_turn} = ($stash_info->{current_player}->id == $c->user->obj->id);
  }

  return;
}

sub create_game :Path('create_game') :Does('NeedsLogin') :LoginRedirectMessage("Need to log in to make a new game.") {
  my ($self, $c) = @_;

  my $errors = [];
  $c->stash->{errors} = $errors;

  my $email = $c->req->parameters->{email};
  if (not $email) {
    push @$errors, 'no email';
  }

  my $other_user;
  if ($email) {
    $other_user = $c->model('DB::Player')->find({username => $email});
    if (!$other_user) {
      push @$errors, "Can't find user $email";
    }
  }

  my $rules = $c->req->parameters->{rules} || push @$errors, 'no rules (how did you manage *that*?)';
  if ($rules =~ m/[^A-Za-z0-9]/) {
    push @$errors, 'rules fails validation';
  }

  if (@$errors) {
    $c->go('/hfe/games');
    return;
  }

  my $rules_class = "GameWork::Rules::$rules";

  Class::MOP::load_class($rules_class);
  my $gamestate = $rules_class->new;

  my $game = $c->model('DB::Game')->create({rules => $rules,
					    state => $gamestate});
  $c->model('DB::GamePlayer')->create({game_id => $game->id,
				       player_id => $c->user->obj->id,
				       position => 0,
				       has_accepted => 1,
				       score => undef
				      });
  $c->model('DB::GamePlayer')->create({game_id => $game->id,
				       player_id => $other_user->id,
				       position => 1,
				       has_accepted => 0,
				       score => undef
				      });

  $c->go('/hfe/games');
}

sub generic_game_action :Path('generic_game_action') :Does('NeedsLogin') :LoginRedirectMessage("Can't do stuff to a game without logging in.") {
  my ($self, $c) = @_;

  my $game = $c->model('DB::Game')->find({id => $c->req->parameters->{game_id}});
  if (!$game) {
    die "Can't find game?";
  }

  my $my_gp = $game->search_related('game_players', {player_id => $c->user->obj->id});
  if (!$my_gp) {
    die "You are not in this game?";
  }

  if ($c->req->parameters->{accept_game}) {
    $my_gp->update({has_accepted => 1});
    $game->notify;
  } else {
    die "generic game action without action?";
  }

  $c->res->redirect('/hfe/games');
}

sub make_user :Path('make_user') {
  my ($self, $c) = @_;

  # None of these are valid when emptystring or '0', so we should be
  # safe avoiding undef warnings like this.
  my $email = $c->req->parameters->{'email'} || '';
  my $password_1 = $c->req->parameters->{'password_1'} || '';
  my $password_2 = $c->req->parameters->{'password_2'} || '';

  $c->log->debug("email: $email");
  $c->log->debug("password_1: $password_1");
  $c->log->debug("password_2: $password_2");


  if (!$email and !$password_1 and !$password_2) {
      $c->log->debug('forwarding, form empty');
      $c->go('/hfe/make_user_form');
      return;
  }

  my $errors = [];
  $c->stash->{errors} = $errors;

  my $ev = Email::Valid->new(#-mxcheck => 1,
			     # Temp, while at gamer's holiday, and have no network access.
			     -mxcheck => 0,
                             -rfc822 => 1,
                             -fqdn => 1,
                             -local_rules => 1);
  if (!$ev->address($email)) {
    # Could check $ev->details to figure out what it didn't like about the email, but not for now.
    push @$errors, 'Invalid email address';
  }

  if ($c->model('DB::Player')->find({username => $email})) {
    push @$errors, 'email address already used';
  }

  if (not $password_1 or length $password_1 < 6) {
    push @$errors, 'Your password must be at least 6 characters';
  }

  if ($password_1 ne $password_2) {
    push @$errors, 'You mistyped your password';
  }

  if (@$errors) {
    $c->go('/hfe/make_user_form');
    return;
  }

  my $password_hash = GameWork::Schema::Result::Player->hash_password($password_1);

  $c->model('DB::Player')->create({username => $email,
                                   password => $password_hash});

  $c->authenticate({username => $email,
                    password => $password_1}) or die "Authentication failed just after creation?";

  $c->log->debug("user exists? ". $c->user_exists);

  $c->res->redirect($c->uri_for('/hfe/games'));
}

sub make_move :Path('make_move') :Does('NeedsLogin') :LoginRedirectMessage("Need to log in to make a move.") {
  my ($self, $c) = @_;

  if (not ($c->req->parameters->{game_id} and
	   $c->req->parameters->{state})) {
    print STDERR "Insufficent parameters, going back to make_move_form\n";
    $c->go('/hfe/make_move_form');
  }

  my $game = $c->model('DB::Game')->find({ id => $c->req->param('game_id') });
  my $new_state = GameWork::Rules->deserialize($c->req->param('state'));

  try {
    $game->state->valid_move($new_state);
  } catch {
    print STDERR "Invalid move: $_\n";
    $c->stash->{error} = $_;
    $c->go('/hfe/make_move_form');
  };

  $game->state($new_state);

  my $score = $game->state->score;
  if ($score) {
    print STDERR "Game over, have scores.\n";

    my $gps_rs = $game->game_players->search({}, {order_by => {-asc => 'position'}});
    while (my $gp = $gps_rs->next) {
      printf STDERR "%s scored %f\n", $gp->player->username, $score->[0];
      $gp->score(shift @$score);
    }

    $game->update;
    $game->notify();

    return $c->res->redirect($c->uri_for('/hfe/games'));
  }

  $game->update();
  $game->notify();

  return $c->res->redirect($c->uri_for('/hfe/games'));
}

sub make_move_form :Path('make_move_form') :Does('NeedsLogin') :LoginRedirectMessage("Need to log in to make a move.") {
  my ($self, $c) = @_;

  $c->stash->{game} = $c->model('DB::Game')->find({id => $c->req->parameters->{game_id}});
}

sub make_user_form :Path('make_user_form') {
}

'Is there anybody there?';
