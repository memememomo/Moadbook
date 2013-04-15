package Moadbook::M::Base;

use Mojo::Base -base;
use utf8;

has 'c';


sub teng {
	shift->c->teng;
}

sub _m {
	shift->c->_m(@_);
}

sub exception {
	shift->c->exception(@_);
}

1;
