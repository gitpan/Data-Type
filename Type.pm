
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

# $Revision: 1.39 $
# $Header: /cygdrive/y/cvs/perl/modules/Data/Type/Type.pm.tmpl,v 1.39 2003/04/12 12:48:38 Murat Exp $

use Data::Type::Regex;

package Data::Type;

	our $VERSION = "0.01.15";

	our $DEBUG = 0;

	require 5.005_62; use strict; use warnings;

	use Carp;

	use Class::Maker;

	use Class::Maker::Exception qw(:try);
	
	use Locale::Language;	# required by langcode langname
	
	use IO::Extended qw(:all);
	
	use Data::Iter qw(:all);
	
	use Exporter;

	our @ISA = qw( Exporter );

	use subs qw(try with);
		
	our %EXPORT_TAGS = 
        ( 
	  'all' => [qw(is isnt valid dvalid catalog toc summary try with)],

	  'valid' => [qw(is isnt valid dvalid)],

	  'inspect' => [qw(catalog toc summary)],

	  'try' => [qw(try with)],
	);
	
	our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
	
	our @EXPORT = ();

         # modules loaded registry (used by _load_dependency method)

        our $_loaded = {};

        our @_requested;

        sub import
        {
	    @_requested = ();

	    push @_requested, 'Std';
	    	    
	    my @copy;
	    
	    foreach my $id (my @args = @_) 
	    {      
		if( $id =~ /^\+/ )
		{
		    $id =~ s/^\+//;
		    
		    push @_requested, $id;	      	      		  
		}	      
		else
		{
		    push @copy, $id;
		}
	    }
	    
	    my %requested;
	    
	    $requested{$_} = '' for @_requested;
	    
	    @_requested = grep { !/^Std$/ } keys %requested;
	    
	    warn sprintf "Following collection where requested to export: %s", join( ', ', @Data::Type::requested) if $Data::Type::DEBUG;         
	    foreach ( 'Std', @_requested )
	    {
		eval "use Data::Type::Collection::$_;"; die $@ if $@;
		
		codegen( $_.'::' );
	    }
	    
	    @_ = @copy;
	    
	    __PACKAGE__->export_to_level(1, @_);
	}

package Data::Type::Entry;

	Class::Maker::class
    	{
	    public => 
	    {
		bool => [qw( expected )],
		
		ref  => [qw( object )],
	    },
	};

package Data::Type::L18N;

        use strict;

	use Locale::Maketext;

	our @ISA = qw( Locale::Maketext );

package Data::Type::L18N::de;

	our @ISA = qw(Data::Type::L18N);

	use strict;

	use vars qw(%Lexicon);

	our %Lexicon =
     	(
		__current_locale__ => 'deutsch',

		"Can't open file [_1]: [_2]\n" => "Problem beim öffnen der datei [_1]. Grund: [_2]\n",

		"You won!" => "Du hast gewonnen!",
	);

package Data::Type::L18N::en;

	our @ISA = qw(Data::Type::L18N);

	use strict;

	use vars qw(%Lexicon);

	our %Lexicon =
	(
		__current_locale__ => 'english',

		"Can't open file [_1]: [_2]\n" => "Can't open file [_1]: [_2]\n",

		"You won!" => "You won!",
	 );

package Data::Type::Proxy;

	use vars qw($AUTOLOAD);

	sub AUTOLOAD
	{
		( my $func = $AUTOLOAD ) =~ s/.*:://;

	return bless [ @_ ], Data::Type::_name_to_package( lc $func );
	}

  #
  # The universal "Data::Type::Object Interface"
  #

package Data::Type::Object::Interface;

use Attribute::Abstract;

sub desc : method
{
    warn "abstract method called" if $Data::Type::DEBUG;
    
    return 'Universal';
}

# static string

sub info : Abstract method;

# shell commando like usage

sub usage { '' } #: Abstract method;

# holds the logic of type validation. Should use Data::Type::ok()
# to dispatch public and private facets

sub test
{
  my $this = shift;

  $this->_load_dependency;	
		
return $this->_test( @_ );
}

# return scalar/array/hash of alternativ choices when an inputfield
# is generated for this type

sub choice : Abstract method;

# returns a data structure used for the configuration/parameterization of
# the datatype

sub param : Abstract method;

# If some default value for C<param> exists, they should be returned
# by this function

sub default : Abstract method;

# returns an array of required modules for this type
# [note] used to build a dependency tree

sub basic_depends : method { qw() }

sub _depends { () }

sub depends : method 
{ 
	my $this = shift;
	
	my @d = ();

	@d = $this->_depends;
	
return ( @d, $this->basic_depends );  
}

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

# No idea ?

sub to_text : Abstract method;

# api for casting of types
# Usage: my $a_castedto_b = TYPE_A->cast( TYPE_B );
# [note] Ideally use C<Class::Multimethods> for dispatching

sub cast : Abstract method;

# return static text of some sort of "manpage" for this type

sub doc : Abstract method; # A descriptive information about the interface should be placed here.

# returns a scalar. This should be implemented by an Data::Type::Collection::*::Interface class
# which is then used when generating the final exportname with C<exported>

sub prefix : method
{
	Carp::croak "abstract method prefix called";
}


# return array of alias's for that type 

sub export : method
{	    
    my $this = shift;
    
    $this ||= ref($this);
    
    return (  Data::Type::_package_to_name( $this ) );
}

# return array of alias's for that type, including a prefix
# if this type is part of a collection

sub exported : method
{
  my $this = shift;
  
  map { Data::Type::_genname( $this->prefix().$_ ) } $this->export;
}	

use String::ExpandEscapes;

sub pod : method
{ 
  my $this = shift;

  my $href = shift;

  my $escapes = {
		 e => join( ', ', $this->exported ),
		 d => $this->desc,
		 v => $this->VERSION,
		 u => $this->usage,
		 m => join(', ', map { "L<$_>" } $this->_depends),
		};
      
  my @fields;

  push @fields, '=head2 %e', '%d';

  if( $this->usage || $this->_depends )
  {
      push @fields, '=over 2';
      
      push @fields, '=item VERSION', '%v' if $escapes->{v};
      
      push @fields, '=item USAGE', '%u' if $escapes->{u};
      
      push @fields, '=item DEPENDS', '%m' if $escapes->{m};
      
      push @fields, '=back';
  }

  my $fmt = join ( "\n\n", @fields )."\n\n";

  my ($result, $error) = String::ExpandEscapes::expand( $fmt, $escapes );

  Carp::croak "Illegal escape sequence $error\n" if $error;

return $result;
}

package Data::Type::Context;

	Class::Maker::class
	{
    		public =>
    		{
    			int => [qw( failed passed )],
     
     			scalar => [qw( value )],
     
     			array => [qw( types )],
    		},
	};

package Data::Type;

		# See head of file for $VERSION variable (moved because of bug in VERSION_FROM of Makefile.pl)

		# This value is important. It gets reset to undef in valid() before the test starts. During test
		# it hold the $value of the data to tested against.

	our $value;
	
	our @_history;
	
	our %alias;       # holds alias names for type like $alias{BIO::CODON} = 'codon';
	
	no strict 'refs';

        our @_locale_handles = ( 'en' );

	our $lh = Data::Type::L18N->get_handle( @_locale_handles ) || die "What language?";

	use Data::Type::Exception;

        use Data::Type::Filter;

        use Data::Type::Facet;

		# generate Type subs
	
	sub current_locale
	{
    		my $this = shift;

    	return $lh->maketext('__current_locale__');
	}

        sub set_locale : method
        {
	    my $this = shift;

            $Data::Type::lh = Data::Type::L18N->get_handle( @_ ) || die "Locale not implented or found";
        }      

        sub esc ($) { my $cpy = $_[0] || '' ; $cpy =~ s/\n/\\n/; "'".$cpy."'" }
	
	sub strlimit
	{
		my $limit = $_[1] || 60;
	
	return length( $_[0] ) > $limit ? join('', (split(//, $_[0]))[0..$limit-1]).'..' : $_[0];
	}

	sub filter : method
	{
		my $this = shift;
		
		foreach ( @_ ) 
		{
		    my ( $name, @args ) = @{$_};

		    print " " x 2;
		    
		    my $before = $Data::Type::value;
		    
		    "Data::Type::Filter::${name}"->filter( @args );

		    print " " x 2;

		    printf '%-20s %20s(%s) %30s => %-30s', 'FILTER', $name, join(',',@args), esc( $before), esc( $Data::Type::value) if $Data::Type::DEBUG;
		    
		    print "\n";
		}
	}

			# Generate Type alias subs
			#
			# - Generate subs like 'VARCHAR' into this package
			# - These are then Exported
			#
			# Note that codegen is called above

	sub _genname
	{
		my $what = shift;

	return uc( $what );
	}

	sub _name_to_package
	{
	    my $name = shift || die "_name_to_package needs at least one parameter";

	return 'Data::Type::Object::'.$name;
	}

	sub _package_to_name
	{
	    my $p = shift || die "_package_to_name needs at least one parameter";

        return ( $p =~ /^Data::Type::Object::([^:]+)/ )[0] || die "'$p' not matchable by _package_to_name";
	}

	sub _revert_alias
	{
	
	return exists $alias{shift} ? $alias{shift} : undef;
	}

	sub _translate
	{
		my $name = shift;

	return join ', ', $name->exported;
	}

	sub expect
	{
		my $recording = shift;

		my $expected = shift;

		foreach my $that ( @_ )
		{
		    $that = bless [ $that ], 'Data::Type::Facet::__anon' if ref($that) eq 'CODE';

		    if ( $recording ) 
		    {
			push @Data::Type::_history, Data::Type::Entry->new( object => $that, expected => $expected );
		    }
		    else
		    {
			Data::Type::try
			{
				$that->test;
			}
			catch Error Data::Type::with
			{
				throw Data::Type::Exception( value => $Data::Type::value, type => $that, catched => \@_ ) if $expected;
			};
		    }
		}
	}

	our $record = 0;

	sub ok { expect( $record, @_ ) }

	sub assert { println $_[0] ? '..ok' : '..nok'}

		# Tests Types

	sub valid
	{
	    $Data::Type::value = ( @_ > 1 ) ? shift : $_;
	    
	    my $type = shift;

	    printf "%-20s %30s %-60s\n", 'VALID', esc( $Data::Type::value ), $type if $Data::Type::DEBUG;
	    
	    die "usage: valid( VALUE, TYPE )" if @_;

	    printfln "\n\nTesting %s given '%s' (%s)", ( $type->exported )[0], $value, strlimit( $type->info ) if $Data::Type::DEBUG;

	    $type->test;
	}

		# Wrapper for dieing instead of throwing exceptions

	our @err;

	sub dvalid
	{
	    my @args = @_;
	    
	    @err = ();
	
	    Data::Type::try
	    {
	      $Data::Type::value = ( @args > 1 ) ? shift @args : $_;

	      my $type = shift @args;

	      printf "%-20s %30s %-60s\n", 'DVALID', $Data::Type::value, $type if $Data::Type::DEBUG;

	      die "usage: dvalid( $Data::Type::value, $type )" if @args;

	      printfln "\n\nTesting %s given '%s' (%s)", ( $type->exported )[0], $Data::Type::value, strlimit( $type->info ) if $Data::Type::DEBUG;

	      $type->test;
	    }
	    catch Error Data::Type::with
	    {
               @err = @_;
            };

	return @err ? 0 : 1;
	}

	sub is { &dvalid }

	sub isnt { not &is }

	sub summary
	{
		@Data::Type::_history = ();

		$Data::Type::record = 1;

		$Data::Type::value = shift;

		#print Data::Dumper->Dump( [ \@_ ] );
		
		$_->test for @_;
		    
		$Data::Type::record = 0;

		return @Data::Type::_history;
	}

	sub _search_pkg
	{
		my $path = '';

		my @found;

		no strict 'refs';

		foreach my $pkg ( @_ )
		{
			next unless $pkg =~ /::$/;

			$path .= $pkg;

			if( $path =~ /(.*)::$/ )
			{
				foreach my $symbol ( sort keys %{$path} )
				{
					if( $symbol =~ /(.+)::$/ && $symbol ne 'main::' )
					{
						push @found, "${path}$1";
					}
				}
			}
		}

	return @found;
	}
                                                 
	sub type_list_as_packages { map { die if $_ =~ /Interface/; $_ } grep { $_ ne 'Data::Type::Object::Interface' and $_->isa( 'Data::Type::Object::Interface' ) } _search_pkg( 'Data::Type::Object::' ) }

	sub type_list { map { _package_to_name($_) } type_list_as_packages() }

	sub filter_list_as_packages { grep { $_ ne 'Data::Type::Filter::Interface' and $_->isa( 'Data::Type::Filter::Interface' ) } _search_pkg( 'Data::Type::Filter::' ) }

	sub filter_list { filter_list_as_packages() }

	sub facet_list_as_packages { grep { $_ ne 'Data::Type::Facet::Interface' and $_->isa( 'Data::Type::Facet::Interface' ) } _search_pkg( 'Data::Type::Facet::' ) }

	sub facet_list { facet_list_as_packages() }

	sub l18n_list { map { /::([^:]+)$/; uc $1 } _search_pkg( 'Data::Type::L18N::' ) }

	sub _show_list
	{
		my $hash = shift;

		my $ind = shift || 2;

		my $result;

		foreach my $key (keys %$hash)
		{
			my $val = $hash->{ $key };

				# headlines

			unless( ref( $key ) )
			{
				$result .= sprintf qq|%s"%s"\n|, " " x $ind, $key;
			}
			else
			{
				$result .= sprintf qq|%s"%s"\n|, " " x $ind, $_ for @$key;
			}

				# contents

			if( ref( $val ) eq 'ARRAY' )
			{
				$result .= sprintf "\n%s  %s\n\n", " " x $ind, join( ', ', sort { $a cmp $b } @$val );
			}
			elsif( ref( $val ) eq 'HASH' )
			{
				$result .= _show_list( $val, $ind + 2 );
			}
		}

	return $result;
	}

	sub _unique_ordered
	{
		my $prev = shift;

		my @result = ( $prev );

		for ( iter \@_ )
		{
			push @result, VALUE() if VALUE() ne $prev;

			$prev = $_;
		}

	return @result;
	}

	sub toc
	{
		return '<empty toc>';

		my $result;

		use Tie::ListKeyedHash;

		tie my %tied_hash, 'Tie::ListKeyedHash';

		foreach my $pkg_name ( type_list_as_packages() )
		{
		  warn "$pkg_name will be reflected" if $Data::Type::DEBUG;

		  my @isa = _unique_ordered @{ Class::Maker::Reflection::inheritance_isa( @{ $pkg_name.'::ISA' } ) };

		  # this is brute and could become a trouble origin

		  @isa = grep { $_ ne 'Data::Type::Object::Interface' and $_->isa( 'Data::Type::Object::Interface' ) } @isa;

		  Carp::croak "$pkg_name has invalid isa tree with @isa" unless @isa;

		  my $special_key = [ _unique_ordered map { $_->can( 'desc' ) ?  $_->desc : () } @isa ];
		  
		  print Data::Dumper->Dump( [ \@isa, $special_key ] ); # if $Data::Type::DEBUG;

		  $tied_hash{ $special_key } = [] unless defined $tied_hash{ $special_key };

		  push @{ $tied_hash{ $special_key } }, sprintf( '%s', _translate( $pkg_name ) );
		}

		$result .= _show_list \%tied_hash;

	return $result;
	}

	sub _export
	{
		my $what = shift;

		foreach my $where ( @_ )
		{
			my $c = sprintf "sub %s { Data::Type::Proxy::%s( \@_ ); };", $where, $what;

			println $c if $Data::Type::DEBUG;

			eval $c;

			warn $@ if $@;
		}
	}

	sub codegen
	{
	    my $prefix = shift;

	    warn "codegen for prefix $prefix" if $Data::Type::DEBUG;

		my @aliases;

		foreach my $type ( Data::Type::type_list() )
		{
		  printfln "generating code for %s", $type if $Data::Type::DEBUG;
		  
		  my $p = _name_to_package($type)->prefix;

		  warnfln "codegen if $p eq $prefix" if $Data::Type::DEBUG;

		  if( $p eq $prefix )
		  {
			_export( $type, _genname( _name_to_package($type)->exported ) );

			push @aliases, _genname( _name_to_package($type)->exported );

			$alias{$_} = $type for @aliases;
		  }
		}

	        if( @aliases )
		{
		    warnfln sprintf "use subs qw(%s);", join ' ', @aliases if $Data::Type::DEBUG;

		    eval sprintf "use subs qw(%s);", join ' ', @aliases;

		    warn $@ if $@;
		}
	}

1;

__END__

=head1 NAME

Data::Type - robust, extensible data- and valuetype system

=head1 SYNOPSIS


  use Data::Type qw(:all +W3C)  # or +BIO, +DB

=over 3

=item PROCEDURAL

  warn 'invalid email' unless is STD::EMAIL;

  dvalid( $email, STD::EMAIL ) or die $Data::Type::err;                # Exceptions are stored in $Data::Type::err

=item OBJECT-ORIENTED

  try
  {
    valid '01001001110110101', STD::BINARY;
  }
  catch Data::Type::Exception with
  {
    my $dte = shift;

    foreach my $dt ( summary( $dte->type ) )
    {
      printf "\texpecting it %s %s ", $dt->[1] ? 'is' : 'is NOT', $dt->[0]->info();
    }
  };

  foreach my $dt ( STD::EMAIL, STD::WORD, STD::CREDITCARD( 'MASTERCARD', 'VISA' ), STD::BIO::DNA, STD::HEX )
  {
    print $dt->$_ for qw(VERSION info usage export param)

    print "belongs to DB collection" if $dt->isa( 'Data::Type::Collection::DB::Interface' ); # is it a Database related type ?
  }


=back

=head1 DESCRIPTION



A lot of CPAN modules have a common purpose: reporting if data has some "characteristics". L<Email::Valid> is an illustrous example: reporting if a string has characteristics of an email address. The C<address()> method reports this via returning C<'yes'> or C<'no'>. Another module, another behaviour: C<Business::ISSN> tests for the characteristics of an C<International Standard Serial Number> and does this via an C<is_valid> method returning C<true> or C<false>. And so on and so on.

The key concept:

=over 3

=item * 
a unified interface to type related CPAN modules

=item * 
generic but simple API (fun to extend)

=item * 
paremeterized types
   
=item * 
alternativly exception-based or functional problem reports

=item * 
localization via C<Locale::Maketext>

=item *
a lot of syntactic sugar ( C<die unless is BIO::DNA> )

=item *
generic access through C<DBI> to catalog of data types and more

=back

This module relies, as much as its plausible, on CPAN modules doing the job in the backend. For instance C<Regexp::Common> is doing a 
lot of the regular expression testing. C<Email::Valid> takes care of the C<EMAIL> type. C<Data::Parse> can be exploited
for doing the backwork for the C<DATE> type.


=head1 DOCUMENTATION

You find a gentle introduction at L<Data::Type::Docs>. It also navigates you through the rest of the documentation. Advanced users should keep on reading here.

=head1 SUPPORTED TYPES

All types are grouped and though belong to a B<collection>. The collection is identified by a short id. All members are living in a namespace that is prefixed with it (uppercased).

=over 3

=item Standard Collection ('STD')

This is a heterogenous collection of datatypes which is loaded by default. It contains various issues from CPAN modules (i.e. business, creditcard, email, markup, regexps and etc.) and some everyday things.

=item Biochemical Collection ('BIO')

Everything that is related to biochemical matters.

=item Database Collection ('DB')

Common types from databases.
 
=item Perl5 Collection ('PERL')

Reserved. Ane day should be filled with things like language elements and name constrains (i.e. a package name).

=item Perl6 Apocalypse Collection ('PERL6')

Reserved. Placeholder for the Apocalypse and Synopsis 6 suggested datatypes for perl6.

=back

[NOTE]
Please consider the same constrains as for CPAN namespaces when using/suggesting a new ID. A short discussion on the sf.net mailinglist is rewarded with gratefullness and respect.

=head1 API

=head2 FUNCTIONS

=over 3

=item valid( $value, @types )

Verifies a 'value' against (one ore more) types or facets. If it isn't belonging to the type a C<Data::Type::Exception> object is thrown (see L<Data::Type::Exception>).

  try
  {
    valid( 'muenalan<haaar..harr>cpan.org', EMAIL );
  }
  catch Data::Type::Exception with
  {
    dump( $e ) foreach @_;
  };

=item dvalid( $value, @types )

Returns true or false instead of throwing exceptions. This is for the exception haters. For reporting, the exceptions are stored in C<$Data::Type::err> aref.

  dvalid( 'muenalan<haaar..harr>cpan.org', EMAIL ) or die dump($Data::Type::err);

=item is( $type )

Same as L<dvalid()>, but uses C<$_> instead of C<$value>. This is for syntactic sugar like:

  foreach( @nucleotide_samples )
  {
    email_to( $SETI ) unless is BIO::DNA;      # Sends "Non terrestric genome found. Suspected sequence '$_'.
  }

[Note] Dont take that example to serious. It also could have been simple RNA. Better would have been C<unless is (BIO::DNA, BIO::RNA)>.

=item summary( $value, @types )

Returns the textual representation of the facet set used while the type is verified. Gives you a clou how the type verification process is driven. You can use that to prompt the web user to correct invalid form fields.

 print summary( $cc , CREDITCARD( 'VISA' ) );

=back

=back

=back

=head1 CLASS METHODS

=over 3

=item Data::Type->set_locale( 'id' )

If there is an implemented locale package under B<Data::Type::L18N::<id>>, then you can switch to that langue with this method. Only text that may be promted to an B<end user> are seriously exposed to localization. Developers must live with B<english>.

[Note] Visit the L<LOCALIZATION> section below for extensive information.

=back

=head1 LOCALIZATION

All localization is done via L<Locale::Maketext>. The package B<Data::Type::L18N> is the base class, while B<Data::Type::L18N::<id>> is a concrete implementation.

=head2 LOCALES

=over 3

=item Data::Type::L18N::de

German. Not very complete.

=item Data::Type::L18N::eng

Complete English dictionary.

=back

And to set to your favorite locale during runtime use the C<set_locale> method of B<Data::Type> (Of course the locale must be implemented).

  use Data::Type qw(:all +DB);

    Data::Type->set_locale( 'de' );  # set to german texts

    ...

Visit the L<Data::Type::Docs::Howto/LOCALIZATION> section for more on adding your own language.

[Note] Localization is only used for texts which somehow will be prompted to the user vis the C<summary()> functions or an exception. This should help developing, for example, web applications with B<Data::Type> and you simply forward problems to the user in the correct language.

=head1 EXPORT

None per default.

=over 3

=item FUNCTIONS

C<is>, C<isnt>, C<valid>, C<dvalid>, C<catalog>, C<toc>, C<summary>, C<try> and C<with>.

Exporter sets are:

B<':all'>     [qw(is isnt valid dvalid catalog toc summary try with)]

B<':valid'>   [qw(is isnt valid dvalid)]

B<':inspect'> [qw(catalog toc summary)]

B<':try'>     [qw(try with)]

=item DATATYPES

You can control the datatypes to be exported with following parameter.

+B<Uppercase Collection Id> (i.e. B<BIO>, B<DB>, ... )

The B<STD> is loaded everytime (And you cannot unload it currently). Currently following
collections are available B<DB>, B<BIO>, B<PERL>, B<PERL6> (see above).

=back

Example:

 use Data::Type qw(:all +BIO);	# loads all functions and all datatypes belonging to the BIO collection

 use Data::Type qw(:all +DB);	# ..and all datatypes belonging to the DB collection

=head1 DATATYPES BY GROUP



=head1 PREREQUISITES

=over 2

=item *
Standard


=over 1

=item Class::Maker (0.05.17)

=item Error (0.15)

=item IO::Extended (0.05)

=item Tie::ListKeyedHash (0.41)

=item Data::Iter (0)

=item Class::Multimethods (1.70)

=item Attribute::Abstract (0.01)

=item DBI (1.30)

=item Text::TabularDisplay (1.18)

=item String::ExpandEscapes (0.01)


=back


=item *
Sorted by type

/maslib/delayed.mas, comp => '/maslib/prerequisites.mas:type_list'

=back

=head1 EXAMPLES

Some examples reside in the t/ and contrib/ directory.


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=head1 SEE ALSO

All the basic are described at L<Data::Type::Docs>. It also navigates you through the rest of the documentation.

L<Data::Type::Docs::FAQ>, L<Data::Type::Docs::FOP>, L<Data::Type::Docs::Howto>, L<Data::Type::Docs::RFC>, L<Data::Type::Facet>, L<Data::Type::Filter>, L<Data::Type::Query>, L<Data::Type::Collection::Std>

And these CPAN modules:

L<Data::Types>, L<String::Checker>, L<Regexp::Common>, L<Data::FormValidator>, L<HTML::FormValidator>, L<CGI::FormMagick::Validator>, L<CGI::Validate>, L<Email::Valid::Loose>, L<Embperl::Form::Validate>, L<Attribute::Types>, L<String::Pattern>, L<Class::Tangram>, L<WWW::Form> 

=head2 W3C XML Schema datatypes

http://www.w3.org/TR/xmlschema-2/

=head2 Synopsis 6 by Damian Conway, Allison Randal

http://www.perl.com/pub/a/2003/04/09/synopsis.html?page=3

=cut
