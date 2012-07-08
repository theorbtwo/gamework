package GameWork::Web::Controller::Root;
use Moose;
use namespace::autoclean;
use 5.10.0;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => '');

sub end : ActionClass('RenderView') {}

'This is the end.  My only friend, the end.';
