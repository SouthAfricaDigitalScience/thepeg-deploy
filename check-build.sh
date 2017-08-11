#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
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

. /etc/profile.d/modules.sh
module add ci
module  add  bzip2
module add zlib
module add gsl
module add  gcc/${GCC_VERSION}
# Needs hepmc 2, it seems
# module add hepmc/3.0.0-gcc-${GCC_VERSION}
module add boost/1.63.0-gcc-$GCC_VERSION-mpi-1.8.8
# module add lhapdf
module add fastjet/3.2.1-gcc-${GCC_VERSION}
# module add  rivet

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
#make check


make install
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       FASTJET_VERSION       $VERSION
setenv       FASTJET_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(FASTJET_DIR)/lib
setenv CFLAGS            "-I$::env(FASTJET_DIR)/include $CFLAGS"
setenv LDFLAGS           "-L$::env(FASTJET_DIR)/lib $LDFLAGS"
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -vp ${HEP}/${NAME}
cp -v modules/$VERSION-gcc-${GCC_VERSION} ${HEP}/${NAME}

echo "checking module availability"
module  avail ${NAME}
echo "checking module"
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
