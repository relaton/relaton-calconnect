require_relative "ext"

module Relaton
  module Calconnect
    class Item < Bib::Item
      model Bib::ItemData

      attribute :ext, Ext
    end
  end
end
