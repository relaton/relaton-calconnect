module Relaton
  module Calconnect
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end
