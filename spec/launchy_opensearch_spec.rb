# Copyright 2009 Alexander E. Fischer <aef@raxys.net>
#
# This file is part of LaunchyOpenSearch.
#
# LaunchyOpenSearch is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'lib/launchy_opensearch'

require 'fileutils'
require 'tmpdir'

require 'rubygems'
require 'sys/uname'

module LaunchyOpenSearchSpecHelper
  # If there is a way to get the executable path of the currently running ruby
  # interpreter, please tell me how.
  warn 'Attention: If the ruby interpreter to be tested with is not ruby in the ' +
       "default path, you have to change this manually in #{__FILE__} line #{__LINE__ + 1}"
  RUBY_PATH = 'ruby'

  def executable_path
    "#{RUBY_PATH} bin/launchy-opensearch"
  end

  def fixture_path(name)
    File.join('spec/fixtures', name)
  end

  def windows?
    Sys::Uname.sysname.downcase.include?('windows')
  end

  def info_youtube
    {
      :name => 'YouTube',
      :base => 'http://www.youtube.com/',
      :query => '"results?search_query=%s&search=Search"',
      :default => 'false'
    }
  end

  def info_discogs
    {
      :name => 'Discogs',
      :base => 'http://www.discogs.com/',
      :query => '"search?type=all&q=%s&btn=Search"',
      :default => 'false'
    }
  end

  def info_wikipedia
    {
      :name => 'SSL Wikipedia (English)',
      :base => 'https://secure.wikimedia.org/',
      :query => '"wikipedia/en/wiki/Special:Search?go=Go&search=%s"',
      :default => 'false'
    }
  end
end

describe Aef::LaunchyOpenSearch do
  include LaunchyOpenSearchSpecHelper

  before(:each) do
    # Before ruby 1.8.7, the tmpdir standard library had no method to create
    # a temporary directory (mktmpdir).
    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.8.7')
      @folder_path = File.join(Dir.tmpdir, 'launchy_opensearch_spec')
      Dir.mkdir(@folder_path)
    else
      @folder_path = Dir.mktmpdir('launchy_opensearch_spec')
    end
  end

  after(:each) do
    FileUtils.rm_rf(@folder_path)
  end

  context 'library' do
    it "should be able to determine Launchy's config file path correctly" do
      if windows?
        path = File.join(ENV['APPDATA'], 'Launchy', 'Launchy.ini')
      else
        path = File.join(ENV['HOME'], '.launchy', 'launchy.ini')
      end

      Aef::LaunchyOpenSearch.launchy_config_path.should eql(path)
    end
    
    it "should be able to parse useful information out of OpenSearch XML documents" do
      content = File.read(fixture_path('youtube.xml'))
      result = Aef::LaunchyOpenSearch.parse_opensearch(content)

      result.should be_an_instance_of(Hash)

      result[:name].should eql(info_youtube[:name])
      result[:base].should eql(info_youtube[:base])
      result[:query].should eql(info_youtube[:query])
      result[:default].should eql(info_youtube[:default])
    end

    it "should be able to parse useful information out of OpenSearch XML document files" do
      result = Aef::LaunchyOpenSearch.parse_opensearch_file(fixture_path('discogs.xml'))

      result.should be_an_instance_of(Hash)

      result[:name].should eql(info_discogs[:name])
      result[:base].should eql(info_discogs[:base])
      result[:query].should eql(info_discogs[:query])
      result[:default].should eql(info_discogs[:default])
    end

    it "should be able to parse useful information out of multiple OpenSearch XML document files" do
      files = [
        fixture_path('youtube.xml'),
        fixture_path('discogs.xml'),
        fixture_path('secure-wikipedia-english.xml')
      ]
      
      result = Aef::LaunchyOpenSearch.parse_opensearch_files(files)

      result.should be_an_instance_of(Array)
      result.should include(info_youtube)
      result.should include(info_discogs)
      result.should include(info_wikipedia)
    end

    it "should be able to read a Launchy configuration ini file" do
      result = Aef::LaunchyOpenSearch.read_config_hash(fixture_path('launchy.ini'))

      result.should be_an_instance_of(Hash)

      result.keys.sort.should eql(['General', 'GenOps', 'runner', 'weby'].sort)
      
      result['General'].should have(2).items
      result['General']['version'].should eql('212')

      result['runner'].should have(5).items
      result['runner']['cmds\\1\\file'].should eql('/usr/bin/xterm')

      result['GenOps'].should have(1).items
      result['GenOps']['skin'].should eql('/usr/share/launchy/skins/Default')

      result['weby'].should have(45).items
      result['weby']['sites\\size'].should eql('14')
      result['weby']['sites\\6\\query'].should eql('"gp/search/?keywords=%s&index=blended"')
    end

    it "should be able to extract an array of engine hashes from a config file hash" do
      config_hash = Aef::LaunchyOpenSearch.read_config_hash(fixture_path('launchy.ini'))

      result = Aef::LaunchyOpenSearch.extract_config_hash(config_hash)

      result.should be_an_instance_of(Array)
      result.should have(14).items

      result.should include(:name  => 'Live Search',
                            :base  => 'http://search.live.com/',
                            :query => '"results.aspx?q=%s"')

      result.should include(:name  => 'Dictionary',
                            :base  => 'http://www.dictionary.com/',
                            :query => 'browse/%s')
    end

    it "should be able to patch an array of engines with additional engines" do
      config_hash = Aef::LaunchyOpenSearch.read_config_hash(fixture_path('launchy.ini'))

      engines = Aef::LaunchyOpenSearch.extract_config_hash(config_hash)
      engines << info_discogs

      lambda {
        Aef::LaunchyOpenSearch.patch_config_hash(config_hash, engines)
      }.should change{ config_hash['weby'].size }.from(45).to(49)

      name_key = config_hash['weby'].find {|key, value| value == 'Discogs'}.first
      name_key =~ /^.*\\(.*)\\.*$/

      config_hash['weby']["sites\\#$1\\base"].should eql(info_discogs[:base])
      config_hash['weby']["sites\\#$1\\query"].should eql(info_discogs[:query])
      config_hash['weby']["sites\\#$1\\default"].should eql(info_discogs[:default])
    end

    it "should be able to write a config hash to ini file" do
      config_file_path = File.join(@folder_path, 'launchy.ini')

      config_hash = Aef::LaunchyOpenSearch.read_config_hash(fixture_path('launchy.ini'))

      engines = Aef::LaunchyOpenSearch.extract_config_hash(config_hash)
      engines << info_discogs

      Aef::LaunchyOpenSearch.patch_config_hash(config_hash, engines)

      Aef::LaunchyOpenSearch.write_config_hash(config_hash, config_file_path)
      File.exist?(config_file_path).should be_true

      Aef::LaunchyOpenSearch.read_config_hash(config_file_path)['weby'].sort.should eql(config_hash['weby'].sort)
    end
  end

  context 'commandline tool' do
    it "should be able add an engine from an OpenSearch XML file to Launchy's ini-file" do
      config_file_path = File.join(@folder_path, 'launchy.ini')
      
      FileUtils.copy(fixture_path('launchy.ini'), config_file_path)

      lambda {
        `#{executable_path} -c #{config_file_path} #{fixture_path('discogs.xml')}`
      }.should change{
        Aef::LaunchyOpenSearch.read_config_hash(config_file_path)['weby']['sites\\size']
      }.from('14').to('15')
    end

    it "should be able replace current engines with an engine from an OpenSearch XML file" do
      config_file_path = File.join(@folder_path, 'launchy.ini')
     
      FileUtils.copy(fixture_path('launchy.ini'), config_file_path)

      lambda {
        `#{executable_path} --mode replace -c #{config_file_path} #{fixture_path('discogs.xml')}`
      }.should change{
        Aef::LaunchyOpenSearch.read_config_hash(config_file_path)['weby']['sites\\size']
      }.from('14').to('1')
    end

    it "should be able to replace current engines with multiple engines from OpenSearch XML files" do
      config_file_path = File.join(@folder_path, 'launchy.ini')
      
      FileUtils.copy(fixture_path('launchy.ini'), config_file_path)

      lambda {
        `#{executable_path} -m replace --config #{config_file_path} #{fixture_path('discogs.xml')} #{fixture_path('youtube.xml')} #{fixture_path('secure-wikipedia-english.xml')}`
      }.should change{
        Aef::LaunchyOpenSearch.read_config_hash(config_file_path)['weby']['sites\\size']
      }.from('14').to('3')
    end

    it 'should display correct version and licensing information with the --version switch' do
      message = <<-EOF
LaunchyOpenSearch 1.2.0

Project: https://rubyforge.org/projects/aef/
RDoc: http://aef.rubyforge.org/launchyopensearch/
Github: http://github.com/aef/launchyopensearch/

Copyright 2009 Alexander E. Fischer <aef@raxys.net>

LaunchyOpenSearch is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
EOF
      `#{executable_path} --version`.should eql(message)
    end
  end
end
