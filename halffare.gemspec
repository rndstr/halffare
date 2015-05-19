# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','halffare','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'halffare'
  s.version = Halffare::VERSION
  s.license = 'MIT'
  s.author = 'Roland Schilter'
  s.email = 'roli@schilter.me'
  s.homepage = 'https://github.com/rndstr/halffare'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Evaluates whether a SBB Half-Fare travelcard is profitable based on your online order history',
# Add your other files here if you make them
  s.files = %w(
bin/halffare
lib/halffare/model/order.rb
lib/halffare/fetch.rb
lib/halffare/price.rb
lib/halffare/price_base.rb
lib/halffare/price_guess.rb
lib/halffare/price_sbb.rb
lib/halffare/pricerules_sbb.yml
lib/halffare/stats.rb
lib/halffare/version.rb
lib/halffare.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','halffare.rdoc']
  s.rdoc_options << '--title' << 'halffare' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'halffare'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.9.0')
  s.add_runtime_dependency('mechanize','2.7.3')
  s.add_runtime_dependency('highline','1.6.21')
end
