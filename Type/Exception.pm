
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::BaseException;

        Class::Maker::class
        {
	    isa => [qw( Class::Maker::Exception )],
	    
	    public =>
	    {
		bool => [qw( expected returned )],
		
		ref => [qw( type )],
	    },
	};

package Data::Type::Exception;

        Class::Maker::class
        {
	    isa => [qw( Data::Type::BaseException )],
	    
	    public =>
	    {
		ref => [qw( value )],
		
		array => [qw( catched )],
	    },
	};
1;

=pod

=head1 NAME

Data::Type::Exception - base classes for exceptions

=head1 INTERFACE

Exceptions are implemented via the 'Error' module. C<Data::Type::Exception> is the base class inheriting from 'Error' and beeing the anchestor of any exception used within this module.

=head2 Data::Type::Exception

This exception has following members:

=over 2

=item $dte->file

The filename where the exception was thrown.

=item $dte->line

The line number.

=item $dte->type

The type 'object' used for verification.

=item $dte->value

Reference to the data subjected to verification.

=item $dte->catched

List of embedded sub-exceptions or other diagnostic details.

=back

=head2 Data::Type::Facet::Exception

Only interesting if you are creating custom types. This exception is thrown in the verification process if a facet (which is a subelement of the verification process) fails.
 

=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut
