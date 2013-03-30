package Moadbook::M::Base;

use parent 'Mojo::Base';

has 'c';

sub teng {
	shift->c->teng;
}

sub _m {
	shift->c->_m(@_);
}

1;
