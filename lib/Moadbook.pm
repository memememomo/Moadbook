package Moadbook;
use Mojo::Base 'Mojolicious';
use DBI;
use Teng::Schema::Loader;
use Mojo::Loader;
use Moadbook::Exception;
use HTML::FillInForm::Lite;

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
			  suppress_row_objects => 1,
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

  # リクエストをハッシュに変換
  $self->helper(req_to_hash => sub {
	  shift->req->params->to_hash;
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

  # 例外
  $self->helper(exception => sub { 'Moadbook::Exception' });

  # FillInForm
  $self->helper(render_filled_html => sub {
	  my $self = shift;
	  my $params = shift;
	  my $html = $self->render_partial(@_)->to_string;

	  my $fill = HTML::FillInForm::Lite->new(fill_password => 1);
	  $self->render_text(
		  $fill->fill(\$html, $params),
		  format => 'html',
	  );
  });

  # Router
  my $r = $self->routes;

  # Namespace
  $r->namespaces(['Moadbook::C']);

  # Auth
  $r->any('/login')->to('auth#login')->name('auth/login');
  $r->any('/logout')->to('auth#logout')->name('auth/logout');

  my $ra = $r->bridge('/')->to('auth#check')->name('auth/check');
  $ra->any('/adbook/list/:page')->to('adbook#index', {page => 1})->name('adbook/index');
  $ra->any('/adbook/create')->to('adbook#create')->name('adbook/create');
  $ra->any('/adbook/update/:id')->to('adbook#update')->name('adbook/update');
  $ra->any('/adbook/delete/:id')->to('adbook#delete')->name('adbook/delete');
  $ra->any('/adbook/update_status')->to('adbook#update_status')->name('adbook/update_status');
}

1;
