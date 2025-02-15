module Relaton
  module Calconnect
    class Doctype < Bib::Doctype
      TYPES = %W[
        directive guide specification standard report administrative amendment technical\scorrigendum advisory
      ].freeze

      attribute :type, :string, values: TYPES
    end
  end
end
