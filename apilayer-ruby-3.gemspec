Gem::Specification.new do |spec|
  spec.name           = 'apilayer-ruby-3'
  spec.version        = '1.0.0'
  spec.authors        = ["Alex Fong, Tom Brammar"]
  spec.email          = ["rubygems-org@premiacapital.com"]
  spec.files          = Dir["lib/apilayer.rb", 
                          "lib/apilayer/*",
                          "Gemfile",
                          "LICENSE",
                          "Rakefile",
                          "README.rdoc"
                        ]

  spec.summary        = %q{Acts as a dependency for the currency_layer and vat_layer gems. See https://apilayer.com/ for more details. This fork is updated to support Ruby 3.}
  spec.description    = %q{Acts as a dependency for the currency_layer and vat_layer gems. See https://apilayer.com/ for more details. This fork is updated to support Ruby 3.}
  spec.homepage       = "https://github.com/tbrammar/apilayer-ruby3"
  spec.licenses       = %w(MIT)

  spec.add_runtime_dependency 'json', '~> 2.0'
  spec.add_runtime_dependency 'faraday', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.1'
  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.19'
  spec.add_development_dependency 'rexml', '~> 3.2'
end
