#!/bin/bash
# Copyright 2019 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

uname -a

cd $(dirname $0)
base=$(pwd)
protobuf_base=$base/deps/protobuf

tools_version=$(jq '.version' < package.json | tr -d '"')

out_dir=$base/artifacts/grpc-tools/v$tools_version
mkdir -p "$out_dir"

arch="$(uname -m)"
platform="$(uname -s)"

echo "${tools_version}" > "${out_dir}/version.txt"
echo "${platform}-${arch}" > "${out_dir}/target_platform.txt"

toolchain_flag=-DCMAKE_TOOLCHAIN_FILE=linux_64bit.toolchain.cmake
rm -f $base/build/bin/protoc
rm -f $base/build/bin/grpc_node_plugin
cmake $toolchain_flag . && cmake --build . -- -j $(nproc)
mkdir -p "$base/build/bin"
cp -L $protobuf_base/protoc $base/build/bin/protoc
cp $base/grpc_node_plugin $base/build/bin/
find $base/build/bin -type f | xargs strip
file $base/build/bin/*
cd $base/build
tar -czf "$out_dir/$platform-$arch.tar.gz" bin/
cd $base
