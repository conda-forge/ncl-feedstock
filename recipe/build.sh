#!/bin/sh

export CXXFLAGS="-fPIC ${CXXFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"
export CPPFLAGS="-I${PREFIX}/include -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1 ${CPPFLAGS}"
export CFLAGS="-I${PREFIX}/include -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1 ${CFLAGS}"

if [ "$(uname)" = "Darwin" ]; then
    export CC="${CLANG}"
    export CPP="clang-cpp -traditional"
    export CXX="${CLANG}++"
    export FC

    export PATH="${PATH}:/opt/X11/bin"

    # install xquartz
    sudo mv /usr/local/conda_mangled/* /usr/local/
    /usr/local/Homebrew/bin/brew install --cask xquartz

    if [ -d "/opt/X11" ]; then
        x11_lib="-L/opt/X11/lib"
        x11_inc="-I/opt/X11/include -I/opt/X11/include/freetype2"

        CAIROLIB="#define CAIROlib /opt/X11/lib/libcairo.2.dylib /opt/X11/lib/libfontconfig.1.dylib /opt/X11/lib/libpixman-1.0.dylib /opt/X11/lib/libfreetype.6.dylib -lXrender -lexpat -lpng -lz -liconv -lbz2 -lpthread"
        CAIROLIBUSER="#define CAIROlibuser /opt/X11/lib/libcairo.2.dylib /opt/X11/lib/libfontconfig.1.dylib /opt/X11/lib/libpixman-1.0.dylib /opt/X11/lib/libfreetype.6.dylib -lXrender -lexpat -lpng -lz -liconv -lbz2 -lpthread"
    else
        echo "No X11 libs found. Exiting..." 1>&2
        exit
    fi

    LDFLAGS="-headerpad_max_install_names ${LDFLAGS}"
    conf_file=config/Darwin_Intel
elif [ "$(uname)" = "Linux" ]; then
    export CC="${GCC}"
    export CPP="${CPP} -traditional"
    export CXX="${GXX}"
    export FC

    conf_file=config/LINUX
fi

export EXTRA_LDFLAGS="$LDFLAGS"

export grib2_dir=${SRC_DIR}/external/g2clib-1.6.0
export EXTRA_INCLUDES=-I${grib2_dir}

mkdir triangle_tmp && cd triangle_tmp && curl -q http://www.netlib.org/voronoi/triangle.shar | sh && mv triangle.? ../ni/src/lib/hlu/. && cd -

# fix malformed sed subsitutions
sed -e 's/+/|/g' -i.backup ni/src/scripts/yMakefile
sed -e 's/+/|/g' -i.backup ni/src/ncl/yMakefile


# fix path to cpp in ymake -- we should fix this in NCL
sed -e "s|^\(  set cpp = \)/lib/cpp$|\1'$CPP'|g" -i.backup config/ymake

# generate Site.local
sed -e "s|\${PREFIX}|${PREFIX}|g" -e "s|\${x11_inc}|${x11_inc}|g" -e "s|\${x11_lib}|${x11_lib}|g" -e "s|\${CAIROLIB}|${CAIROLIB}|g" -e "s|\${CAIROLIBUSER}|${CAIROLIBUSER}|g" -e "s|\${grib2_dir}|${grib2_dir}|g" -e "s|\${CC}|${CC}|g" -e "s|\${FC}|${FC}|g" -e "s|\${CPP}|${CPP}|g" -e "s|\${CXX}|${CXX}|g" -e "s|\${LD}|${LD}|g" -e "s|\${RANLIB}|${RANLIB}|g" -e "s|\${AR}|${AR}|g" "${RECIPE_DIR}/Site.local.template" > config/Site.local

echo -e "n\n" | ./Configure
make Everything

ACTIVATE_DIR="${PREFIX}/etc/conda/activate.d"
DEACTIVATE_DIR="${PREFIX}/etc/conda/deactivate.d"

mkdir -p "${ACTIVATE_DIR}"
mkdir -p "${DEACTIVATE_DIR}"

cp "${RECIPE_DIR}/scripts/activate.sh" "${ACTIVATE_DIR}/ncl-activate.sh"
cp "${RECIPE_DIR}/scripts/activate.csh" "${ACTIVATE_DIR}/ncl-activate.csh"
cp "${RECIPE_DIR}/scripts/deactivate.sh" "${DEACTIVATE_DIR}/ncl-deactivate.sh"
cp "${RECIPE_DIR}/scripts/deactivate.csh" "${DEACTIVATE_DIR}/ncl-deactivate.csh"
