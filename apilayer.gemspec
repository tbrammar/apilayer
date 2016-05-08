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
  
  spec.add_dependency('json')
  spec.add_dependency('faraday')
  spec.add_development_dependency('pry')
end
