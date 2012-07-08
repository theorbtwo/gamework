package GameWork::Schema;
use strictures 1;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces();

sub DBIx::Class::Row::DESTROY {
  my ($self) = @_;

  if ($self->is_changed) {
    die "Row dirty at DESTROY time";
  }
}

"A place for everything, and everything in it's place";
