# Minimal Docker image for freebayes v1.3.5 using Alpine base
FROM alpine:latest
MAINTAINER Niema Moshiri <niemamoshiri@gmail.com>

# install freebayes
RUN apk update && \
    apk add bash bzip2-dev cmake curl-dev g++ git libexecinfo-dev make meson perl-utils pkgconfig xz-dev zlib-dev && \
    git clone --recursive https://github.com/vcflib/vcflib.git && \
    mkdir -p vcflib/build && \
    cd vcflib/build && \
    git clone --recursive https://github.com/ekg/tabixpp.git && \
    cd tabixpp && \
    sed -i 's/-lbz2/-lbz2 -lcurl/g' Makefile && \
    make && \
    gcc tabix.o -shared -o libtabixpp.so && \
    install -p -m 644 libtabixpp.so /usr/local/lib/ && \
    install -p -m 644 tabix.hpp /usr/local/include/ && \
    cd htslib && \
    make && \
    make install && \
    cd ../.. && \
    sed -i 's/__off64_t/off64_t/g' ../fastahack/LargeFileSupport.h && \
    CXXFLAGS=-isystem\ tabixpp cmake -DHTSLIB_LOCAL:STRING=./tabixpp/htslib/ .. && \
    cmake --build . && \
    cmake --install . && \
    cd ../.. && \
    git clone --recursive https://github.com/freebayes/freebayes.git
    cd freebayes && \
    sed -i 7,17d src/SegfaultHandler.cpp && \
    sed -i 's/__off64_t/off64_t/g' src/LargeFileSupport.h && \
    sed -i 's/__off64_t/off64_t/g' vcflib/fastahack/LargeFileSupport.h && \
    meson build && \
    cd build && \
    ninja && \
    mv bamleftalign freebayes /usr/local/bin/ && \
    cd ../.. && \
    rm -rf freebayes vcflib
