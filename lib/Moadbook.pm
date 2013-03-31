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

  # 結果メッセージ
  $self->helper(set_result_message => sub {
	  my ($self, $message) = @_;
	  $self->flash(result_message => $message);
  });

  # エラーメッセージ
  $self->helper(set_error_messages => sub {
	  my ($self, $messages) = @_;
	  unless (ref $messages) { $messages = [$messages] }
	  $self->stash(error_messages => $messages);
  });

  # check method
  $self->helper(is_post_method => sub {
	  my $self = shift;
	  return lc($self->req->method) eq 'post' ? 1 : 0;
  });

  $self->helper(is_get_method => sub {
	  my $self = shift;
	  return lc($self->req->method) eq 'get' ? 1 : 0;
  });

  # Router
  my $r = $self->routes;

  # Namespace
  $r->namespaces(['Moadbook::C']);

  # Auth
  $r->any('/login')->to('auth#login')->name('auth/login');
  $r->any('/logout')->to('auth#logout')->name('auth/logout');

  my $ra = $r->bridge('/')->to('auth#check')->name('auth/check');
  $ra->get('/')->to('example#welcome')->name('index');
}

1;
