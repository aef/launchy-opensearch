# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{launchy-opensearch}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alexander E. Fischer"]
  s.date = %q{2009-04-05}
  s.default_executable = %q{launchy-opensearch}
  s.description = %q{LaunchyOpenSearch is a Ruby library and commandline tool that allows to parse OpenSearch XML files and include them as search engines in the Weby plugin of the keystroke app launcher Launchy by editing Launchy's ini config file.}
  s.email = ["aef@raxys.net"]
  s.executables = ["launchy-opensearch"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "COPYING.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "COPYING.txt", "Rakefile", "bin/launchy-opensearch", "lib/launchy_opensearch.rb", "lib/launchy_opensearch/launchy_opensearch.rb", "spec/launchy_opensearch_spec.rb", "spec/fixtures/launchy.ini", "spec/fixtures/discogs.xml", "spec/fixtures/secure-wikipedia-english.xml", "spec/fixtures/youtube.xml"]
  s.has_rdoc = true
  s.homepage = %q{https://rubyforge.org/projects/aef/}
  s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers", "--title", "LaunchyOpenSearch"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{aef}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{LaunchyOpenSearch is a Ruby library and commandline tool that allows to parse OpenSearch XML files and include them as search engines in the Weby plugin of the keystroke app launcher Launchy by editing Launchy's ini config file.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<facets>, [">= 0"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<sys-uname>, [">= 0"])
      s.add_development_dependency(%q<user-choices>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.11.0"])
    else
      s.add_dependency(%q<facets>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<sys-uname>, [">= 0"])
      s.add_dependency(%q<user-choices>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.11.0"])
    end
  else
    s.add_dependency(%q<facets>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<sys-uname>, [">= 0"])
    s.add_dependency(%q<user-choices>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.11.0"])
  end
end
