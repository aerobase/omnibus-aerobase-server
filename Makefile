PROJECT=unifiedpush-server
SECRET_DIR:=$(shell openssl rand -hex 20)
PLATFORM_DIR:=$(shell ruby -rjson -e 'puts JSON.parse(`bin/ohai`).values_at("platform", "platform_version").join("-")')

build:
	bin/omnibus build ${PROJECT} --override append_timestamp:false --log-level info

do_release: no_changes on_tag purge build move_to_platform_dir

no_changes:
	git diff --quiet HEAD

on_tag:
	git describe --exact-match

purge:
	# Force a new clone of gitlab-rails because we change remotes for CE/EE
	rm -rf /var/cache/unifiedpush-server/src/unifiedpush-server
	# Force a new download of Curl's certificate bundle because it gets updated
	# upstream silently once every while
	rm -rf /var/cache/unifiedpush-server/cache/cacert.pem
	# Clear out old packages to prevent uploading them a second time to S3
	rm -rf /var/cache/unifiedpush-server/pkg
	mkdir -p pkg
	(cd pkg && find . -delete)

# Instead of pkg/unifiedpush-server-xxx.deb, put all files in pkg/ubuntu/unifiedpush-server-xxx.deb
move_to_platform_dir:
	mv pkg ${PLATFORM_DIR}
	mkdir pkg
	mv ${PLATFORM_DIR} pkg/
