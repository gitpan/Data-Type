
# (c) 2002 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

package Data::Type::Collection::Perl::Interface;

    our @ISA = qw(Data::Type::Object::Interface);

sub prefix : method { 'Perl::' }

package Data::Type::Collection::Perl;

our @ISA = qw(Data::Type::Collection::Perl::Interface);

1;

=pod


=head1 CONTACT

Also L<http://sf.net/projects/datatype> is hosting a projects dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>


=cut
