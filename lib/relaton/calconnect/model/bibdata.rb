module Relaton
  module Calconnect
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end
