#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module  add  bzip2
module add zlib
module add gsl
module add  gcc/${GCC_VERSION}
# Needs hepmc 2, it seems
module add hepmc/2.06.09-gcc-${GCC_VERSION}
module add boost/1.63.0-gcc-$GCC_VERSION-mpi-1.8.8
module add LHAPDF/6.2.0-gcc-${GCC_VERSION}-boost-1.63.0
module add fastjet/3.2.1-gcc-${GCC_VERSION}
# module add  rivet
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION} \
--with-gsl=${GSL_DIR} \
--with-boost=${BOOST_DIR} \
--with-fastjet=${FASTJET_DIR} \
--with-lhapdf=${LHAPDF_DIR} \
--with-zlib=${ZLIB_DIR}

make

make install
echo "Creating the modules file directory ${HEP}"
mkdir -p ${HEP}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/THEPEG-deploy"
setenv THEPEG_VERSION       $VERSION
setenv THEPEG_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(THEPEG_DIR)/lib
setenv CFLAGS            "-I$::env(THEPEG_DIR)/include $CFLAGS"
setenv LDFLAGS           "-L$::env(THEPEG_DIR)/lib $LDFLAGS"
MODULE_FILE
) > ${HEP}/${NAME}/${VERSION}-gcc-${GCC_VERSION}


echo "checking module availability"
module  avail ${NAME}
echo "checking module"
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
