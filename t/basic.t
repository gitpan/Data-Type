use Test;
BEGIN { plan tests => 5; $| = 0 }

use strict; use warnings;

use Data::Type qw(:all);
use Error qw(:try);
use IO::Extended qw(:all);

	try
	{
			# NUM

		verify( '0' , NUM( 20 ) );

		verify( '234' , NUM( 20 ) );

			# BOOL

		verify( '1' , BOOL( 'true' ) );

			# INT

		verify( '100' , INT );

			# REAL

		verify( '1.1' , REAL );

			# GENDER

		verify( 'male' , GENDER );

			# REF

		my $bla = 'blalbl';
			
		verify( bless( \$bla, 'SomeThing' ) , REF );

		verify( bless( \$bla, 'SomeThing' ) , REF( qw(SomeThing) ) );

		verify( bless( \$bla, 'SomeThing' ) , REF( qw(SomeThing Else) ) );

		verify( [ 'bla' ] , REF( 'ARRAY' ) );

		verify( 'yes' , YESNO );

		verify( 'no' , YESNO );

		verify( "yes\n" , YESNO );

		verify( "no\n" , YESNO );

		verify( '01001001110110101' , BINARY );

		verify( '0F 0C 0A' , HEX );

		ok(1);
	}
	catch Type::Exception with
	{
		ok(0);
		
		use Data::Dumper;
		
		print Dumper shift;
	};

	try
	{			
		my $bla = 'blalbl';

		verify( bless( \$bla, 'SomeThing' ) , REF( 'Never' ) );

		ok(0);
	}
	catch Type::Exception with
	{
		ok(1);
	};

	try
	{
		verify( 'bla' , REF );
		
		ok(0);
	}
	catch Type::Exception with
	{
		ok(1);
	};

	try
	{
		verify( 'aaa01001001110110101' , BINARY );
		
		ok(0);
	}
	catch Type::Exception with
	{
		ok(1);
	};

	try
	{
		verify( 'gg0F 0C 0A' , HEX );
		
		ok(0);
	}
	catch Type::Exception with
	{
		ok(1);
	};
