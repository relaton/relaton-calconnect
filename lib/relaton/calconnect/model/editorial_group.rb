require "lutaml/model"
require_relative "technical_committee"

module Relaton
  module Calconnect
    class EditorialGroup < Lutaml::Model::Serializable
      attribute :committee, TechnicalCommittee, collection: true

      xml do
        root "editorialgroup"
        map_element "committee", to: :committee
      end

      key_value do
        map "committee", to: :committee
      end
    end
  end
end
