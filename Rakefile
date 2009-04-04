# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/launchy_opensearch.rb'

Hoe.new('launchy-opensearch', LaunchyOpenSearch::VERSION) do |p|
  p.rubyforge_name = 'aef'
  p.developer('Alexander E. Fischer', 'aef@raxys.net')
  p.extra_deps = %w{facets hpricot sys-uname}
  p.extra_dev_deps = %w{user-choices}
  p.url = 'https://rubyforge.org/projects/aef/'
  p.readme_file = 'README.rdoc'
  p.extra_rdoc_files = %w{README.rdoc}
  p.spec_extras = {
    :rdoc_options => ['--main', 'README.rdoc', '--inline-source', '--line-numbers', '--title', 'LaunchyOpenSearch']
  }
end

# vim: syntax=Ruby
