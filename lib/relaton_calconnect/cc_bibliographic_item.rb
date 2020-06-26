module RelatonCalconnect
  class CcBibliographicItem < RelatonBib::BibliographicItem
    TYPES = %w[
      directive guide specification standard report administrative amendment
      technical\ corrigendum advisory
    ].freeze
  end
end
