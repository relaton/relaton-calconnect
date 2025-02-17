module Relaton
  module Calconnect
    class Committee < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :content, :string

      xml do
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
