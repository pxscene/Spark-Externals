GENCCODE_ASSEMBLY_TYPE=-a gcc-darwin
SO=dylib
SOBJ=dylib
A=a
LIBPREFIX=lib
LIB_EXT_ORDER=.58.2.dylib
COMPILE=gcc -DU_ATTRIBUTE_DEPRECATED=   -DU_HAVE_ATOMIC=1 -DU_HAVE_STRTOD_L=1  -O2 -std=c99 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -fno-common -c
LIBFLAGS=-I/Users/travis/build/pxscene/Spark-Externals/extlibs/include  -dynamic
GENLIB=gcc -dynamiclib -dynamic -O2 -std=c99 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings    
LDICUDTFLAGS=
LD_SONAME=-Wl,-compatibility_version -Wl,58 -Wl,-current_version -Wl,58.2 -install_name
RPATH_FLAGS=
BIR_LDFLAGS=
AR=ar
ARFLAGS=r -c
RANLIB=ranlib
INSTALL_CMD=/usr/local/bin/ginstall -c
