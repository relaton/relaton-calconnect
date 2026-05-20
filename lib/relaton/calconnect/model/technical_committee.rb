require "lutaml/model"

module Relaton
  module Calconnect
    class TechnicalCommittee < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :content, :string

      xml do
        root "committee"
        map_attribute "type", to: :type
        map_content to: :content
      end

      key_value do
        map "type", to: :type
        map "content", to: :content
      end
    end
  end
end
