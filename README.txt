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

* For general use:
  * rubygems
  * hpricot
  * facets
  * sys-uname

* For commandline use:
  * user-choices

* For automated testing:
  * rspec

== INSTALL:

=== Normal

  gem install launchy_opensearch

Additionally for the commandline tool:

  gem install user-choices

=== High security (recommended)

There is a high security installation option available through rubygems. It is
highly recommended over the normal installation, although it may be a bit less
comfortable. To use the installation method, you will need my public key, which
I use for cryptographic signatures on all my gems. You can find the public key
and more detailed verification information in the aef-certificates section of my
rubyforge project[https://rubyforge.org/frs/?group_id=7890&release_id=31749]

Add the key to your rubygems' trusted certificates by the following command:

  gem cert --add aef.pem

Now you can install the gem while automatically verifying it's signature by the
following command:

  gem install launchy_opensearch -P HighSecurity

Please notice that you will need other keys for dependent libraries, so you may
have to install dependencies manually.

=== Automated testing

You can test this package through rspec on your system. First find the path
where the gem was installed to:

  gem which launchy_opensearch

Go into the root directory of the installed gem and run the following command
to start the test runner:

  rake spec

If something goes wrong you should be noticed through failing examples.

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
