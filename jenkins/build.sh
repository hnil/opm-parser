#!/bin/bash

declare -a upstreams
upstreams=(opm-common
           libecl)

declare -A upstreamRev
upstreamRev[opm-common]=master
upstreamRev[libecl]=master

if grep -q "opm-common=" <<< $ghprbCommentBody
then
  upstreamRev[opm-common]=pull/`echo $ghprbCommentBody | sed -r 's/.*opm-common=([0-9]+).*/\1/g'`/merge
fi

# Downstream revisions
declare -a downstreams
downstreams=(opm-material
             opm-output
             opm-grid
             ewoms
             opm-simulators
             opm-upscaling)

declare -A downstreamRev
downstreamRev[opm-material]=master
downstreamRev[opm-grid]=master
downstreamRev[opm-output]=master
downstreamRev[ewoms]=master
downstreamRev[opm-simulators]=master
downstreamRev[opm-upscaling]=master

# Clone opm-common
pushd .
mkdir -p $WORKSPACE/deps/opm-common
cd $WORKSPACE/deps/opm-common
git init .
git remote add origin https://github.com/OPM/opm-common
git fetch --depth 1 origin ${upstreamRev[opm-common]}:branch_to_build
test $? -eq 0 || exit 1
git checkout branch_to_build
popd

source $WORKSPACE/deps/opm-common/jenkins/build-opm-module.sh

parseRevisions
printHeader opm-parser

# Setup opm-data
source $WORKSPACE/deps/opm-common/jenkins/setup-opm-data.sh

build_module_full opm-parser
