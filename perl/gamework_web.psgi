use strict;
use warnings;

use GameWork::Web;

my $app = GameWork::Web->apply_default_middlewares(GameWork::Web->psgi_app);
$app;

