package MonkeyPatch;

use strict;
use warnings;

no strict 'refs';
no warnings qw/redefine syntax/;

our %FUNCTIONS_PATCHED = ();

sub patch {
	my %param = ();

	if (scalar @_ == 1) {
		%param = ( $_[0] => sub {} );
	} else {
		%param = @_;
	}

	for my $name (keys %param) {
		my $sub = $param{$name};

        $name = findGlobNameByRef($name);
        if (!defined($FUNCTIONS_PATCHED{$name})) {
            $FUNCTIONS_PATCHED{$name} = \&{*{$name}};
        }

        *{$name} = $sub || sub {};
	}
}

sub findGlobNameByRef {
    my ($functionRef) = @_;
    if ($functionRef =~ /^CODE\([\da-fx]+\)/) {
        foreach my $globName (keys %::) {
            my $globRef = \&{$::{$globName}};
            if ($functionRef eq $globRef) {
                if (index( $globName, '::' ) == -1) {
                    $globName = 'main::'.$globName;
                }
                return $globName;
            }
        }
    }
    return $functionRef;
}

sub runOriginal {
	my $name = shift;

    $name = findGlobNameByRef($name);
	if (defined($FUNCTIONS_PATCHED{$name})) {
        return &{$FUNCTIONS_PATCHED{$name}}(@_);
    } else {
		return *{$name}->(@_);
	}
}

sub unpatch {
	my @names = @_;

	for my $name (@names) {
        $name = findGlobNameByRef($name);
        if (defined($FUNCTIONS_PATCHED{$name})) {
            *{$name} = \&{$FUNCTIONS_PATCHED{$name}};

            $FUNCTIONS_PATCHED{$name} = undef;
            delete $FUNCTIONS_PATCHED{$name};
        }
	}
}

sub unpatchAll {
	unpatch(keys %FUNCTIONS_PATCHED);
	%FUNCTIONS_PATCHED = ();
}

1;

