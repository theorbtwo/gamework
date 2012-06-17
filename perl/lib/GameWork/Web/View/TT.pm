package GameWork::Web::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

GameWork::Web::View::TT - TT View for GameWork::Web

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
