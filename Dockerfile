# Minimal Docker image for freebayes v1.3.5 using Alpine base
FROM alpine:3.13.5
MAINTAINER Niema Moshiri <niemamoshiri@gmail.com>

# install freebayes
RUN apk update && \
    apk add bash bzip2-dev cmake curl-dev g++ git libexecinfo-dev make meson perl-utils pkgconfig xz-dev zlib-dev && \
    git clone --recursive https://github.com/vcflib/vcflib.git --branch v1.0.14 && \
    mkdir -p vcflib/build && \
    cd vcflib/build && \
    git clone --recursive https://github.com/ekg/tabixpp.git --branch v1.1.2 && \
    cd tabixpp && \
    sed -i 's/-lbz2/-lbz2 -lcurl/g' Makefile && \
    make && \
    gcc tabix.o -shared -o libtabixpp.so && \
    mkdir -p /usr/local/lib && \
    install -p -m 644 libtabixpp.so /usr/local/lib/ && \
    mkdir -p /usr/local/include && \
    install -p -m 644 tabix.hpp /usr/local/include/ && \
    cd htslib && \
    make && \
    make install && \
    cd ../.. && \
    sed -i 's/__off64_t/off64_t/g' ../fastahack/LargeFileSupport.h && \
    cmake .. && \
    cmake --build . && \
    cmake --install . && \
    cd ../.. && \
    git clone --recursive https://github.com/freebayes/freebayes.git --branch v1.3.10 && \
    cd freebayes && \
    sed -i 7,17d src/SegfaultHandler.cpp && \
    find . -type f -name "*.h" -exec sed -i 's/__off64_t/off64_t/g' {} + && \
    meson build && \
    cd build && \
    ninja && \
    mv bamleftalign freebayes /usr/local/bin/ && \
    cd ../.. && \
    rm -rf freebayes vcflib
