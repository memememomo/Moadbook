package Moadbook;
use Mojo::Base 'Mojolicious';
use DBI;
use Teng::Schema::Loader;
use Mojo::Loader;

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

  # Teng
  $self->helper(teng => sub {
	  my $self = shift;
	  $self->{__teng} ||= do {
		  my $dbh = DBI->connect(@{$self->config->{DBI}});
		  Teng::Schema::Loader->load(
			  dbh		=> $dbh,
			  namespace => 'Moadbook::DB',
		  );
	  };
  });

  # Load Model
  $self->helper(_m => sub {
	  my $self = shift;
	  my $name = shift;

	  my $model_name = 'Moadbook::M::' . $name;

	  my $e = Mojo::Loader->new->load($model_name);
	  if ($e) {
		  die $e;
	  }

	  $model_name->new(
		  c => $self,
		  @_
	  );
  });

  # Router
  my $r = $self->routes;

  # Namespace
  $r->namespaces(['Moadbook::C']);

  # Normal route to controller
  $r->get('/')->to('example#welcome');
}

1;
