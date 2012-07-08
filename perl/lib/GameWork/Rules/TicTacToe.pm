package GameWork::Rules::TicTacToe;
use Moose;
use MooseX::StrictConstructor;

extends 'GameWork::Rules';

# At each row/col (0..2), the value of grid is -1 if nobody has played there, or 0 or 1 for player 0 or 1.

has 'grid', is => 'ro', default => sub {
  my $grid = [];
  for my $x (0..2) {
    for my $y (0..2) {
      $grid->[$x][$y] = -1;
    }
  }

  return $grid;
};

# which player's turn is it.
has 'current_turn', is => 'rw', default => 0;

sub at {
  my ($self, $coord) = @_;
  print STDERR "at: $self $coord\n";

  $self->grid->[$coord->[0]][$coord->[1]];
}

=item score

Should return C<undef> if the game hasn't finished, or an array-ref for the final score of each player.

Note that the scores of the two players must always sum to 1.

=cut

sub score {
  my ($self) = @_;

  my @combos;
  for my $n (0, 1, 2) {
    my $col = [[$n, 0], [$n, 1], [$n, 2]];
    my $row = [[0, $n], [1, $n], [2, $n]];
    push @combos, $col;
    push @combos, $row;
  }
  
  push @combos, [[0, 0], [1, 1], [2, 2]];
  push @combos, [[0, 2], [1, 1], [2, 0]];

  for my $combo (@combos) {
    # Fixme: remove implicit three.
    my $v = $self->at($combo->[0]);
    next if $v == -1;
    if ($self->at($combo->[1]) == $v and
        $self->at($combo->[2]) == $v) {
      if ($v == 0) {
        # If any row has all zeros, player zero has won, so the score from the point of view of player zero is 1.
        return [1, 0];
      } else {
        return [0, 1];
      }
    }
  }

  # Nobody has won yet.  If there are any spaces, then the game isn't yet done, return undef.
  for my $x (0..2) {
    for my $y (0..2) {
      if ($self->at([$x, $y]) == -1) {
        return undef;
      }
    }
  }

  # There were no spaces, the game is tied.
  return [0.5, 0.5];
}

=item valid_move

C<$old_state->valid_move($new_state)> returns true if going from old_state to new_state is a valid single move.

Should return 1 or die with a reasonable error message.  FIXME: I18n?

=cut

sub valid_move {
  my ($old, $new) = @_;

  my $mover;

  if ($old->current_turn == 0 and $new->current_turn == 1) {
    $mover = 0;
  } elsif ($old->current_turn == 1 and $new->current_turn == 0) {
    $mover = 1;
  } else {
    die "Strange mover -- from ".$old->current_turn." to ".$new->current_turn;
  }

  my $moves;

  for my $x (0..2) {
    for my $y (0..2) {
      my $o = $old->at([$x, $y]);
      my $n = $new->at([$x, $y]);
      #print "[$x, $y] -- $o -> $n\n";

      if ($old->at([$x, $y]) == $new->at([$x, $y])) {
        # boring case
      } elsif ($old->at([$x, $y]) == -1 and $new->at([$x, $y]) == $mover) {
        $moves++;
      } else {
        die "Invalid move: [$x, $y] changed from ".$old->at([$x, $y])." to ".$new->at([$x, $y])." while it was player $mover\'s turn";
      }
    }
  }

  if ($moves != 1) {
    die "Moved $moves times, expected 1?";
  }

  return 1;
}

sub pretty {
  my ($self) = @_;

  my $out = '';

  for my $x (0..2) {
    for my $y (0..2) {
      my $c = {0 => 'X',
               1 => 'O',
               -1 => '.'}->{$self->at([$x, $y])};
      $out .= $c;
    }
    $out .= "\n";
  }

  my $p = $self->current_turn;
  $out .= "Currently player $p\'s turn\n\n";

  return $out;
}


'Begin at the beginning, and when you get to the end, stop.';
