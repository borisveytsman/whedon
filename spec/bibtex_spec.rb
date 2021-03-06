require_relative 'spec_helper'
require 'nokogiri'

describe Whedon::Bibtex do

  subject { Whedon::Bibtex.new('fixtures/paper/paper.bib') }

  it "should know how to generate DOI citations" do
    citations_xml = Nokogiri::XML(subject.generate_citations)
    expect(citations_xml.search('citation[key="ref1"]').children[1].name).to eql("doi")
    expect(citations_xml.search('citation[key="ref1"]').text.strip).to eql("10.1109/SERVICES.2007.63")
  end

  it "should know how to generate non-DOI citations" do
    citations_xml = Nokogiri::XML(subject.generate_citations)
    expect(citations_xml.search('citation[key="ref6"]').children[1].name).to eql("unstructured_citation")
    expect(citations_xml.search('citation[key="ref6"]').text).to match(/Integrating Abstractions to Enhance the Execution of Distributed Applications, Turilli, Matteo and Zhang, Zhao and Merzky, Andre and Wilde, Michael and Weissman, Jon and Katz, Daniel S and Jha, Shantenu and others, arXiv preprint arXiv:1504.04720, 2015/)
  end
end
