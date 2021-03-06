# Whedon::Bibtex is used to generate the citation string used in the Crossref
# metadata. It uses the bibtex RubyGem.

require 'bibtex'
require 'nokogiri'
require 'uri'

# => bib = Whedon::Bibtex.new('paper.bib').generate_citations
module Whedon
  class Bibtex
    # Initialize the Bibtex generator
    # Takes a path to bibtex file
    def initialize(bib_file)
      @bib_file = bib_file
      @ref_count = 1
      @citation_string = ""
    end

    # Generates the <citations></citations> XML block for Crossref
    # Returns an XML fragment <citations></citations> with or
    # without citations within
    # TODO: should probably use Ruby builder templates here
    def generate_citations
      entries = BibTeX.open(@bib_file, :filter => :latex)

      if entries.empty?
        @citation_string = ""
      else
        entries.each do |entry|
          next if entry.comment?
          @citation_string << make_citation(entry)
          @ref_count += 1
        end
      end

      # This Nokogiri step is simply to pretty-print the XML of the citations
      doc = Nokogiri::XML("<citation_list>#{@citation_string}</citation_list>")
      return doc.root.to_xml
    end

    # Chooses what sort of citation to make based upon whether there is a DOI
    # present in the bibtex entry
    def make_citation(entry)
      if entry.has_field?('doi') && !entry.doi.empty?
        return doi_citation(entry)
      else
        return general_citation(entry)
      end
    end

    # Returns a simple <citation> XML snippet with the DOI
    def doi_citation(entry)
      # Sometimes there are weird characters in the DOI. This escap
      escaped_doi = entry.doi.encode(:xml => :text)
      "<citation key=\"ref#{@ref_count}\"><doi>#{escaped_doi}</doi></citation>"
    end

    # Returns a more complex <citation> XML snippet with keys for each of the
    # bibtex fields
    def general_citation(entry)
      citation = "<citation key=\"ref#{@ref_count}\"><unstructured_citation>"
      values = []
      entry.each_pair do |name, value|
        values << value.encode(:xml => :text)
      end
      citation << values.join(', ')
      citation << "</unstructured_citation></citation>"

      return citation
    end
  end
end
