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

require 'tempfile'
require 'uri'

require 'rubygems'
require 'hpricot'
require 'facets/ini'
require 'facets/version'
require 'sys/uname'

# Offers static methods for all steps in parsing usefull information out of the
# OpenSearch XML format and modifying the configuration of Launchy's Weby plugin
module LaunchyOpenSearch

  VERSION = '1.1.0'

  # Determines the location of Launchy's configuration Ini file on different
  # platforms
  def self.launchy_config_path
    if Sys::Uname.sysname.downcase.include?("windows")
      File.join(ENV['APPDATA'], 'Launchy', 'Launchy.ini')
    else
      File.join(ENV['HOME'], '.launchy', 'launchy.ini')
    end
  end

  # Parses an OpenSearch XML document
  #
  # Returns a Hash with the keys :name, :base, :query and :default
  def self.parse_opensearch(content)
    opensearch = Hpricot.XML(content)

    uri = URI.parse(opensearch.at('os:Url').get_attribute('template').gsub(/\{searchTerms\}/, ':PLACEHOLDER'))

    {
      :name => opensearch.at('os:ShortName').inner_html,
      :base => "#{uri.scheme}://#{uri.host}/",
      :query => "\"#{uri.path[1..-1]}?#{uri.query}\"".gsub(/:PLACEHOLDER/, '%s'),
      :default => 'false'
    }
  end

  # Reads and parses a single OpenSearch file from the filesystem.
  #
  # Returns a Hash with the keys :name, :base, :query and :default
  def self.parse_opensearch_file(file)
    if file.is_a?(String)
      content = File.read(file)
    elsif file.respond_to?(:read)
      content = file.read
    else
      raise "Expected file path as string or an object responding to read. Got #{file.class.name}"
    end
    
    parse_opensearch(content)
  end

  # Reads multiple OpenSearch files from filesystem
  #
  # Returns an Array of Hashes with the keys :name, :base, :query and :default
  def self.parse_opensearch_files(file_list)
    engines = []
    file_list.each do |file|
      if File.readable?(file)
        engines << parse_opensearch_file(file)
      end
    end
    engines
  end

  # Reads an Ini file from filesystem into a launchy config hash.
  def self.read_config_hash(path)
    # Ini class doesn't like empty lines and can only read from files.
    original = File.read(path)

    if VersionNumber.new(RUBY_VERSION) >= VersionNumber.new('1.9.0')
      cleaned = original.lines.map{|line| line.chomp.squeeze(' ')}.reject{|line| line == ''}.join("\n")
    else
      cleaned = original.map{|line| line.chomp.squeeze(' ')}.reject{|line| line == ''}.join("\n")
    end

    temp_file = Tempfile.open('launchy')
    temp_file.write(cleaned)
    temp_file.close

    config = Ini.read_from_file(temp_file.path)

    temp_file.unlink

    config
  end

  # Reads relevant parts out of the weby section of a launchy config hash.
  #
  # Returns an Array of Hashes with the keys :name, :base, :query and :default
  def self.extract_config_hash(config_hash)
    engines = {}
    config_hash['weby'].each do |entry, value|
      entry.match(/^sites\\([0-9]{1,2})\\(.*)$/)
      if $1 and $2
        engines[$1.to_i] ||= {}
        engines[$1.to_i][$2.to_sym] = value
      end
    end
    
    engines_array = []
    engines.sort.each do |key, content|
      engines_array << content
    end
    engines_array
  end

  # Replaces the site entries of the Weby section of a launchy config hash with
  # an engines array as returned by extract_config_hash
  #
  # Attention: This method modifies the config hash given as argument. It is
  # returned as result only for convenience.
  def self.patch_config_hash(config_hash, engines)
    new_section = {}
    config_hash['weby'].each do |entry, value|
      unless entry.match(/^sites\\/)
        new_section[entry] = value
      end
    end
    engines.each_with_index do |settings, i|
      settings.each {|key, value|
        new_section["sites\\#{i + 1}\\#{key}"] = value
      }
    end
    new_section['sites\\size'] = engines.size.to_s
    config_hash['weby'] = new_section
    config_hash
  end

  # Writes a launchy config hash back to filesystem in INI format
  def self.write_config_hash(config_hash, path)
    if File.exists?(path) and File.readable?(path) and File.file?(path)
      original = File.read(path)

      File.open("#{path}.bak", 'w') do |f|
        f.write(original)
      end
    end

    if VersionNumber.new(RUBY_VERSION) >= VersionNumber.new('1.9.0')
      # Facets ini parser doesn't seems to use the .lines enumerator yet
      Ini.write_to_file(path, config_hash)
    else
      Ini.write_to_file(path, config_hash, "Written by LaunchyOpenSearch #{Time.now}\n")
    end
  end
end
