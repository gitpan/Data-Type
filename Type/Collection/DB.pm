
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::Collection::DB::Interface;

    our @ISA = qw(Data::Type::Object::Interface);

    our $VERSION = '0.01.25';

    sub prefix : method { 'DB::' }

    sub desc { 'Database' }

    sub doc { 'Database types.' }

    # Add Regex's to existing one

package Data::Type::Regex;

    register 'mysql_date', exact( qr/\d{4}-[01]\d-[0-3]\d/ ), 'a date as described in the mysql doc';

    register 'mysql_datetime', exact( qr/\d{4}-[01]\d-[0-3]\d [0-2]\d:[0-6]\d:[0-6]\d/ ), 'a datetime as described in the mysql doc';

    register 'mysql_timestamp',  exact( qr/[1-2][9|0][7-9,0-3][0-7]-[01]\d-[0-3]\d [0-2]\d:[0-6]\d:[0-6]\d/ ), 'a timestamp as described in the mysql doc';

    register 'mysql_time', exact( qr/-?\d{3,3}:[0-6]\d:[0-6]\d/ ), 'a time as described in the mysql doc';
 
    register 'mysql_year4', exact( qr/[0-2][9,0,1]\d\d/ ), 'as described in the mysql doc';

    register 'mysql_year2', exact( qr/\d{2,2}/ ), 'as described in the mysql doc';

package Data::Type::Collection::DB::Interface::Mysql;

	our @ISA = qw(Data::Type::Collection::DB::Interface);

	sub desc { 'Mysql' }

	sub doc { 'Mysql types.' }

#
# Database Types
#

package Data::Type::Object::varchar;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::String);

	our $VERSION = '0.01.25';

	sub export : method { ( 'VARCHAR' ) }

	sub desc : method { 'string with a limited length' }

	sub info
	{
		my $this = shift;

		return sprintf 'string with limited length of %s', $this->[0];		
	}
	
	sub _test
	{
		my $this = shift;

		Data::Type::ok( 1, Data::Type::Facet::less( $this->[0]+1 ) );
	}

package Data::Type::Object::date_mysql;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::Temporal);

	our $VERSION = '0.01.01';

	sub _depends { qw(Date::Parse) }

        sub export : method { ( 'DATE') }

	sub desc : method { 'flexible date' }

	sub info : method 
        {

	    #The supported range is '1000-01-01' to '9999-12-31' (mysql)

	    return 'date (mysql or Date::Parse conform)';
	}

	sub usage  : method
	{
		my $this = shift;

		return q{DATE() emulates MYSQL builtin datatype};
	}

	sub _test
	{
		my $this = shift;

			Data::Type->filter( [ 'chomp' ] );
	
			Data::Type::ok( 1, Data::Type::Facet::match( 'mysql_date' ) );
	}

package Data::Type::Object::db_datetime;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::Temporal);

our $VERSION = '0.01.25';

        sub export : method { ( 'DATETIME') }

	sub desc : method { 'date and time combination'	}

	sub info
	{
		my $this = shift;

			 #The supported range is '1000-01-01 00:00:00' to '9999-12-31 23:59:59' (mysql)

		return 'date and time combination';
	}

	sub _test
	{
		my $this = shift;

			Data::Type::ok( 1, Data::Type::Facet::match( 'mysql_datetime' ) );
	}

package Data::Type::Object::timestamp;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::Temporal);

	our $VERSION = '0.01.25';

sub export : method { ( 'TIMESTAMP') }

	sub desc : method { 'timestamp'	}

	sub info { 'timestamp (mysql)'	}

	sub usage { q{[RANGE] ('1970-01-01 00:00:00' to sometime in the year 2037)} }

	sub _test
	{
		my $this = shift;

			Data::Type::ok( 1, Data::Type::Facet::match( 'mysql_timestamp' ) );
	}

package Data::Type::Object::db_time;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::Temporal);

our $VERSION = '0.01.25';

        sub export : method { ( 'TIME' ) }

	sub desc : method { 'time' }

	sub info { 'time (mysql)' }

	sub usage { q{[RANGE] ('-838:59:59' to '838:59:59')} }

	sub _test
	{
		my $this = shift;

			Data::Type::ok( 1, Data::Type::Facet::match( 'mysql_time' ) );
	}

package Data::Type::Object::year;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::Temporal);

	our $VERSION = '0.01.25';

        sub export : method { ( 'YEAR' ) }

	sub desc : method { 'year' }

	sub info { 'year in 2- or 4-digit format' }

	sub usage
	{
		return 	'The allowable values are 1901 to 2155, 0000 in the 4-digit year format, and 1970-2069 if you use the 2-digit format (70-69) (default is 4-digit)';
	}

	sub _test
	{
		my $this = shift;

			my $yformat = $this->[0] || 4;

			if( $yformat == 2 )
			{
					#1970-2069 if you use the 2-digit format (70-69);

				Data::Type::ok( 1, Data::Type::Facet::match( 'mysql_year2' ) );
			}
			else
			{
					#The allowable values are 1901 to 2155, 0000 in the 4-digit

				Data::Type::ok( 1, Data::Type::Facet::match( 'mysql_year4' ) );
			}
	}

package Data::Type::Object::tinytext;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::String);

	our $VERSION = '0.01.25';

        sub export : method { ( 'TINYTEXT' ) }

	sub desc : method { 'tiny text'	}

	sub info
	{
		my $this = shift;

		return "text with a max length of 255 (2^8 - 1) characters (alias mysql tinyblob)";
	}

	sub _test
	{
		my $this = shift;

		Data::Type::ok( 1, Data::Type::Facet::less( 255+1 ) );
	}

package Data::Type::Object::text;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::String);

	our $VERSION = '0.01.25';

        sub export : method { ( "TEXT" ) }

	sub desc : method { '"BLOB" sized dataset' }

	sub info
	{
		my $this = shift;

		return "blob with a max length of 65535 (2^16 - 1) characters (alias mysql text)";
	}

	sub _test
	{
		my $this = shift;

		Data::Type::ok( 1, Data::Type::Facet::less( 65535+1 ) );
	}

package Data::Type::Object::mediumtext;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::String);

	our $VERSION = '0.01.25';

        sub export : method { ( "MEDIUMTEXT" ) }

	sub desc : method { 'medium text' }

	sub info
	{
		my $this = shift;

		return "text with a max length of 16777215 (2^24 - 1) characters (alias mysql mediumblob)";
	}

	sub _test
	{
		my $this = shift;

		Data::Type::ok( 1, Data::Type::Facet::less( 16777215+1 ) );
	}

package Data::Type::Object::longtext;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::String);

	our $VERSION = '0.01.25';

        sub export : method { ("LONGTEXT") }

	sub desc : method { 'long text'	}

	sub info
	{
		my $this = shift;

		return "text with a max length of 4294967295 (2^32 - 1) characters (alias mysql longblob)";
	}

	sub _test
	{
		my $this = shift;

		Data::Type::ok( 1, Data::Type::Facet::less( 4294967295+1 ) );
	}

package Data::Type::Object::enum;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::Logic);

	our $VERSION = '0.01.25';

        sub export : method { ("ENUM") }
 
	sub info
	{
		my $this = shift;

			#A string object that can have only one value, chosen from the list of values 'value1', 'value2', ..., NULL or the special "" error value. An ENUM can have a maximum of 65535 distinct values (mysql)

		return qq{a member of an enumeration};
	}

	sub param { { max => 65535 } }

	sub _test
	{
		my $this = shift;

			throw Data::Type::Facet::Exception() if @$this > $this->param->{max};

			Data::Type::ok( 1, Data::Type::Facet::exists( [ @$this ] ) );
	}

package Data::Type::Object::set;

	our @ISA = qw(Data::Type::Collection::DB::Interface::Mysql Data::Type::Collection::Std::Interface::Logic);
	
	our $VERSION = '0.01.25';
	
	sub export : method { ("SET") }
	    
        sub desc : method { 'set of strings' }
	    
        sub info : method
	{
	    my $this = shift;
	    
	    # A string object that can have zero or more values, each of which must be chosen from the list of values 'value1', 'value2', ... A SET can have a maximum of 64 members. (mysql)
	    
	    return qq{a set (can have a maximum of 64 members (mysql))};
	}
	    
        sub param : method
	{
	    
	    return { limit => 64, max => 65535 };
	}
	    
        sub choice : method
	{
	    my $this = shift;
	    
	    return @$this;
   	}
	    
        sub _test : method
	{
	    my $this = shift;
	    
	    throw Data::Type::Facet::Exception( text => sprintf "exceed limit of %d", $this->param->{limit} ) if @$Data::Type::value > $this->param->{limit};
	    
	    throw Data::Type::Facet::Exception( text => sprintf "exceed maximum items of %d", $this->param->{max} ) if @$this > $this->param->{max};
	    
	    Data::Type::ok( 1, Data::Type::Facet::exists( [ @$this ] ) );
	}
	    
1;

__END__

=pod

=head1 NAME

Data::Type::Collection::DB - types from databases

=head1 SYNOPSIS

 valid ' ' x 20, DB::VARCHAR( 20 );
 valid '2001-01-01', DB::DATE( 'MYSQL' );
 valid '16 Nov 94 22:28:20 PST', DB::DATE( 'DATEPARSE' );
 valid '9999-12-31 23:59:59', DB::DATETIME;
 valid '1970-01-01 00:00:00', DB::TIMESTAMP;
 valid '-838:59:59', DB::TIME;
 valid '2155', DB::YEAR;
 valid '69', DB::YEAR(2);
 valid '0' x 20, DB::TINYTEXT;
 valid '0' x 20, DB::MEDIUMTEXT;
 valid '0' x 20, DB::LONGTEXT;
 valid '0' x 20, DB::TEXT;

=head1 DESCRIPTION

Common types from databases. All vendor-specific types should have a special prefix. 
Example:

  DB::TIME
  DB::MYSQL::TIME
  DB::ORA::TIME

=head1 TYPES


=head2 DB::DATE

flexible date

=over 2

=item VERSION

0.01.01

=item USAGE

DATE() emulates MYSQL builtin datatype

=item DEPENDS

L<Date::Parse>

=back

=head2 DB::DATETIME

date and time combination

=head2 DB::TIME

time

=over 2

=item VERSION

0.01.25

=item USAGE

[RANGE] ('-838:59:59' to '838:59:59')

=back

=head2 DB::ENUM

Mysql

=head2 DB::LONGTEXT

long text

=head2 DB::MEDIUMTEXT

medium text

=head2 DB::SET

set of strings

=head2 DB::TEXT

"BLOB" sized dataset

=head2 DB::TIMESTAMP

timestamp

=over 2

=item VERSION

0.01.25

=item USAGE

[RANGE] ('1970-01-01 00:00:00' to sometime in the year 2037)

=back

=head2 DB::TINYTEXT

tiny text

=head2 DB::VARCHAR

string with a limited length

=head2 DB::YEAR

year

=over 2

=item VERSION

0.01.25

=item USAGE

The allowable values are 1901 to 2155, 0000 in the 4-digit year format, and 1970-2069 if you use the 2-digit format (70-69) (default is 4-digit)

=back



=head1 INTERFACE


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut
