
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::Collection;

our %EXPORT_COLLECTION_TAGS = 
( 
  'all' => [ids()],
);

our @EXPORT_COLLECTION_OK = ( @{ $EXPORT_COLLECTION_TAGS{'all'} } );

our @EXPORT_COLLECTION = ();

our $_ids = 
{ 
	STD => 'Std.pm',  
	BIO => 'Bio.pm',  
	DB => 'DB.pm',  
	W3C => 'W3C.pm',  
};

our $_stds = [qw(STD)];

sub ids
{
	return keys %$_ids;
}

           # a list of collections requested for export

        sub _types 
        {
	    my %types;

	    foreach ( type_list_as_packages() )
	    {
		my $prefix = $_->prefix;
		
		$prefix =~ s/::$//;
		
		@{ $types{ $prefix } } = [] unless exists $types{$prefix };
		
		push @{ $types{ $prefix } }, $_->exported;
	    }

	    return \%types;
	}

1;
