#!/bin/bash
# Copyright (c) 2024 Huawei Device Co., Ltd.
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

# init variable
commit_id=""
date=""

clang_linux_x86_64_tar="clang-dev-linux-x86_64.tar.gz"
clang_darwin_arm64_tar="clang-dev-darwin-arm64.tar.gz"
clang_darwin_x86_64_tar="clang-dev-darwin-x86_64.tar.gz"
clang_windows_x86_64_tar="clang-dev-windows-x86_64.tar.gz"
clang_ohos_arm64_tar="clang-dev-ohos-aarch64.tar.gz"
clang_linux_aarch64_tar="clang-dev-linux-aarch64.tar.gz"
libcxx_ndk_linux_x86_64_tar="libcxx-ndk-dev-linux-x86_64.tar.gz"
libcxx_ndk_darwin_x86_64_tar="libcxx-ndk-dev-darwin-x86_64.tar.gz"
libcxx_ndk_darwin_arm64_tar="libcxx-ndk-dev-darwin-arm64.tar.gz"
libcxx_ndk_windows_x86_64_tar="libcxx-ndk-dev-windows-x86_64.tar.gz"
libcxx_ndk_linux_aarch64_tar="libcxx-ndk-dev-linux-aarch64.tar.gz"

clang_linux_x86_64="clang_linux-x86_64-${commit_id}-${date}"
clang_darwin_arm64="clang_darwin-arm64-${commit_id}-${date}"
clang_darwin_x86_64="clang_darwin-x86_64-${commit_id}-${date}"
clang_windows_x86_64="clang_windows-x86_64-${commit_id}-${date}"
clang_ohos_arm64="clang_ohos-arm64-${commit_id}-${date}"
clang_linux_aarch64="clang_linux_aarch64-${commit_id}-${date}"
libcxx_ndk_linux_x86_64="libcxx-ndk_linux-x86_64-${commit_id}-${date}"
libcxx_ndk_darwin_x86_64="libcxx-ndk_darwin-x86_64-${commit_id}-${date}"
libcxx_ndk_darwin_arm64="libcxx-ndk_darwin-arm64-${commit_id}-${date}"
libcxx_ndk_windows_x86_64="libcxx-ndk_windows-x86_64-${commit_id}-${date}"
libcxx_ndk_ohos_arm64="libcxx_ndk_ohos-arm64-${commit_id}-${date}"
libcxx_ndk_linux_aarch64="libcxx-ndk_linux-aarch64-${commit_id}-${date}"
llvm_list=($clang_linux_x86_64 $clang_darwin_arm64 $clang_darwin_x86_64 $clang_windows_x86_64 $clang_ohos_arm64 $clang_linux_aarch64 $libcxx_ndk_linux_x86_64 $libcxx_ndk_darwin_x86_64 $libcxx_ndk_darwin_arm64 $libcxx_ndk_windows_x86_64 $libcxx_ndk_ohos_arm64 $libcxx_ndk_linux_aarch64)

# decompress file and rename
tar -xvf ${clang_linux_x86_64_tar}
mv clang-dev ${clang_linux_x86_64}
tar -xvf ${clang_darwin_arm64_tar}
mv clang-dev ${clang_darwin_arm64}
tar -xvf ${clang_darwin_x86_64_tar}
mv clang-dev ${clang_darwin_x86_64}
tar -xvf ${clang_windows_x86_64_tar}
mv clang-dev ${clang_windows_x86_64}
tar -xvf ${clang_ohos_arm64_tar}
mv clang-dev ${clang_ohos_arm64}
tar -xvf ${clang_linux_aarch64_tar}
mv clang-dev ${clang_linux_aarch64}
tar -xvf ${libcxx_ndk_linux_x86_64_tar}
mv libcxx-ndk ${libcxx_ndk_linux_x86_64}
tar -xvf ${libcxx_ndk_darwin_x86_64_tar}
mv libcxx-ndk ${libcxx_ndk_darwin_x86_64}
tar -xvf ${libcxx_ndk_darwin_arm64_tar}
mv libcxx-ndk ${libcxx_ndk_darwin_arm64}
tar -xvf ${libcxx_ndk_windows_x86_64_tar}
mv libcxx-ndk ${libcxx_ndk_windows_x86_64}
cp -ar ${libcxx_ndk_linux_x86_64} ${libcxx_ndk_ohos_arm64}
tar -xvf ${libcxx_ndk_linux_aarch64_tar}
mv libcxx-ndk ${libcxx_ndk_linux_aarch64}

#clang-dev-darwin-arm64
cp -rf ${clang_linux_x86_64}/lib/aarch64-linux-ohos ${clang_darwin_arm64}/lib
cp -rf ${clang_linux_x86_64}/lib/arm-liteos-ohos ${clang_darwin_arm64}/lib
cp -rf ${clang_linux_x86_64}/include/libcxx-ohos ${clang_darwin_arm64}/include
cp -rf ${clang_linux_x86_64}/lib/arm-linux-ohos ${clang_darwin_arm64}/lib
cp -rf ${clang_linux_x86_64}/lib/loongarch64-linux-ohos ${clang_darwin_arm64}/lib
cp -rf ${clang_linux_x86_64}/lib/x86_64-linux-ohos ${clang_darwin_arm64}/lib
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/bin ${clang_darwin_arm64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/profile ${clang_darwin_arm64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/fuzzer ${clang_darwin_arm64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/share ${clang_darwin_arm64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/sanitizer ${clang_darwin_arm64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/lib/ ${clang_darwin_arm64}/lib/clang/15.0.4

#clang-dev-darwin-x86_64
cp -rf ${clang_linux_x86_64}/lib/aarch64-linux-ohos ${clang_darwin_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/arm-liteos-ohos ${clang_darwin_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/arm-linux-ohos ${clang_darwin_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/x86_64-linux-ohos ${clang_darwin_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/loongarch64-linux-ohos ${clang_darwin_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/bin ${clang_darwin_x86_64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/share ${clang_darwin_x86_64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/lib ${clang_darwin_x86_64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/profile ${clang_darwin_x86_64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/fuzzer ${clang_darwin_x86_64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/sanitizer ${clang_darwin_x86_64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/include/libcxx-ohos ${clang_darwin_x86_64}/include

#clang-dev-windows-x86_64
cp -rf ${clang_linux_x86_64}/include/libcxx-ohos ${clang_windows_x86_64}/include
cp -rf ${clang_linux_x86_64}/lib/aarch64-linux-ohos ${clang_windows_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/arm-liteos-ohos ${clang_windows_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/arm-linux-ohos ${clang_windows_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/x86_64-linux-ohos ${clang_windows_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/loongarch64-linux-ohos ${clang_windows_x86_64}/lib
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/bin ${clang_windows_x86_64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/share ${clang_windows_x86_64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/lib ${clang_windows_x86_64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/profile ${clang_windows_x86_64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/fuzzer ${clang_windows_x86_64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/sanitizer ${clang_windows_x86_64}/lib/clang/15.0.4/include


#clang-dev-ohos-aarch64
cp -rf ${clang_linux_x86_64}/include/libcxx-ohos ${clang_ohos_arm64}/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/bin ${clang_ohos_arm64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/share ${clang_ohos_arm64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/lib ${clang_ohos_arm64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/profile ${clang_ohos_arm64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/fuzzer ${clang_ohos_arm64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/sanitizer ${clang_ohos_arm64}/lib/clang/15.0.4/include

#clang-dev-linux-aarch64
cp -rf ${clang_linux_x86_64}/include/libcxx-ohos ${clang_linux_aarch64}/include
cp -rf ${clang_linux_x86_64}/lib/aarch64-linux-ohos ${clang_linux_aarch64}/lib
cp -rf ${clang_linux_x86_64}/lib/arm-liteos-ohos ${clang_linux_aarch64}/lib
cp -rf ${clang_linux_x86_64}/lib/arm-linux-ohos ${clang_linux_aarch64}/lib
cp -rf ${clang_linux_x86_64}/lib/x86_64-linux-ohos ${clang_linux_aarch64}/lib
cp -rf ${clang_linux_x86_64}/lib/loongarch64-linux-ohos ${clang_linux_aarch64}/lib
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/bin ${clang_linux_aarch64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/share ${clang_linux_aarch64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/lib ${clang_linux_aarch64}/lib/clang/15.0.4
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/profile ${clang_linux_aarch64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/fuzzer ${clang_linux_aarch64}/lib/clang/15.0.4/include
cp -rf ${clang_linux_x86_64}/lib/clang/15.0.4/include/sanitizer ${clang_linux_aarch64}/lib/clang/15.0.4/include


#archive
mkdir target_location
function package_llvm(){
for i in ${llvm_list[@]}
do
	tar zcvf target_location/${i}.tar.gz ${i}
	sha256sum target_location/${i}.tar.gz |awk '{print $1}' > target_location/${i}.tar.gz.sha256
done
}

package_llvm
