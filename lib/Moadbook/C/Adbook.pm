package Moadbook::C::Adbook;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

has 'model' => sub { shift->_m('Adbook') };


sub index {
	my $self = shift;

	my %opts;
	$opts{page} = $self->param('page');

	my ($list, $pager) = $self->model->list(\%opts);

	my %filled;
	for my $l (@$list) {
		$filled{"status_$l->{id}"} = $l->{status};
	}

	$self->stash->{list} = $list;
	$self->stash->{pager} = $pager;

	$self->render_filled_html(\%filled);
}

sub create {
	my $self = shift;

	$self->stash->{month} = [1..12];
	$self->stash->{day}   = [1..31];

	if ($self->is_post_method) {
		my $values = $self->req_to_hash;
		my $y = delete $values->{birthday_y} || 0;
		my $m = delete $values->{birthday_m} || 0;
		my $d = delete $values->{birthday_d} || 0;
		$values->{birthday} = sprintf("%04d-%02d-%02d", $y, $m, $d);

		eval {
			$self->model->create($values);
		};
		if (my $e = $self->exception->catch($@)) {
			$self->set_error_messages($e->messages);
			return $self->render_filled_html($self->req_to_hash);
		}

		$self->set_result_message('作成しました。');
		return $self->redirect_to('adbook/index');
	}

	return $self->render;
}

sub update {
	my $self = shift;

	$self->stash->{month} = [1..12];
	$self->stash->{day}   = [1..31];

	if ($self->is_post_method) {
		my $sets = $self->req_to_hash;
		my $y = delete $sets->{birthday_y};
		my $m = delete $sets->{birthday_m};
		my $d = delete $sets->{birthday_d};
		$sets->{birthday} = sprintf("%04d-%02d-%02d", $y, $m, $d);

		$self->stash->{email} = $self->param('email');

		eval {
			$self->model->update($sets, $self->param('id'));
		};
		if (my $e = $self->exception->catch($@)) {
			$self->set_error_messages($e->messages);
			return $self->render_filled_html($self->req_to_hash);
		}

		$self->set_result_message('更新しました。');
		return $self->redirect_to('adbook/update', id => $self->param('id'));
	}

	my $values = $self->model->fetch($self->param('id'));
	my ($y, $m, $d) = split(/-/, $values->{birthday});
	$values->{birthday_y} = $y;
	$values->{birthday_m} = $m;
	$values->{birthday_d} = $d;

	$self->stash->{email} = $values->{email};

	return $self->render_filled_html($values);
}

sub delete {
	my $self = shift;

	eval {
		$self->model->delete($self->param('id'));
	};
	if (my $e = $self->exception->catch($@)) {
		$self->set_result_message($e->messages->[0]);
		return $self->redirect_to('adbook/index');
	}

	return $self->redirect_to('adbook/index');
}

sub update_status {
	my $self = shift;

	for my $key (keys %{$self->req_to_hash}) {
		if ($key =~ /status_(\d+)/) {
			my $id = $1;
			my $status = $self->param($key);
			$self->model->update_status($status, $id);
		}
	}

	$self->set_result_message('ステータスを更新しました。');
	$self->redirect_to('adbook/index');
}


1;

