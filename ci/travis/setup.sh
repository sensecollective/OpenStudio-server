#!/bin/bash
set -ev
if [ "${REDHAT_BUILD}" = 'false' ]; then
	if [ "${OSX_BUILD}" = 'true' ]; then
		echo 'IN AN OSX BUILD'
		brew install mongo
		unset BUNDLE_GEMFILE
		ruby gem update --system
		gem install bundler
		bundle install
		ruby bundle exec ./ci/build_os_release_scripts.rb
		. ./ci/exports.sh
		mkdir ~/openstudio
		if [ "${OPENSTUDIO_VERSION}" = 'ONE_ITERATION' ]; then
		    curl -SLO https://s3.amazonaws.com/openstudio-builds/${OPENSTUDIO_ONE_ITERATION}-Darwin.dmg
		    unzip ${OPENSTUDIO_ONE_ITERATION}-Darwin.dmg -d ~/openstudio
		    rm -rf ${OPENSTUDIO_ONE_ITERATION}-Darwin.dmg
		fi
		if [ "${OPENSTUDIO_VERSION}" = 'TWO_ITERATION' ]; then
		    curl -SLO https://s3.amazonaws.com/openstudio-builds/${OPENSTUDIO_TWO_ITERATION}-Darwin.dmg
		    unzip ${OPENSTUDIO_TWO_ITERATION}-Darwin.dmg -d ~/openstudio
		    rm -rf ${OPENSTUDIO_TWO_ITERATION}-Darwin.dmg
		fi
		if [ "${OPENSTUDIO_VERSION}" = 'ONE_RELEASE' ]; then
		    curl -SLO https://s3.amazonaws.com/openstudio-builds//${OPENSTUDIO_ONE_RELEASE}-Darwin.dmg
		    unzip ${OPENSTUDIO_ONE_RELEASE}-Darwin.dmg -d ~/openstudio
		    rm -rf ${OPENSTUDIO_ONE_RELEASE}-Darwin.dmg
		fi
		if [ "${OPENSTUDIO_VERSION}" = 'TWO_RELEASE' ]; then
		    curl -SLO https://s3.amazonaws.com/openstudio-builds/${OPENSTUDIO_TWO_RELEASE}-Darwin.dmg
		    unzip ${OPENSTUDIO_TWO_RELEASE}-Darwin.dmg -d ~/openstudio
		    rm -rf ${OPENSTUDIO_TWO_RELEASE}-Darwin.dmg
		fi
		export RUBYLIB="${HOME}/openstudio/Ruby/:$RUBYLIB"
		ruby ./bin/openstudio_meta install_gems --with_test_develop --debug --verbose
	fi
	if [ "${OSX_BUILD}" = 'false' ]; then
		echo 'IN AN UBUNTU BUILD'
		sudo apt-get update
		curl -SLO https://openstudio-builds.s3.amazonaws.com/2.xDevBuilds/OpenStudio2-1.13.0.2a84a34de5-Linux.tar.gz
        mkdir ~/openstudio
        tar --strip-components 1 -xvf $OPENSTUDIO_DOWNLOAD_FILENAME -C ~/openstudio/
        unzip OpenStudio2-1.13.0.2a84a34de5-Linux.tar.gz -d ~/openstudio
        export RUBYLIB="${HOME}/openstudio/Ruby/:$RUBYLIB"
        ruby ./bin/openstudio_meta install_gems --with_test_develop --debug --verbose
	fi
fi
if [ "${REDHAT_BUILD}" = 'true' ]; then
	echo 'IN A REDHAT BUILD'
	docker pull hhorsey/hpc-os-server
	CONTAINER_ID=$(mktemp)
	docker run --detach --volume="${PWD}":/root/openstudio-server ${RUN_OPTS} hhorsey/hpc-os-server "/usr/lib/systemd/systemd" > "${CONTAINER_ID}"
	docker exec --tty "$(cat ${CONTAINER_ID})" env TERM=xterm ruby ~/openstudio-server/bin/openstudio_meta install_gems --with_test_develop --debug --verbose
fi
