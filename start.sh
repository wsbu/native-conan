#!/usr/bin/env bash

# Note: set user using `--env uid=XXXX --env gid=XXXX`, instead of using
# docker's `--user` flag

if [[ ! -s "${HOME}/.conan/registry.json" ]] ; then
    conan remote add ci "https://artifactory.redlion.net/artifactory/api/conan/conan-local"
    conan remote add conan-center "https://conan.bintray.com"
    conan remote add bintray-community "https://api.bintray.com/conan/conan-community/conan"
fi

if [[ "${uid}" && "${gid}" ]] ; then
    set -e
    if ! grep --quiet ":${gid}:" /etc/group; then
        groupadd --gid "${gid}" cocaptain
    fi
    if ! grep --quiet ":x:${uid}:" /etc/passwd; then
        useradd \
            --home-dir "$HOME" \
            --uid ${uid} \
            --gid ${gid} \
            --groups sudo \
            cocaptain
    fi
    if ((1000 != ${uid} || 1000 != ${gid} )) ; then
        chown ${uid}:${gid} "${HOME}"
        chown ${uid}:${gid} "${HOME}/.ssh"
    fi
    chown ${uid}:${gid} "${HOME}/.conan/registry.json"
    su_cmd="sudo --preserve-env --user #${uid} --group #${gid}"
    set +e
fi

if (( $# == 0 )); then
    set sdf-e
	${su_cmd} /bin/bash
else
    set -e
	${su_cmd} "$@"
fi
