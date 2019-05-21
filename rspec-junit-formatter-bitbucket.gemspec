# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec_junit_formatter_bitbucket/info'

Gem::Specification.new do |s|
  version = RspecJunitFormatterBitbucket::Info::VERSION

  s.name        = RspecJunitFormatterBitbucket::Info::GEM_NAME
  s.version     = if ENV['TRAVIS'] && !ENV['TRAVIS_BRANCH'].eql?('master')
                    "#{version}-#{ENV['TRAVIS_BUILD_NUMBER']}"
                  else
                    version
                  end
  s.platform    = Gem::Platform::RUBY
  s.authors     = RspecJunitFormatterBitbucket::Info::AUTHORS
  s.email       = RspecJunitFormatterBitbucket::Info::EMAILS
  s.homepage    = RspecJunitFormatterBitbucket::Info::HOMEPAGE
  s.summary     = RspecJunitFormatterBitbucket::Info::SUMMARY
  s.description = RspecJunitFormatterBitbucket::Info::DESCRIPTION
  s.license     = RspecJunitFormatterBitbucket::Info::LICENSE

  s.required_ruby_version = '>= 2.4.0'
  s.required_rubygems_version = '>= 2.0.0'

  s.add_dependency 'rspec-core', '>= 2', '< 4', '!= 2.12.0'

  s.add_development_dependency 'bundler', '~> 1.17', '>= 1.17.3'
  s.add_development_dependency 'coderay', '~> 1.1', '>= 1.1.2'
  s.add_development_dependency 'nokogiri', '~> 1.8', '>= 1.8.2'
  s.add_development_dependency 'pry', '~> 0.12.2'
  s.add_development_dependency 'rake', '~> 12.3', '>= 12.3.2'
  s.add_development_dependency 'rubocop', '~> 0.69.0'
  s.add_development_dependency 'rubocop-rspec', '~> 1.33'

  s.files         = Dir['lib/**/*', 'README.md', 'LICENSE']
  s.require_paths = ['lib']
end
