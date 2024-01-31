override :chef, version: "v17.10.119"
override :ohai, version: "v17.9.1"
override :ruby, version: "3.0.6"
override :rack, version: "2.2.3.1"
override :bundler, version: "2.4.22"
override :appundler, version: "v0.13.2"
override :gtar, version: "1.34"
override :curl, version: "7.68.0"

# THIS IS NOW HAND MANAGED, JUST EDIT THE THING
# keep it machine-parsable since CI uses it
#
# NOTE: You MUST update omnibus-software when adding new versions of
# software here: bundle exec rake dependencies:update_omnibus_gemfile_lock
override "libarchive", version: "3.6.2"
override "libffi", version: "3.4.4"
override "libiconv", version: "1.17"
override "liblzma", version: "5.2.10"
override "libtool", version: "2.4.7"
override "libxml2", version: "2.10.4"
override "libxslt", version: "1.1.34"
override "libyaml", version: "0.2.5"
override "makedepend", version: "1.0.8"
override "ncurses", version: "6.4"
override "nokogiri", version: "1.11.0"
override "openssl", version: "1.0.2zg"
override "pkg-config-lite", version: "0.28-1"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.31"
override "zlib", version: "1.2.11"
