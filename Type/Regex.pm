
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::Regex;

	use Regexp::Common;

	sub exact { '^'.$_[0].'$' }

		# registry is filled by ::Collection::* classes
		# and should be available very early. Thats why this
		# package is within a BEGIN block.

		# USAGE for field values are qr// or  sub ( ID, FIELD, @_ ) { }
 		#
		#	where $_registry->{ID}->{FIELD}

	our $_registry;

	register( 'email', qr/(?:[^\@]*)\@(?:\w+)(?:\.\w+)+/, 'primitiv regex for email' );

		# register( 'id', qr//, 'description' )
		#
		# add a regular expression to $_registry
		
	sub register : method
	{
		my $this = shift if $_[0] eq __PACKAGE__;

		my $id = shift;

		my $regex = shift;

		my $desc = shift;

			$id and $regex and $desc or Carp::croak "usage error: register( ID, REGEX, DESC )";

			$Data::Type::Regex::_registry->{$id}->{regex} = $regex;

			$Data::Type::Regex::_registry->{$id}->{desc} = $desc;

			$Data::Type::Regex::_registry->{$id}->{created} = [ caller ];
	}

		# request( 'domain', 'desc' ) - returns ->{domain}->{desc}
		# request( 'domain', 'regex' ) - returns ->{domain}->{regex}
		#
		# alternativly a coderef will lead to execution and return result

	sub request
	{
		my $this = shift;

		my $id = shift;
		
		my $field = shift;

		if( exists $_registry->{$id} )
		{
			if( exists $_registry->{$id}->{$field} )
			{
				my $x = $_registry->{$id}->{$field};

				return ref($x) eq 'CODE' ? $x->( @_ ) : $x;
			}
			
			Carp::croak "$id is not a registered in Data::Type::Regex";
		}

		Carp::croak "$id is not a registered in Data::Type::Regex";
	}

1;

=pod

=head1 NAME

Data::Type::Regex - regex based data types made easy

=head1 API

=over 3

=item *
register( $id, $regex, $desc )

=item *
request( $id, $field )

Example: request( 'domain', 'desc' ) returns the ->{desc} field of the 'domain' regex

=back

=head1 CATALOG


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut
