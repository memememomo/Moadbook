package Moadbook::Validator;

use strict;
use warnings;
use utf8;
use Carp;
use Email::Valid;
use Email::Valid::Loose;


sub INT { $_[0] =~ /\A[+\-]?[0-9]+\z/ }
sub UINT { $_[0] =~ /\A[0-9]+\z/ }
sub LENGTH {
	my $target = shift;
	my $length = length($target);
    my $min    = shift;
    my $max    = shift || $min;
	Carp::croak("missing \$min") unless defined($min);

    ( $min <= $length and $length <= $max )
}

sub EMAIL {
	Email::Valid->address($_[0]);
}

sub EMAIL_LOOSE {
	Email::Valid::Loose->address($_[0]);
}

sub EMAIL_LOOSE_LOOSE {
	my ($email) = @_;

	return 0 if length $email > 255;

	my @e = split /@/, $email;
	return 0 if @e > 2;

	my ($user, $domain) = ($e[0], $e[1]);

	return 0 if !$user || !$domain;
	return 0 if $user =~ /@/ || $domain =~ /@/;

	return 0 if $user !~ m(^[a-zA-Z0-9_.\-+/?&$%|!#~^'*={}`]+$);

	return 0 if $domain !~ /\./;
	return 0 if $domain =~ /(^\.)|(\.\.)|(\.$)/;

	return 0 if $domain !~ /^[a-zA-Z0-9.-]+$/;

	return 1;
}

sub CHOICE {
	my $target = shift;

	Carp::croak("missing \$choices") if @_ == 0;

    my @choices = @_==1 && ref$_[0]eq'ARRAY' ? @{$_[0]} : @_;

    for my $c (@choices) {
        if ($c eq $target) {
            return 1;
        }
    }
    return 0;
}

sub DATE {
	my ($y, $m, $d) = @_;

    return 0 if ( !$y or !$m or !$d );

    if ($d > 31 or $d < 1 or $m > 12 or $m < 1 or $y == 0) {
        return 0;
    }
    if ($d > 30 and ($m == 4 or $m == 6 or $m == 9 or $m == 11)) {
        return 0;
    }
    if ($d > 29 and $m == 2) {
        return 0;
    }
    if ($m == 2 and $d > 28 and !($y % 4 == 0 and ($y % 100 != 0 or $y % 400 == 0))){
        return 0;
    }
    return 1;
}

sub HIRAGANA { _delsp($_[0]) =~ /^\p{InHiragana}+$/  };
sub KATAKANA { _delsp($_[0]) =~ /^\p{InKatakana}+$/  };
sub JTEL     { $_[0] =~ /^0\d+\-?\d+\-?\d+$/        };
sub JZIP     { $_[0] =~ /^\d{3}\-\d{4}$/            };

sub TIME {
    my ($h, $m, $s) = @_;

    return 0 if (!defined($h) or !defined($m));
    return 0 if ("$h" eq "" or "$m" eq "");
    $s ||= 0; # optional

    if ( $h > 23 or $h < 0 or $m > 59 or $m < 0 or $s > 59 or $s < 0 ) {
        return 0;
    }

    return 1;
}

sub _delsp {
	my $x = $_;
	$x =~ s/\s//g;
	return $x;
}

1;
