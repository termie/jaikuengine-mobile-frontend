# $Id: 24c14n.t 547 2004-11-14 19:37:33Z pajas $

##
# these testcases are for xml canonization interfaces.
#

use Test;
use strict;

BEGIN { plan tests => 14 };
use XML::LibXML;
use XML::LibXML::Common qw(:libxml);

my $parser = XML::LibXML->new;

{
    my $doc = $parser->parse_string( "<a><b/> <c/> <!-- d --> </a>" );

    my $c14n_res = $doc->toStringC14N();
    ok( $c14n_res, "<a><b></b> <c></c>  </a>" );

    $c14n_res = $doc->toStringC14N(1);
    ok( $c14n_res, "<a><b></b> <c></c> <!-- d --> </a>" );
}

{
    my $doc = $parser->parse_string( '<a><b/><![CDATA[ >e&f<]]><!-- d --> </a>' );
    
    my $c14n_res = $doc->toStringC14N();
    ok( $c14n_res, '<a><b></b> &gt;e&amp;f&lt; </a>' );
    $c14n_res = $doc->toStringC14N(1);
    ok( $c14n_res, '<a><b></b> &gt;e&amp;f&lt;<!-- d --> </a>' );
}

{
    my $doc = $parser->parse_string( '<a a="foo"/>' );
    
    my $c14n_res;
    $c14n_res = $doc->toStringC14N(0);
    ok( $c14n_res, '<a a="foo"></a>' );
}

{
    my $doc = $parser->parse_string( '<b:a xmlns:b="http://foo"/>' );
    
    my $c14n_res;
    $c14n_res = $doc->toStringC14N(0);
    ok( $c14n_res, '<b:a xmlns:b="http://foo"></b:a>' );
}


# ----------------------------------------------------------------- #
# The C14N says: remove unused namespaces, libxml2 just orders them
# ----------------------------------------------------------------- #
{
    my $doc = $parser->parse_string( '<b:a xmlns:b="http://foo" xmlns:a="xml://bar"/>' );
    
    my $c14n_res;
    $c14n_res = $doc->toStringC14N(0);
    ok( $c14n_res, '<b:a xmlns:a="xml://bar" xmlns:b="http://foo"></b:a>' );

    # would be correct, but will not work.
    # ok( $c14n_res, '<b:a xmlns:b="http://foo"></b:a>' );
}

# ----------------------------------------------------------------- #
# The C14N says: remove redundant namespaces
# ----------------------------------------------------------------- #
{
    my $doc = $parser->parse_string( '<b:a xmlns:b="http://foo"><b:b xmlns:b="http://foo"/></b:a>' );
    
    my $c14n_res;
    $c14n_res = $doc->toStringC14N(0);
    ok( $c14n_res, '<b:a xmlns:b="http://foo"><b:b></b:b></b:a>' );
}

{
    my $doc = $parser->parse_string( '<a xmlns="xml://foo"/>' );
    
    my $c14n_res;
    $c14n_res = $doc->toStringC14N(0);
    ok( $c14n_res, '<a xmlns="xml://foo"></a>' );
}

{
    my $doc = $parser->parse_string( <<EOX );
<?xml version="1.0" encoding="iso-8859-1"?>
<a><b/></a>
EOX

    my $c14n_res;
    $c14n_res = $doc->toStringC14N(0);
    ok( $c14n_res, '<a><b></b></a>' );
}

print "# canonize with xpath expressions\n";
{
    my $doc = $parser->parse_string( <<EOX );
<?xml version="1.0" encoding="iso-8859-1"?>
<a><b><c/><d/></b></a>
EOX
    my $c14n_res;
    $c14n_res = $doc->toStringC14N(0, "//d" );
    ok( $c14n_res, '<d></d>' );
}

{
    my $doc = $parser->parse_string( <<EOX );
<?xml version="1.0" encoding="iso-8859-1"?>
<a xmlns="http://foo/test#"><b><c/><d><e/></d></b></a>
EOX
    my $rootnode=$doc->documentElement;
    my $c14n_res;
    $c14n_res = $rootnode->toStringC14N(0, "//*[local-name()='d']");
    ok( $c14n_res, '<d></d>' );
    ($rootnode) = $doc->findnodes("//*[local-name()='d']");
    $c14n_res = $rootnode->toStringC14N();
    ok( $c14n_res, '<d xmlns="http://foo/test#"><e></e></d>' );
    $rootnode = $doc->documentElement->firstChild;
    $c14n_res = $rootnode->toStringC14N(0);
    ok( $c14n_res, '<b xmlns="http://foo/test#"><c></c><d><e></e></d></b>' );
}
