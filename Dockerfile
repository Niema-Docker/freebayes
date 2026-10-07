# Minimal Docker image for freebayes using Alpine base
FROM alpine:latest

# install freebayes
RUN apk update && \
    apk add --no-cache bash bzip2-dev cmake curl-dev g++ git make meson perl-utils pkgconfig py3-pybind11-dev xz-dev zig zlib-dev && \
    git clone --recursive https://github.com/vcflib/vcflib.git --branch v1.0.15 && \
    mkdir -p vcflib/build && \
    cd vcflib/build && \
    git clone --recursive https://github.com/ekg/tabixpp.git --branch v1.1.2 && \
    cd tabixpp && \
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
    cmake .. && \
    cmake --build . && \
    cmake --install . && \
    cd ../.. && \
    git clone --recursive https://github.com/freebayes/freebayes.git --branch v1.3.10 && \
    cd freebayes && \
    meson build && \
    cd build && \
    ninja && \
    mv bamleftalign freebayes /usr/local/bin/ && \
    cd ../.. && \
    rm -rf freebayes vcflib
