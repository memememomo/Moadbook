package Moadbook::Exception;

use Mojo::Base -base;
use utf8;

has 'messages';


sub throw {
	my ($class, $messages) = @_;
	if (ref $messages ne 'ARRAY') {
		$messages = [$messages];
	}
	my $e = __PACKAGE__->new;
	$e->messages($messages);
	die $e;
}

sub catch {
	my ($class, $e) = @_;

	return undef unless $@;

	if (ref $e eq __PACKAGE__) {
		return $e;
	}
	else {
		die $e;
	}
}

1;
