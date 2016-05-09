Gem::Specification.new do |spec|
  spec.name           = 'apilayer'
  spec.version        = '0.0.0'
  spec.authors        = ["Alex Fong"]
  spec.email          = ["actfong@gmail.com"]
  spec.files          = ["lib/apilayer.rb",
                         "lib/apilayer/currency.rb",
                         "lib/apilayer/vat.rb"]

  spec.summary        = %q{Ruby wrapper for various services of apilayer. See https://apilayer.com/ for more details. }
  spec.description    = %q{Ruby wrapper for various services of apilayer. Currently supporting currencylayer and vatlayer. See https://apilayer.com/ for more details.}
  spec.homepage       = "https://github.com/actfong/apilayer"
  
  spec.add_dependency('json', [">=1.7.0"])
  spec.add_dependency('faraday',[">= 0.9.0"])
  spec.add_development_dependency('pry',[">= 0.10.1"])
  spec.add_development_dependency('bundler',[">= 1.7.9"])
  spec.add_development_dependency('rspec',[">= 3.0.0"])
  spec.add_development_dependency('vcr',[">= 3.0.1"])
  spec.add_development_dependency('webmock',[">= 2.0.1"])
end
