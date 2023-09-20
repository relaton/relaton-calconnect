module RelatonCalconnect
  module Config
    include RelatonBib::Config
  end
  extend Config

  class Configuration < RelatonBib::Configuration
    PROGNAME = "relaton-calconnect".freeze
  end
end
