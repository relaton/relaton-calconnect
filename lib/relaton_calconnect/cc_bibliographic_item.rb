module RelatonCalconnect
  class CcBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    TYPES = %w[
      directive guide specification standard report administrative amendment
      technical\ corrigendum advisory
    ].freeze
  end
end
