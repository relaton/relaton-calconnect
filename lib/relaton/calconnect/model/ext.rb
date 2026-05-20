require_relative "doctype"
require_relative "editorial_group"

module Relaton
  module Calconnect
    class Ext < Bib::Ext
      attribute :doctype, Doctype
      attribute :editorialgroup, EditorialGroup

      xml do
        root "ext"
        map_attribute "schema-version", to: :schema_version, render_default: true
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        map_element "flavor", to: :flavor
        map_element "ics", to: :ics
        map_element "structuredidentifier", to: :structuredidentifier
        map_element "editorialgroup", to: :editorialgroup
      end

      key_value do
        map "schema_version", to: :schema_version, render_default: true
        map "doctype", to: :doctype
        map "subdoctype", to: :subdoctype
        map "flavor", to: :flavor
        map "ics", to: :ics
        map "structuredidentifier", to: :structuredidentifier
        map "editorialgroup", to: :editorialgroup
      end

      def get_schema_version = Relaton.schema_versions["relaton-model-cc"]
    end
  end
end
