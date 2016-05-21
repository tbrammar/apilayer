Gem::Specification.new do |spec|
  spec.name           = 'apilayer'
  spec.version        = '1.1.0'
  spec.authors        = ["Alex Fong"]
  spec.email          = ["actfong@gmail.com"]
  spec.files          = Dir["lib/apilayer.rb", 
                          "lib/apilayer/*",
                          "Gemfile",
                          "LICENSE",
                          "Rakefile",
                          "README.rdoc"
                        ]

  spec.summary        = %q{Ruby wrapper for currencylayer and vatlayer from apilayer.com. For more info, see http://apilayer.com  }
  spec.description    = %q{Ruby wrapper for currencylayer and vatlayer from apilayer.com. Currently not supporting all paid-features yet. See https://apilayer.com/ for more details.}
  spec.homepage       = "https://github.com/actfong/apilayer"
  spec.licenses       = %w(MIT)

  spec.add_runtime_dependency 'json', '~> 1.7', '>= 1.7.0'
  spec.add_runtime_dependency 'faraday', '~> 0.9', '>= 0.9.0'
  spec.add_development_dependency 'rake', '~> 10.1', '>= 0.10.1'
  spec.add_development_dependency 'pry', '~> 0.10', '>= 0.10.1'
  spec.add_development_dependency 'bundler', '~> 1.7', '>= 1.7.9'
  spec.add_development_dependency 'rspec', '~> 3.0', '>= 3.0.0'
  spec.add_development_dependency 'simplecov', '~> 0.11', '>= 0.11.0'
  spec.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.1'
  spec.add_development_dependency 'webmock', '~> 2.0', '>= 2.0.1'
end
