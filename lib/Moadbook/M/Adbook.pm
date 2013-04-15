package Moadbook::M::Adbook;

use Mojo::Base 'Moadbook::M::Base';
use utf8;
use Moadbook::Validator;


sub has_adbook {
	my ($self, $email) = @_;
	my $count = $self->teng->count('adbook', 'id', {email => $email});
	return $count ? 1 : 0;
}

sub _validate {
	my ($self, $v, $mode) = @_;

	my @errors;

	if ($mode ne 'update') {
		if (!$v->{email}) {
			push @errors, 'メールアドレスを入力してください。';
		} else {
			if (!Moadbook::Validator::EMAIL_LOOSE($v->{email})) {
				push @errors, 'メールアドレスの形式が不正です。';
			}
			if ($self->has_adbook($v->{email})) {
				push @errors, 'すでに登録されているメールアドレスです。';
			}
		}
	}

	if (!$v->{name}) {
		push @errors, '名前を入力してください。';
	}

	if (!$v->{gender}) {
		push @errors, '性別を入力してください。';
	}
	else {
		if (!Moadbook::Validator::CHOICE($v->{gender}, ['male', 'famale'])) {
			push @errors, '性別の値が不正です。';
		}
	}

	if (!$v->{age}) {
		push @errors, '年齢を入力して下さい。';
	} else {
		if (!Moadbook::Validator::UINT($v->{age})) {
			push @errors, '年齢は数字で設定してください。';
		}
	}

	if (!Moadbook::Validator::DATE(split(/-/, $v->{birthday}))) {
		push @errors, '誕生日が不正です。';
	}

	if (@errors) {
		$self->exception->throw(\@errors);
	}
}

sub create {
	my ($self, $values) = @_;
	$self->_validate($values);
	return $self->teng->insert('adbook', $values);
}

sub update {
	my ($self, $sets, $id) = @_;
	$self->_validate($sets, 'update');
	return $self->teng->update('adbook', $sets, {id => $id});
}

sub delete {
	my ($self, $id) = @_;

	my $row = $self->fetch($id);
	if ($row->{status} eq '1') {
		$self->exception->throw('ステータスが有効になっているので削除出来ません。');
	}

	return $self->teng->delete('adbook', {id => $id});
}

sub list {
	my ($self, $opts) = @_;

	my $desc = $opts->{desc} ? 'DESC' : 'ASC';
	my $page = $opts->{page} || 1;
	my $hits = $opts->{hits} || 20;

	my ($rows, $pager) =
		$self->teng->search_with_pager(
			'adbook',
			{},
			{
				page => $page,
				rows => $hits,
				order_by => '`id` ' . $desc,
			}
		);

	return wantarray ? ($rows, $pager) : $rows;
}

sub fetch {
	my ($self, $id) = @_;
	return $self->teng->single('adbook', {id => $id});
}

sub update_status {
	my ($self, $status, $id) = @_;
	return $self->teng->update('adbook', {status => $status}, {id => $id});
}

1;
