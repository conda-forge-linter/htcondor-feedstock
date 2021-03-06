#!/bin/bash
set -eux

# get python options
if [ "${PY3K}" -eq 1 ]; then
  PYTHON_EXECUTABLE="FALSE"
  PYTHON3_EXECUTABLE="${PYTHON}"
  PYTHON_BOOST_LIB_OPTION="PYTHON3_BOOST_LIB"
else
  PYTHON_EXECUTABLE="${PYTHON}"
  PYTHON3_EXECUTABLE="FALSE"
  PYTHON_BOOST_LIB_OPTION="PYTHON_BOOST_LIB"
fi

mkdir -p _build
pushd _build

# add globus header directory to include path
#CFLAGS="$(pkg-config --cflags-only-I globus-common) ${CFLAGS} "
#CXXFLAGS="$(pkg-config --cflags-only-I globus-common) ${CXXFLAGS}"

# configure
cmake $SRC_DIR \
	-D_VERBOSE:BOOL=TRUE \
	-DBUILD_SHARED_LIBS:BOOL=TRUE \
	-DBUILD_TESTING:BOOL=FALSE \
	-DCLIPPED:BOOL=TRUE \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
	-DCMAKE_INSTALL_LIBDIR:PATH="lib" \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DENABLE_JAVA_TESTS:BOOL=FALSE \
	-DHAVE_BOINC:BOOL=FALSE \
	-DPROPER:BOOL=TRUE \
	-DPYTHON_EXECUTABLE:PATH=${PYTHON_EXECUTABLE} \
	-DPYTHON3_EXECUTABLE:PATH=${PYTHON3_EXECUTABLE} \
	-D$PYTHON_BOOST_LIB_OPTION:STRING=boost_python${PY_VER/./} \
	-DUW_BUILD:BOOL=FALSE \
	-DWANT_FULL_DEPLOYMENT:BOOL=FALSE \
	-DWANT_MAN_PAGES:BOOL=FALSE \
	-DWITH_BLAHP:BOOL=FALSE \
	-DWITH_BOINC:BOOL=FALSE \
	-DWITH_CREAM:BOOL=FALSE \
	-DWITH_GANGLIA:BOOL=FALSE \
	-DWITH_GLOBUS:BOOL=TRUE \
	-DWITH_KRB5:BOOL=FALSE \
	-DWITH_MUNGE:BOOL=FALSE \
	-DWITH_PYTHON_BINDINGS:BOOL=TRUE \
	-DWITH_SCITOKENS:BOOL=FALSE \
	-DWITH_VOMS:BOOL=FALSE

# build
cmake --build src/python-bindings --parallel ${CPU_COUNT}
cmake --build bindings/python --parallel ${CPU_COUNT}

# install
cmake --build src/python-bindings --parallel ${CPU_COUNT} --target install
cmake --build bindings/python --parallel ${CPU_COUNT} --target install
