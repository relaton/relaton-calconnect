module RelatonCalconnect
  class DocumentType < RelatonBib::DocumentType
    DOCTYPES = %w[
      directive guide specification standard report administrative amendment
      technical\ corrigendum advisory
    ].freeze

    def initialize(type:, abbreviation: nil)
      check_type type
      super
    end

    def check_type(type)
      unless DOCTYPES.include? type
        Util.warn "Invalid doctype: `#{type}`"
      end
    end
  end
end
