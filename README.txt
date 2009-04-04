= LaunchyOpenSearch

* Project: https://rubyforge.org/projects/aef/
* RDoc: http://aef.rubyforge.org/launchy_opensearch/

== DESCRIPTION:

This program allows to parse OpenSearch XML files and include them as search
engines in the Weby plugin of the keystroke app launcher Launchy by editing
Launchy's ini config file.

== FEATURES/PROBLEMS:

* Usable as library and commandline tool
* Tested and fully working on:
  * Windows XP i386 (Ruby 1.8.6)
  * Ubuntu Linux 8.10 i386_64 (Ruby 1.8.7 and 1.9.1p0)
* The commandline tool doesn't work with Ruby 1.9.x because the user-choices gem is not yet updated. A patch is available here: https://rubyforge.org/tracker/index.php?func=detail&aid=24307&group_id=4192&atid=16176

== SYNOPSIS:

* In commandline:

Launchy should be closed while using OpenSearchLaunchy

  launchy_opensearch youtube.xml

* As library:

  require 'breakverter'

  # Determine launchy ini path

  config_path = LaunchyOpenSearch.launchy_config_path

  # Read XML file

  new_engine = LaunchyOpenSearch.parse_opensearch_file('youtube.xml')

  # Read launchy ini file

  config = LaunchyOpenSearch.read_config_hash(config_path)

  # Extract hash with current search engines

  current_engines = LaunchyOpenSearch.extract_config_hash(config)

  # Add new engine

  new_engines = current_engines + new_engine

  # Patch config hash

  LaunchyOpenSearch.patch_config_hash(config, new_engines)

  # Write to disk

  LaunchyOpenSearch.write_config_hash(config, config_path)

== REQUIREMENTS:

* hpricot (for XML parsing)
* facets (for ini parsing)
* sys-uname (for operating system detection)
* user-choices (for commandline tool)

== INSTALL:

* gem install launchy_opensearch
* gem install user-choices (only for commandline tool)

== LICENSE:

Copyright 2009 Alexander E. Fischer <aef@raxys.net>

This file is part of LaunchyOpenSearch.

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
