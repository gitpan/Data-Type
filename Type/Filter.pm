
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::Filter::Interface;

	use Attribute::Abstract;

	sub desc : Abstract method;

	sub info : Abstract method;

	sub filter : Abstract method;

package Data::Type::Filter::chomp;

	our @ISA = ( 'Data::Type::Filter::Interface' );

	our $VERSION = '0.01.25';

	sub desc : method { 'chomps' }

	sub info : method { 'chomps' }
    
	sub filter : method
	{
	    my $this = shift;

	    chomp $Data::Type::value;
	}
    
package Data::Type::Filter::lc;

	our @ISA = ( 'Data::Type::Filter::Interface' );

	our $VERSION = '0.01.25';

	sub desc : method { 'lower case' }

	sub info : method { 'lower cases' }

	sub filter : method
	{
		my $this = shift;

		$Data::Type::value = lc $Data::Type::value;		
	}

package Data::Type::Filter::uc;

	our @ISA = ( 'Data::Type::Filter::Interface' );

	our $VERSION = '0.01.25';

	sub desc : method { 'upper case' }

	sub info : method { 'upper cases via "uc"' }

	sub filter : method
	{
		my $this = shift;

		$Data::Type::value = uc $Data::Type::value;
		
	}

package Data::Type::Filter::strip;

	our @ISA = ( 'Data::Type::Filter::Interface' );

	our $VERSION = '0.01.25';

	sub desc : method { 'strips text' }

	sub info : method { 'removes arbitrary substrings' }

	sub filter : method
	{
		my $this = shift;

		my $what = shift || die "strip requires one argument" ;

		$Data::Type::value =~ s/$what//go;
	}

package Data::Type::Filter::collapse;

	our @ISA = ( 'Data::Type::Filter::Interface' );

	our $VERSION = '0.01.32';

	sub desc : method { 'collapses repeats' }

	sub info : method { 'collapses any arbitrary repeats of characters to single representation' }

	sub filter : method
	{
		my $this = shift;

		my $what = shift;

		$Data::Type::value =~ s/$what{2,}/$what/go;
	}

1;

__END__

=pod

=head1 NAME

Data::Type::Filter - cleans values before subjecting to facets

=head1 INTERFACE

=over 3

=item * 
Data::Type::Filter::Interface

=over 4

=item -
$VERSION

=item -
sub desc : Abstract method;

=item -
sub info : Abstract method;

=item -
sub filter : Abstract method;

=back

=back


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut
