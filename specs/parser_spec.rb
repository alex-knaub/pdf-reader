$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

require 'stringio'
require 'test/unit'
require 'pdf/reader'
require 'pdf/reader/error'

class PDF::Reader::XRef
  attr_accessor :xref
end

module ParserHelper
  def parse_string (r)
    PDF::Reader::Parser.new(PDF::Reader::Buffer.new(sio = StringIO.new(r)), nil)
  end
end

context "The PDF::Reader::Parser class" do
  include ParserHelper

  specify "should be able to decode streams that use FlateDecode" do
    decoded_stream = "\n0.000 0.000 0.000 rg\n0.000 0.000 0.000 RG\nq\n1 w\nQ\nq\n1 w\nQ\nq\nq\n430.000 0 0 787.000 300.000 50.000 cm\n/I0 Do\nQ\nq\n1.000 0.000 0.000 rg\n1.000 0.000 0.000 RG\n72.000 0.000 81.156 792.000 re f\n1.000 1.000 1.000 rg\n1.000 1.000 1.000 RG\nBT 0.000 1.000 -1.000 0.000 137.303 70.000 Tm /F1 72.0 Tf 0 Tr (PDF::Writer for Ruby) Tj ET\n1 w\nQ\nBT 536.664 711.216 Td /F1 24.0 Tf 0 Tr (\n) Tj ET\nBT 170.016 684.432 Td /F1 24.0 Tf 0 Tr (Native Ruby PDF Document Creation\n) Tj ET\nBT 540.220 662.112 Td /F1 20.0 Tf 0 Tr (\n) Tj ET\nBT 357.440 639.792 Td /F1 20.0 Tf 0 Tr (The Ruby PDF Project\n) Tj ET\nBT 237.480 617.472 Td ET\nq\n0.000 0.000 1.000 rg\n0.000 0.000 1.000 RG\n1.116 w [ ] 0 d\nBT 237.480 617.472 Td 0.000 Tw /F1 20.0 Tf 0 Tr (http://rubyforge.org/projects/ruby-pdf) Tj ET\n237.480 615.798 m\n540.220 615.798 l S\n1 w\nQ\nBT 540.220 617.472 Td /F1 20.0 Tf 0 Tr (\n) Tj ET\nBT 436.340 595.152 Td 0.000 Tw /F1 20.0 Tf 0 Tr (version 1.1.2\n) Tj ET\nBT 541.998 575.064 Td 0.000 Tw /F1 18.0 Tf 0 Tr (\n) Tj ET\nBT 368.748 554.976 Td 0.000 Tw /F1 18.0 Tf 0 Tr (Copyright \251 2003\2262005\n) Tj ET\nBT 437.508 534.888 Td 0.000 Tw ET\nq\n0.000 0.000 1.000 rg\n0.000 0.000 1.000 RG\n1.0044 w [ ] 0 d\nBT 437.508 534.888 Td /F1 18.0 Tf 0 Tr (Austin Ziegler) Tj ET\n437.508 533.381 m\n541.998 533.381 l S\n1 w\nQ\nBT 541.998 534.888 Td /F1 18.0 Tf 0 Tr (\n) Tj ET\n1 w\nQ"

    buffer = PDF::Reader::Buffer.new(File.new(File.dirname(__FILE__) + "/data/pdfwriter-manual.pdf"))
    xref = PDF::Reader::XRef.new(buffer)
    buffer.seek(1445)
    parser = PDF::Reader::Parser.new(buffer, xref)
    obj = parser.object(7, 0)
    obj.should be_a_kind_of(PDF::Reader::Stream)
    obj.should eql(decoded_stream)
  end

  # TODO: replace the next spec with this pending one
  specify "should be able to decode streams that use FlateDecode with something funny about them"

  specify "should raise a MalformedPDFError when there's a problem decoding a Flated Stream" do
  decoded_stream = <<EOF
/CIDInit /ProcSet findresource begin
12 dict begin
begincmap
/CIDSystemInfo <</Registry (F1+0) /Supplement 0 >> def
/CMapName /F1+0 def
/CMapType 2 def
1 begincodespacerange <41><7A> endcodespacerange
52 beginbfchar
<41><0056>
<42><0065>
<43><0072>
<44><00F6>
<45><0066>
<46><006E>
<47><0074>
<48><006C>
<49><0069>
<4A><0063>
<4B><0068>
<4C><0075>
<4D><0067>
<4E><0020>
<4F><0044>
<50><006F>
<51><0027>
<52><0073>
<53><0061>
<54><0032>
<55><0030>
<56><0038>
<57><0053>
<58><0064>
<59><003A>
<5A><0031>
<61><002E>
<62><0033>
<63><004E>
<64><006D>
<65><0070>
<66><0050>
<67><0047>
<68><00FC>
<69><004D>
<6A><006A>
<6B><002C>
<6C><00E4>
<6D><0045>
<6E><004B>
<6F><006B>
<70><0046>
<71><007A>
<72><0049>
<73><0041>
<74><0062>
<75><002F>
<76><0042>
<77><0077>
<78><0054>
<79><0037>
<7A><0036>
endbfchar
endcmap
CMapName currentdict /CMap defineresource pop
end
end
EOF

    buffer = PDF::Reader::Buffer.new(File.new(File.dirname(__FILE__) + "/data/zlib_stream_issue.pdf"))
    xref = PDF::Reader::XRef.new(buffer)
    xref =     PDF::Reader::XRef.new(buffer)
    xref.xref[30] = Hash.new
    xref.xref[30][0] = 64379
    ref =      PDF::Reader::Reference.new(30,0)
    lambda { obj, stream = xref.object(ref) }.should raise_error(PDF::Reader::MalformedPDFError)

    # TODO: resolve why the zlib shippedwith ruby can't decompress this stream correctly
    #       then replace the the above raise_error check with the following 2 checks
    #obj.should be_a_kind_of(Hash)
    #stream.should eql(decoded_stream.strip)

  end

  specify "should parse a string correctly" do
    parse_string("this is a string)").string.should eql("this is a string")
    parse_string("this \\n is a string)").string.should eql("this \n is a string")
    parse_string("x \\t x)").string.should eql("x \t x")
    parse_string("x \\101 x)").string.should eql("x A x")
    parse_string("x \\( x)").string.should eql("x ( x")
    parse_string("(x)))").string.should eql("(x)")
    parse_string("Adobe)").string.should eql("Adobe")
    parse_string("!\"%1)").string.should eql("!\"%1")
    str = <<EOT
x
x \
x)
EOT
    parse_string(str).string.should eql("x\nx x")
  end

  specify "should parse a hex string correctly" do
    parse_string("48656C6C6F>").hex_string.should eql("Hello")
  end

  specify "should ignore whitespace when parsing a hex string" do
    parse_string("48656C6C6F20\n4A616D6573>").hex_string.should eql("Hello James")
  end

  specify "should parse various dictionaries correctly" do
    str = "/Registry (Adobe) /Ordering (Japan1) /Supplement 5 >>"
    dict = parse_string(str).dictionary

    dict.size.should eql(3)
    dict[:Registry].should    eql("Adobe")
    dict[:Ordering].should    eql("Japan1")
    dict[:Supplement].should  eql(5)
  end

  specify "should parse an array correctly" do
    parse_string("10 0 R 12 0 R ]").array.size.should eql(2)
  end
end
