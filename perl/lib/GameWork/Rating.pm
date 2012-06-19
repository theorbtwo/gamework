package GameWork::Rating;
use strictures 1;

sub update {
  # http://www.glicko.net/glicko/glicko-boost.pdf section 2.1
  my ($r, $rd, # the *initial* rating and raiting deviation for this player.
      $matches, $white_advantage) = @_;

  #my $rd_new = (1/($rd**2) + 1/($d2))**-0.5;
  #my $r_new  = $r + $rd_new**2 * $q * (sum {g($_->{rd}) * ($_->{score})} @$matches);
}

sub E {
  my ($white_advantage, $is_white, $our_rating, $other_rating, $other_deviation) = @_;

#  1/(1+10**(-g($other_deviation)*));
}

sub sum (&@) {
  my ($code, @list) = @_;

  my $sum = undef;
  for my $i (@list) {
    $sum += $code->($i);
  }

  return $sum;
}

