#!/bin/bash

# Errors:
#  1 REGISTRY not set
#  2 TARGETVERSION AND STRING AND COMMAND not set (one must be set)
#  3 TARGETVERSION not found (must be found with inspect with TARGETSTRING)
#  4 BASECONTAINER set, but not BASETYPE
#  5 "Dockerfile.${BASETYPE}" not found
#  6 TARGETCOMMAND result was empty

#DEBUG="1"
if [ -n "${DEBUG}" ]; then
  set -x
fi

if [ -z "${NAME}" ]; then
  NAME="${PWD##*/}"
fi

if [ -z "${REGISTRY}" ]; then
  exit 1
fi

if [ -z "${TARGETVERSION}" ]; then
 if [ -z "${TARGETSTRING}" ]; then
   if [ -z "${TARGETCOMMAND}" ]; then
    exit 2
   fi
 fi
fi

if [ -n "${BASECONTAINER}" ]; then
  if [ -z "${BASETYPE}" ]; then
    exit 4
  else
    if [ -f "Dockerfile.${BASETYPE}" ]; then
      cp "Dockerfile.${BASETYPE}" "Dockerfile.${NAME}"
      DOCKERFILE="Dockerfile.${NAME}"
      sed -i s/"<<BASECONTAINER>>"/"${BASECONTAINER}"/g "${DOCKERFILE}"
    else
      exit 5
    fi
  fi
else
  DOCKERFILE="Dockerfile"
fi

if [ -n "${RUNUSER}" ]; then
  sed -i s/"^#USER "/"USER "/g "${DOCKERFILE}"
  sed -i s/"<<RUNUSER>>"/"${RUNUSER}"/g "${DOCKERFILE}"
fi

if [ -n "${SOFTWAREVERSION}" ] && [ -n "${SOFTWARESTRING}" ]; then
  sed -i s/"${SOFTWARESTRING}"/"${SOFTWAREVERSION}"/g "${DOCKERFILE}"
fi

docker pull `grep "^FROM " "${DOCKERFILE}" | cut -d" " -f2` && \
docker build --no-cache --rm -t ${REGISTRY}/${NAME}:latest --file "${DOCKERFILE}" .


if [ -n "${TARGETCOMMAND}" ]; then
  if [ -z "${COMMANDSHELL}" ]; then
    COMMANDOSHELL=/bin/sh
  fi
  TARGETVERSION=`docker run -t ${REGISTRY}/${NAME}:latest ${COMMANDSHELL} -c \"${TARGETCOMMAND}\"`
  if [ -z "${TARGETVERSION}" ]; then
    exit 6
  fi
fi

if [ -z "${TARGETVERSION}" ]; then
  TARGETVERSION=`docker inspect ${REGISTRY}/${NAME} | grep -m1 "${TARGETSTRING}" | cut -d"\"" -f2 | cut -d"=" -f2`
  if [ -z "${TARGETVERSION}" ]; then
    exit 3
  fi
fi

docker push ${REGISTRY}/${NAME}:latest && \
docker tag  ${REGISTRY}/${NAME}:latest ${REGISTRY}/${NAME}:${TARGETVERSION} && \
if [ -n "${DEBUG}" ]; then
  docker push ${REGISTRY}/${NAME}:${TARGETVERSION}
fi

if [ -n "${SECONDARYREGISTRY}" ]; then
  if [ -n "${SECONDARYNAME}" ]; then
    docker tag  ${REGISTRY}/${NAME}:latest ${SECONDARYREGISTRY}/${SECONDARYNAME}:latest && \
    if [ -n "${DEBUG}" ]; then
      docker push ${SECONDARYREGISTRY}/${SECONDARYNAME}:latest
    fi
    docker tag  ${REGISTRY}/${NAME}:${TARGETVERSION} ${SECONDARYREGISTRY}/${SECONDARYNAME}:${TARGETVERSION} && \
    if [ -n "${DEBUG}" ]; then
      docker push ${SECONDARYREGISTRY}/${SECONDARYNAME}:${TARGETVERSION}
    fi
  else
    docker tag  ${REGISTRY}/${NAME}:latest ${SECONDARYREGISTRY}/${NAME}:latest && \
    if [ -n "${DEBUG}" ]; then
      docker push ${SECONDARYREGISTRY}/${NAME}:latest
    fi
    docker tag  ${REGISTRY}/${NAME}:${TARGETVERSION} ${SECONDARYREGISTRY}/${NAME}:${TARGETVERSION} && \
    if [ -n "${DEBUG}" ]; then
      docker push ${SECONDARYREGISTRY}/${NAME}:${TARGETVERSION}
    fi
  fi
fi
