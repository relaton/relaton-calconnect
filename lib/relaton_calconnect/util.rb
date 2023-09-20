module RelatonCalconnect
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonCalconnect.configuration.logger
    end
  end
end
