package Moadbook::C::Auth;

use parent 'Mojolicious::Controller';
use utf8;


sub login {
	my $self = shift;

	if ($self->is_post_method) {
		my $login_id = $self->config->{sys}->{login_id};
		my $login_password = $self->config->{sys}->{login_password};

		if ($login_id eq $self->param('login_id')
				&& $login_password eq $self->param('login_password')) {
			$self->session->{login_id} = $login_id;
			return $self->redirect_to('index');
		}

		$self->set_error_messages('IDまたはパスワードが間違っています。');
		return $self->render();
	}

	$self->set_result_message('ログインしました。');
	$self->render();
}


sub logout {
	my $self = shift;
	$self->session(expires => 1);
	return $self->redirect_to('auth/login');
}

sub check {
	my $self = shift;

	if ($self->session->{login_id}) {
		return 1;
	}

	return $self->redirect_to('auth/login');
}

1;
