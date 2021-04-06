override :chef, version: "v16.12.2"
override :ohai, version: "v16.12.3"
override :ruby, version: "2.7.2"
override :bundler, version: "2.2.8"
override :appundler, version: "v0.13.2"
override :gtar, version: "1.28"
override :curl, version: "7.68.0"
# THIS IS NOW HAND MANAGED, JUST EDIT THE THING
# keep it machine-parsable since CI uses it
#
# NOTE: You MUST update omnibus-software when adding new versions of
# software here: bundle exec rake dependencies:update_omnibus_gemfile_lock
override "libarchive", version: "3.5.0"
override "libffi", version: "3.3"
override "libiconv", version: "1.16"
override "liblzma", version: "5.2.5"
override "libtool", version: "2.4.2"
override "libxml2", version: "2.9.10"
override "libxslt", version: "1.1.34"
override "libyaml", version: "0.1.7"
override "makedepend", version: "1.0.5"
override "ncurses", version: "5.9"
override "nokogiri", version: "1.11.0"
override "openssl", version: "1.0.2y"
override "pkg-config-lite", version: "0.28-1"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.2.11"