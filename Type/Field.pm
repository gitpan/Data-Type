
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

# $Revision: 1.1 $
# $Header: /cygdrive/y/cvs/perl/modules/Data/Type/Type/Field.pm.tmpl,v 1.1 2003/04/02 11:38:22 Murat Exp $

	#
	# Requesting Data::Type Objects
	#

package Data::Type::Field;

use Attribute::Abstract;

Class::Maker::class
{
  public => 
    {
	string => [qw( mask )],

      scalar => [qw( desc prompt type usage default required )]
    },

};

# mask => '(###)-###-####)'   # a simple mask for input prompt (in this example a telefon number

# desc => 'more complete textual description',

# prompt => 'Do you accept this',

# type => YESNO,

# usage => [yes|no]

# default => 'yes',

# required => 1

package Data::Type::Field::OneOfMany;  # yes/no, true/false, 

	our @ISA = qw(Data::Type::Field);

package Data::Type::Field::ManyOfMany;  

	our @ISA = qw(Data::Type::Field);

sub get_from_shell : method
{
  my $this = shift;

    my ($desc, $choices, $default) = @_;

    my $tries = 1;

    local $| = 1;

    my ( $default_choice, $cnt ) = ( 0, 0 );

	print $desc, "\n";

        for ( @$choices ) 
	{ 
	    $cnt++;

	    printf "  %d) %s %s\n", $cnt, $_, $default eq $_ ? '(default)' : '';
	    
	    $default_choice = $cnt if $default eq $_;
	}

    while (1) 
    {	    
	print "Select item 1-$cnt [$default_choice]: ";

	chomp(my $input=<STDIN>);

	no warnings;

	my $answer = defined $input ? $input+0 : $default_choice;

	return $choices->[$answer-1] if $answer >= 0 && $answer <= $cnt;

	print "Please choose from 1 - $cnt\n";

	print "And quit screwing around.\n" and $tries = 0 if ++$tries > 3;
    }
}

1;

=pod


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut
