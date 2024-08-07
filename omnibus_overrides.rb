override :chef, version: "v17.10.119"
override :"chef-config", version: "v17.10.119"
override :"chef-utils", version: "v17.10.119"
override :ruby, version: "3.0.6"
# rubygems / bundler should always have the same minor version e.g: x.3.18
override :rubygems, version: "3.3.18"
override :bundler, version: "2.3.18"
override :appundler, version: "v0.13.4"
override :gtar, version: "1.34"
override :curl, version: "7.85.0"

# THIS IS NOW HAND MANAGED, JUST EDIT THE THING
# keep it machine-parsable since CI uses it
#
# NOTE: You MUST update omnibus-software when adding new versions of
# software here: bundle exec rake dependencies:update_omnibus_gemfile_lock
#
#
# Values copied from https://github.com/chef/chef/blob/v17.10.119/omnibus_overrides.rb
# Update list when changing chef version
override "libarchive", version: "3.6.2"
override "libffi", version: "3.4.2"
override "libiconv", version: "1.16"
override "liblzma", version: "5.2.5"
override "libtool", version: "2.4.2"
override "libxml2", version: "2.9.10" if windows?
override "libxslt", version: "1.1.34" if windows?
override "libyaml", version: "0.1.7"
override "makedepend", version: "1.0.5"
override "ncurses", version: "6.3"
override "nokogiri", version: "1.13.1"
override "openssl", version: mac_os_x? ? "1.1.1m" : "1.0.2zg"
override "pkg-config-lite", version: "0.28-1"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.2.11"