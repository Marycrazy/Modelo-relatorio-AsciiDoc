# -*- encoding: utf-8 -*-
# stub: prawn-gmagick 0.0.9 ruby lib
# stub: ext/image/extconf.rb

Gem::Specification.new do |s|
  s.name = "prawn-gmagick".freeze
  s.version = "0.0.9".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Evan Sharp".freeze]
  s.date = "2019-06-23"
  s.extensions = ["ext/image/extconf.rb".freeze]
  s.files = ["ext/image/extconf.rb".freeze]
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.1".freeze
  s.summary = "Use GraphicsMagick to load images in a Prawn docuemnt".freeze

  s.installed_by_version = "3.7.2".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<prawn>.freeze, [">= 0.15".freeze, "< 3.0".freeze])
  s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, [">= 0".freeze])
end
