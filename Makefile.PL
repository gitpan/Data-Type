use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Data::Type',
    'VERSION_FROM'	=> 'Type.pm', # finds $VERSION
    'PREREQ_PM'		=> 
	{
	  
# the static prerequisites

'Class::Maker' => '0.05.17',
'Error' => '0.15',
'IO::Extended' => '0.05',
'Tie::ListKeyedHash' => '0.41',
'Data::Iter' => '0',
'Class::Multimethods' => '1.70',
'Attribute::Abstract' => '0.01',
'DBI' => '1.30',
'Text::TabularDisplay' => '1.18',
'String::ExpandEscapes' => '0.01',

          
# prerequisites by datatype

'Locale::Language' => '2.02', # STD::LANGCODE, STD::LANGNAME
'Business::CreditCard' => '0.27', # STD::CREDITCARD
'Email::Valid' => '0.14', # STD::EMAIL
'Business::UPC' => '0.04', # STD::UPC
'HTML::Lint' => '1.23', # STD::HTML
'Business::CINS' => '1.13', # STD::CINS
'Date::Parse' => '2.27', # STD::DATE, DB::DATE
'Business::ISSN' => '0.90', # STD::ISSN
'Net::IPv6Addr' => '0.2', # STD::IP
'Regexp::Common' => '2.113', # STD::INT, STD::IP, STD::QUOTED, STD::REAL, STD::URI, STD::ZIP
'X500::DN' => '0.28', # STD::X500::DN
'Locale::SubCountry' => '', # STD::COUNTRYCODE, STD::COUNTRYNAME, STD::REGIONCODE, STD::REGIONNAME
'XML::Parser' => '2.31', # STD::XML
'XML::Schema' => '0.07', # W3C::ANYURI, W3C::BASE64BINARY, W3C::BOOLEAN, W3C::BYTE, W3C::DATE, W3C::DATETIME, W3C::DECIMAL, W3C::DOUBLE, W3C::DURATION, W3C::ENTITIES, W3C::ENTITY, W3C::FLOAT, W3C::GDAY, W3C::GMONTH, W3C::GMONTHDAY, W3C::GYEAR, W3C::GYEARMONTH, W3C::HEXBINARY, W3C::ID, W3C::IDREF, W3C::IDREFS, W3C::INT, W3C::INTEGER, W3C::LANGUAGE, W3C::LONG, W3C::NAME, W3C::NCNAME, W3C::NEGATIVEINTEGER, W3C::NMTOKEN, W3C::NMTOKENS, W3C::NONNEGATIVEINTEGER, W3C::NONPOSITIVEINTEGER, W3C::NORMALIZEDSTRING, W3C::NOTATION, W3C::POSITIVEINTEGER, W3C::QNAME, W3C::SHORT, W3C::STRING, W3C::TIME, W3C::TOKEN, W3C::UNSIGNEDBYTE, W3C::UNSIGNEDINT, W3C::UNSIGNEDLONG, W3C::UNSIGNEDSHORT
'Pod::Find' => '0.23', # STD::POD

	},

    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Type.pm', # retrieve abstract from module
       AUTHOR     => 'muenalan@cpan.org') : ()),
);
