package GameWork::Web::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

#around 'render' => sub {
#  my $orig = shift;
#  my ($orig, $self, $c) = @_;
#
#  print "In HTML render\n";
#  $orig->(@_);
#};

=head1 NAME

GameWork::Web::View::HTML - TT View for GameWork::Web

=head1 DESCRIPTION

TT View for GameWork::Web.

=head1 SEE ALSO

L<GameWork::Web>

=head1 AUTHOR

James Mastros,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
