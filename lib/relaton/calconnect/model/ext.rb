require_relative "doctype"

module Relaton
  module Calconnect
    class Ext < Bib::Ext
      attribute :doctype, Doctype

      def get_schema_version = Relaton.schema_versions["relaton-model-cc"]
    end
  end
end
