use Test;
BEGIN { plan tests => 9; $| = 0 }

use strict; use warnings;

use Data::Type qw(:all +Bio);
use IO::Extended qw(:all);

ok( Data::Type::type_list() );
ok( Data::Type::_name_to_package( 'myname' ) eq 'Data::Type::Object::myname' );
ok( Data::Type::_package_to_name( 'Data::Type::Object::myname' ), 'myname' );

$_ = 'ATGC';

ok( dvalid BIO::DNA );
ok( is BIO::DNA );
ok( not isnt BIO::DNA );

$_ = 'HHHHH';

ok(not dvalid BIO::DNA);
ok(not is BIO::DNA);
ok(isnt BIO::DNA);

