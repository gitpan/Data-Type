
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::Facet::Exception;

      	Class::Maker::class
       	{
       		isa => [qw( Data::Type::BaseException )],
       	};

package Data::Type::Facet::Interface;

	use Attribute::Abstract;

	sub test : Abstract method;

	sub info : Abstract method;

	sub desc : Abstract method;

	sub usage : Abstract method;

	sub _depends : method { () }

sub _load_dependency 
{
    my $this = shift;
    
    foreach ( $this->_depends )
    {
	unless( exists $Data::Type::_loaded->{$_} )
	{
	    eval "use $_;"; die $@ if $@;

	    $Data::Type::_loaded->{$_} = caller;
	}
	else
	{
	    warn sprintf "%s tried to load twice %s", $_, join( ', ', caller ) if $Data::Type::DEBUG;
	}
    }
}

package Data::Type::Facet;

	use vars qw($AUTOLOAD);

	sub AUTOLOAD
	{
		( my $func = $AUTOLOAD ) =~ s/.*:://;

	return bless [ @_ ], sprintf 'Data::Type::Facet::%s', $func;
	}

package Data::Type::Facet::__anon;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { $_[0]->info }

	sub info : method { 'anonymous facet i.e. generated from a sub reference' }

	sub test : method
	{
		my $this = shift;

		Data::Type::try 
		{
			$_[0]->();
		}
		catch Error Data::Type::with
		{
			my $e = shift;

			throw $e;
		};

		#throw Data::Type::Facet::Exception( text => 'not a reference' ) unless ref( $Data::Type::value );
	}

package Data::Type::Facet::ref;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'if its a reference' }

	sub info : method
	{
		my $this = shift;

		return sprintf $this->[0] ? 'reference' : 'reference to %s', $this->[0];
	}

	sub test : method
	{
		my $this = shift;

		throw Data::Type::Facet::Exception( text => 'not a reference' ) unless ref( $Data::Type::value );
	}

package Data::Type::Facet::range;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'if value is between a value x and y' }

	sub test : method
	{
		my $this = shift;

		throw Data::Type::Facet::Exception( text => "$Data::Type::value is not in range $this->[0] - $this->[1]" ) unless $Data::Type::value >= $this->[0] && $Data::Type::value <= $this->[1];
	}

	sub info : method
	{
		my $this = shift;

		return sprintf 'between %s - %s characters long', $this->[0], $this->[1];
	}

package Data::Type::Facet::lines;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'whether enough lines (newlines)' }

	sub test : method
	{
		my $this = shift;

		throw Data::Type::Facet::Exception( text => "not enough (new)lines found" ) unless ( $Data::Type::value =~ s/(\n)//g) > $this->[0];
	}

	sub info : method
	{
		my $this = shift;

		return sprintf '%d lines', $this->[0];
	}

package Data::Type::Facet::less;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'length is less than x' }

	sub test : method
	{
	    my $this = shift;
    
	    throw Data::Type::Facet::Exception( text => "length isnt less than $this->[0]" ) unless length($Data::Type::value) < $this->[0];
	}

	sub info : method { return sprintf 'less than %d chars long', $_[0]->[0] }

package Data::Type::Facet::max;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'scalar is numerically not exceeding x' }

	sub test : method
	{
		my $this = shift;

    		throw Data::Type::Facet::Exception() if $Data::Type::value > $this->[0];
	}

	sub info : method
	{
		my $this = shift;

		return sprintf 'maximum of %d', $this->[0];
	}

package Data::Type::Facet::min;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'scalar is numerically more than x' }

	sub test : method
	{
		my $this = shift;

    		throw Data::Type::Facet::Exception() if $Data::Type::value < $this->[0];
	}

	sub info : method
	{
		my $this = shift;

		return sprintf 'minimum of %d', $this->[0];
	}

package Data::Type::Facet::match;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'matches regexp (registered with Data::Type::Regexp)' }

	sub usage : method
	{
		return 'match( REGEX_REGISTRY_KEY ) 	REGEX_REGISTRY_KEY is a key from Data::Type::Regex::_registry'
	}
	
	sub test : method
	{
		my $this = shift;

		Data::Type::Facet::defined->test;
			
#		warn sprintf "FACET match %s value '%s' with $this->[0]", defined( $Data::Type::value ) ? 'defined' : 'undefined', $Data::Type::value;
		
		unless( $Data::Type::value =~ Data::Type::Regex->request( $this->[0], 'regex', @$this ) )
		{
		    throw Data::Type::Facet::Exception( text => Data::Type::Regex->request( $this->[0], 'desc', @$this ) ) ;
		}
	}

	sub info : method
	{
		my $this = shift;

	return sprintf 'matching a regular expression for %s', Data::Type::Regex->request( $this->[0], 'desc', @$this );
	}

package Data::Type::Facet::is;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'is == x' }

	sub test : method
	{
		my $this = shift;

   		throw Data::Type::Facet::Exception( text => "is not exact $this->[0]" ) unless $Data::Type::value == $this->[0];
	}

	sub info : method
	{
		my $this = shift;

		return sprintf 'exact %s', $this->[0];
	}

package Data::Type::Facet::defined;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.04';

	sub desc : method { 'defined() returns true' }

	sub test : method
	{
		my $this = shift;

	    	throw Data::Type::Facet::Exception( text => 'not defined value' ) unless defined $Data::Type::value;
	}

	sub info : method
	{
		my $this = shift;

		return sprintf 'defined (not undef) value';
	}

package Data::Type::Facet::bool;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'true after boolean evaluation' }

	sub test : method
	{
		my $this = shift;

		    throw Data::Type::Facet::Exception( text => "not boolean $this->[0]" ) unless $this->[0];
	}

	sub info : method
	{
		my $this = shift;

		return sprintf "boolean '%s' value", $this->[0] ? 'true' : 'false';
	}

package Data::Type::Facet::null;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'is literally "NULL" (after uppercase filter)' }

	sub test : method
	{
		my $this = shift;

   		throw Data::Type::Facet::Exception( text => "not literally NULL" ) unless uc( $Data::Type::value ) eq 'NULL';
	}

	sub info : method
	{
		my $this = shift;

		return "case-independant exact 'NULL'";
	}

package Data::Type::Facet::exists;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'exists in a hash or as an array member' }

	use Class::Multimethods;

	multimethod _exists => ( '$', 'HASH' ) => sub : method 
	{ 
		throw Data::Type::Facet::Exception( text => '$_[0] does not exist in HASH' ) unless exists $_[1]->{$_[0]};
	};

	multimethod _exists => ( '$', 'ARRAY' ) => sub : method 
	{ 
		for( @{$_[1]} )
		{
			return if $_[0] eq $_;
		}

		throw Data::Type::Facet::Exception( text => '$_[0] does not exist in array' );
	};

	multimethod _exists => ( 'ARRAY', 'HASH' ) => sub : method 
	{ 
	    _exists( $_, $_[1] ) for @{ $_[0] };
	};

	multimethod _exists => ( 'ARRAY', 'ARRAY' ) => sub : method 
	{ 
	    _exists( $_, $_[1] ) for @{ $_[0] };
	};

	sub test : method
	{
		my $this = shift;

			_exists( $Data::Type::value, @$this );
	}

	sub info : method
	{
		my $this = shift;

		if( ref( $this->[0] ) eq 'HASH' )
		{
			return sprintf 'element of hash keys (%s)', join( ', ', keys %{ $this->[0] } );
		}

		return sprintf 'element of array (%s)', join(  ', ', @{$this->[0]} );
	}

package Data::Type::Facet::mod10check;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'passes the mod10 LUHN algorithm check' }

	# could have used Algorithm::LUHN

	sub test : method
	{
		my $this = shift;


		eval "use Business::CreditCard;";

		die $@ if $@;

			# We use Business::CreditCard's mod10 luhn

	    	throw Data::Type::Facet::Exception( text => "mod10check failed" ) unless validate( $Data::Type::value );
	}

	sub info : method
	{
		my $this = shift;

		return 'LUHN formula (mod 10) for validation of creditcards';
	}

package Data::Type::Facet::file;

	our @ISA = qw(Data::Type::Facet::Interface);

	our $VERSION = '0.01.01';

	sub desc : method { 'whether file is existent' }

	sub usage : method { '( FILENAME )' }

	sub info : method { 'tests characteristics of file' }

	sub test : method
	{
		my $this = shift;

			throw Data::Type::Facet::Exception(

			    text => 'supplied filename does not exist',

			    value => $Data::Type::value,

			    type => __PACKAGE__

			) unless -e $Data::Type::value;

    			throw Data::Type::Facet::Exception( text => 'undefined value' ) unless defined $Data::Type::value;

			unless( $Data::Type::value =~ Data::Type::Regex->request( $this->[0], 'regex', @$this ) )
			{
    				throw Data::Type::Facet::Exception( text => Data::Type::Regex->request( $this->[0], 'desc', @$this ) ) ;
			}
	}

1;

__END__

=pod

=head1 NAME

Data::Type::Facet - a subelement of a type

=head1 EXCEPTIONS

Data::Type::Facet::Exception


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut