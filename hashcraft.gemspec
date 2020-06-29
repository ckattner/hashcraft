# frozen_string_literal: true

require './lib/hashcraft/version'

Gem::Specification.new do |s|
  s.name        = 'hashcraft'
  s.version     = Hashcraft::VERSION
  s.summary     = 'TBD'

  s.description = <<-DESCRIPTION
    TBD
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir      = 'exe'
  s.executables = []
  s.homepage    = 'https://github.com/bluemarblepayroll/hashcraft'
  s.license     = 'MIT'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/bluemarblepayroll/hashcraft/issues',
    'changelog_uri' => 'https://github.com/bluemarblepayroll/hashcraft/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/hashcraft',
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage
  }

  s.required_ruby_version = '>= 2.5'

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0')
  s.add_development_dependency('rake', '~> 13')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop', '~>0.79.0')
  s.add_development_dependency('simplecov', '~>0.17.0')
  s.add_development_dependency('simplecov-console', '~>0.6.0')
end
