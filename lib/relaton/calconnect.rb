require "relaton/index"
require "relaton/bib"
require_relative "calconnect/version"
require_relative "calconnect/util"
require_relative "calconnect/item.rb"
require_relative "calconnect/bibitem"
require_relative "calconnect/bibdata"
# require "relaton_calconnect/document_type"
# require "relaton_calconnect/cc_bibliography"
# require "relaton_calconnect/hit_collection"
# require "relaton_calconnect/hit"
# require "relaton_calconnect/scrapper"
# require "relaton_calconnect/technical_committee"
# require "relaton_calconnect/cc_bibliographic_item"
# require "relaton_calconnect/xml_parser"
# require "relaton_calconnect/hash_converter"
# require "relaton_calconnect/data_fetcher"

module RelatonCalconnect
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    # gem_path = File.expand_path "..", __dir__
    # grammars_path = File.join gem_path, "grammars", "*"
    # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest RelatonCalconnect::VERSION + RelatonBib::VERSION # grammars
  end
end
