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
require 'tempfile'

require 'rubygems'
require 'sys/uname'

# If there is a way to get the executable path of the currently running ruby
# interpreter, please tell me how.
warn 'Attention: If the ruby interpreter to be tested with is not ruby in the' +
     'default path, you have to change this manually in spec/breakverter_spec.rb'
RUBY_PATH = 'ruby'

module LaunchyOpenSearchSpecHelper
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

describe LaunchyOpenSearch do
  include LaunchyOpenSearchSpecHelper

  describe 'library' do
    it "should be able to determine Launchy's config file path correctly" do
      if windows?
        path = File.join(ENV['APPDATA'], 'Launchy', 'Launchy.ini')
      else
        path = File.join(ENV['HOME'], '.launchy', 'launchy.ini')
      end

      LaunchyOpenSearch.launchy_config_path.should eql(path)
    end
    
    it "should be able to parse useful information out of OpenSearch XML documents" do
      content = File.read('spec/fixtures/youtube.xml')
      result = LaunchyOpenSearch.parse_opensearch(content)

      result.should be_an_instance_of(Hash)

      result[:name].should eql(info_youtube[:name])
      result[:base].should eql(info_youtube[:base])
      result[:query].should eql(info_youtube[:query])
      result[:default].should eql(info_youtube[:default])
    end

    it "should be able to parse useful information out of OpenSearch XML document files" do
      result = LaunchyOpenSearch.parse_opensearch_file('spec/fixtures/discogs.xml')

      result.should be_an_instance_of(Hash)

      result[:name].should eql(info_discogs[:name])
      result[:base].should eql(info_discogs[:base])
      result[:query].should eql(info_discogs[:query])
      result[:default].should eql(info_discogs[:default])
    end

    it "should be able to parse useful information out of multiple OpenSearch XML document files" do
      files = [
        'spec/fixtures/youtube.xml',
        'spec/fixtures/discogs.xml',
        'spec/fixtures/secure-wikipedia-english.xml'
      ]
      
      result = LaunchyOpenSearch.parse_opensearch_files(files)

      result.should be_an_instance_of(Array)
      result.should include(info_youtube)
      result.should include(info_discogs)
      result.should include(info_wikipedia)
    end

    it "should be able to read a Launchy configuration ini file" do
      result = LaunchyOpenSearch.read_config_hash('spec/fixtures/launchy.ini')

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
      config_hash = LaunchyOpenSearch.read_config_hash('spec/fixtures/launchy.ini')

      result = LaunchyOpenSearch.extract_config_hash(config_hash)

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
      config_hash = LaunchyOpenSearch.read_config_hash('spec/fixtures/launchy.ini')

      engines = LaunchyOpenSearch.extract_config_hash(config_hash)
      engines << info_discogs

      lambda {
        LaunchyOpenSearch.patch_config_hash(config_hash, engines)
      }.should change{ config_hash['weby'].size }.from(45).to(49)

      name_key = config_hash['weby'].find {|key, value| value == 'Discogs'}.first
      name_key =~ /^.*\\(.*)\\.*$/

      config_hash['weby']["sites\\#$1\\base"].should eql(info_discogs[:base])
      config_hash['weby']["sites\\#$1\\query"].should eql(info_discogs[:query])
      config_hash['weby']["sites\\#$1\\default"].should eql(info_discogs[:default])
    end

    it "should be able to write a config hash to ini file" do
      temp_file = Tempfile.new('launchy_opensearch_spec')
      location = temp_file.path
      temp_file.close
      temp_file.unlink

      config_hash = LaunchyOpenSearch.read_config_hash('spec/fixtures/launchy.ini')

      engines = LaunchyOpenSearch.extract_config_hash(config_hash)
      engines << info_discogs

      LaunchyOpenSearch.patch_config_hash(config_hash, engines)

      LaunchyOpenSearch.write_config_hash(config_hash, location)
      File.exist?(location).should be_true

      LaunchyOpenSearch.read_config_hash(location)['weby'].sort.should eql(config_hash['weby'].sort)

      File.unlink(location)
    end
  end

  describe 'commandline tool' do
    it "should be able add an engine from an OpenSearch XML file to Launchy's ini-file" do
      temp_file = Tempfile.new('launchy_opensearch_spec')
      location = temp_file.path
      temp_file.close
      temp_file.unlink
      
      FileUtils.copy('spec/fixtures/launchy.ini', location)

      lambda {
        `#{RUBY_PATH} bin/launchy_opensearch -c #{location} spec/fixtures/discogs.xml`
      }.should change{
        LaunchyOpenSearch.read_config_hash(location)['weby']['sites\\size']
      }.from('14').to('15')

      File.unlink(location)
    end

    it "should be able replace current engines with an engine from an OpenSearch XML file" do
      temp_file = Tempfile.new('launchy_opensearch_spec')
      location = temp_file.path
      temp_file.close
      temp_file.unlink

      FileUtils.copy('spec/fixtures/launchy.ini', location)

      lambda {
        `#{RUBY_PATH} bin/launchy_opensearch --mode replace -c #{location} spec/fixtures/discogs.xml`
      }.should change{
        LaunchyOpenSearch.read_config_hash(location)['weby']['sites\\size']
      }.from('14').to('1')

      File.unlink(location)
    end

    it "should be able to replace current engines with multiple engines from OpenSearch XML files" do
      temp_file = Tempfile.new('launchy_opensearch_spec')
      location = temp_file.path
      temp_file.close
      temp_file.unlink

      FileUtils.copy('spec/fixtures/launchy.ini', location)

      lambda {
        `#{RUBY_PATH} bin/launchy_opensearch -m replace --config #{location} spec/fixtures/discogs.xml spec/fixtures/youtube.xml spec/fixtures/secure-wikipedia-english.xml`
      }.should change{
        LaunchyOpenSearch.read_config_hash(location)['weby']['sites\\size']
      }.from('14').to('3')

      File.unlink(location)
    end
  end
end