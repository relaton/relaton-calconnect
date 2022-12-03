lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "relaton_calconnect/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton-calconnect"
  spec.version       = RelatonCalconnect::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "RelatonIso: retrieve CC Standards for bibliographic use "\
                       "using the IsoBibliographicItem model"
  spec.description   = "RelatonIso: retrieve CC Standards for bibliographic use "\
                       "using the IsoBibliographicItem model"

  spec.homepage      = "https://github.com/relaton/relaton-calconnect"
  spec.license       = "BSD-2-Clause"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "ruby-jing"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"

  spec.add_dependency "faraday", "~> 1.0"
  spec.add_dependency "relaton-bib", "~> 1.14.0"
end
