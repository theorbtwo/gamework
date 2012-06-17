package GameWork::Web::View::JSON;

use strict;
use base 'Catalyst::View::JSON';

__PACKAGE__->config({
                     expose_stash => 'return',
});

=head1 NAME

GameWork::Web::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<GameWork::Web>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

James Mastros,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
