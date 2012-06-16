package GameWork::Rules;
use Moose;
use MooseX::StrictConstructor;
use JSON;

my $j = JSON->new;
$j->ascii(1);
# Temp; change to 0 once we're fairly certian it's working.
$j->pretty(1);

# Use ->TO_JSON to convert blessed objects to json.
$j->allow_blessed(1);
$j->convert_blessed(1);

sub serialize {
  $j->encode(shift);
}

sub TO_JSON {
  my ($self) = @_;

  +{
    d => { %{$self} },
    _blessing => ref($self),
   };
}

sub deserialize {
  my ($self, $data) = @_;

  my $decoded = $j->decode($data);

  my $blessing = $decoded->{_blessing};
  if ($blessing ne $self and 
      $self ne __PACKAGE__) {
    die "Expected a $self, got a $blessing";
  }

  bless $decoded->{d}, $blessing;

  return $decoded->{d};
}

'The rule is, jam tomorrow and jam yesterday-but never jam today.';
