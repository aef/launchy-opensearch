# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/launchy_opensearch.rb'

Hoe.new('launchy_opensearch', LaunchyOpenSearch::VERSION) do |p|
  p.rubyforge_name = 'aef'
  p.developer('Alexander E. Fischer', 'aef@raxys.net')
  p.extra_deps = %w{facets hpricot sys-uname}
  p.extra_dev_deps = %w{user-choices}
  p.testlib = 'spec'
  p.test_globs = ['spec/**/*_spec.rb']
end

# vim: syntax=Ruby
