package Moadbook;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Template Engine
  $self->plugin('tt_renderer');

  # Load Config
  $self->plugin(config => {
	  file		=> $self->home->rel_file('/conf/'.$self->mode.'.pl'),
	  stash_key => 'config',
  });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  # Namespace
  $r->namespaces(['Moadbook::C']);

}

1;
