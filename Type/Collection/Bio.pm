
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::Collection::Bio::Interface;

  our @ISA = qw(Data::Type::Object::Interface);

  our $VERSION = '0.01.25';

  sub prefix : method { 'Bio::' }

package Data::Type::Regex;

  register 'dna', exact( qr/[ATGC]+/ ), 'arbitrary set of A, T, G or C';

  register 'rna', exact( qr/[AUGC]+/ ), 'arbitrary set of A, U, G or C';

register(
	 'triplet', 
	 
	 sub 
	 {
	     my $this = shift;
	     
	     my $type = lc( shift || 'dna' );

	     Carp::croak __PACKAGE__." required parameter missing dna (default) or rna" unless defined $type;

	     Carp::croak sprintf "%s triplet usage failure (dna or rna) only and not $_[1]", __PACKAGE__, $type unless $type =~ /^[rd]na$/;
	       
             return exact( $type eq 'dna' ? qr/[ATGC]{3,3}/ : qr/[AUGC]{3,3}/ ); 
	 }, 

         sub { sprintf "a triplet string of %s", $_[1] || 'dna (default) or rna' }
);

	# BIO stuff
	
	# Resources: http://users.rcn.com/jkimball.ma.ultranet/BiologyPages/C/Codons.html
	# CPAN: Bio::Tools::CodonTable
	
package Data::Type::Object::dna;

  our @ISA = qw(Data::Type::Collection::Bio::Interface Data::Type::Collection::Std::Interface::Logic);

  our $VERSION = '0.01.03';

  sub export { ('DNA') }

  sub desc : method { 'dna fragment' }

  sub info : method { q{dna sequence} }

sub usage : method { 'sequence of [ATGC]' }
	
	sub _test : method
	{
		my $this = shift;

		#warn "dt test \$Data::Type::value '$Data::Type::value'";
		
		Data::Type->filter( [ 'strip', '\s' ], [ 'chomp' ] );
		
		Data::Type::ok( 1, Data::Type::Facet::match( 'dna' ) );
	}

package Data::Type::Object::rna;

	our @ISA = qw(Data::Type::Collection::Bio::Interface Data::Type::Collection::Std::Interface::Logic);

	our $VERSION = '0.01.03';

	sub export { ('RNA') }

	sub desc : method { 'RNA fragment' }

	sub info { qq{rna sequence} }

	sub usage { 'sequence of [ATUC]' }
	
	sub _test
	{
		my $this = shift;

			Data::Type->filter( [ 'strip', '\s' ], [ 'chomp' ] );

		        Data::Type::ok( 1, Data::Type::Facet::match( 'rna' ) );
	}

package Data::Type::Object::codon;

	our @ISA = qw(Data::Type::Collection::Bio::Interface Data::Type::Collection::Std::Interface::Logic);

	our $VERSION = '0.01.03';

	sub export { ('CODON') }

        sub desc : method { 'DNA/RNA triplet' }

        sub info : method { qq{DNA (default) or RNA nucleoside triphosphates triplet} }

	sub usage : method { 'triplet of DNA or RNA' }
	
	sub _test
	{
		my $this = shift;

			Data::Type->filter( [ 'strip', '\s' ], [ 'chomp', 'uc' ] );
			
			my $kind = lc( $this->[0] || 'DNA' );

			Carp::croak( sprintf "'%s' expects 'DNA' or 'RNA' as an argument and not '%s'",$this->export,$kind ) unless $kind eq 'dna' || $kind eq 'rna';

		        Data::Type::ok( 1, Data::Type::Facet::match( 'triplet', $kind ) );
	}

1;

=pod

=head1 NAME

Data::Type::Collection::Bio - types from databases

=head1 SYNOPSIS

        print "found dna" if shift and is BIO::DNA;

	valid 'AUGGGAAAU',	BIO::RNA;
	valid 'ATGCAAAT',	BIO::DNA;

	try
	{
		typ ENUM( qw(DNA RNA) ), \( my $a, my $b );

		print "a is typ'ed" if istyp( $a );

		$a = 'DNA';		# $alias only accepts 'DNA' or 'RNA'
		$a = 'RNA';
		$a = 'xNA';		# throws exception

		untyp( $alias );
	}
	catch Data::Type::Exception with
	{
		printf "Expected '%s' %s at %s line %s\n",
			$e->value,
			$e->type->info,
			$e->file,
			$e->line;
	};

 valid 'AUGGGAAAU', BIO::RNA;
 valid 'ATGCAAAT',  BIO::DNA;

=head1 DESCRIPTION

Everything that is related to biochemical matters.

[Note] Also a fictive C<BIO::ATOM> which would count to the chemical matters would go into that collection.

=head1 TYPES


=head2 BIO::CODON

DNA/RNA triplet

=over 2

=item VERSION

0.01.03

=item USAGE

triplet of DNA or RNA

=back

=head2 BIO::DNA

dna fragment

=over 2

=item VERSION

0.01.03

=item USAGE

sequence of [ATGC]

=back

=head2 BIO::RNA

RNA fragment

=over 2

=item VERSION

0.01.03

=item USAGE

sequence of [ATUC]

=back



=head1 INTERFACE


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut
