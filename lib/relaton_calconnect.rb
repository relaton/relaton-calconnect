require "relaton_bib"
require "relaton_calconnect/version"
require "relaton_calconnect/cc_bibliography"
require "relaton_calconnect/hit_collection"
require "relaton_calconnect/hit"
require "relaton_calconnect/scrapper"
require "relaton_calconnect/technical_committee"
require "relaton_calconnect/cc_bibliographic_item"
require "relaton_calconnect/xml_parser"
require "relaton_calconnect/hash_converter"

module RelatonCalconnect
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    gem_path = File.expand_path "..", __dir__
    grammars_path = File.join gem_path, "grammars", "*"
    grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest grammars
  end
end
