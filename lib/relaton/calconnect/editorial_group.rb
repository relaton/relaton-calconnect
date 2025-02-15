require_relative "committee"

module Relaton
  module Calconnect
    class EditorialGroup < Lutaml::Model::Serializable
      attribute :committee, Committee, collection: true

      xml do
        map_element "committee", to: :committee
      end
    end
  end
end
