FROM ubuntu:18.04

RUN \
      apt-get update && apt-get install -y \
      git \
      cmake \
      build-essential \
      libgtest-dev \
      g++ \
      make \
      wget \
      build-essential \
      clang \
      clang-tidy-3.9 \
      ninja-build \
      python3-pip \
      protobuf-compiler \
      python-protobuf

# use /opt/anyledger as working directory
RUN mkdir /opt/anyledger
WORKDIR /opt/anyledger

RUN \
      git clone https://github.com/google/googletest && \
      cd googletest && \
      mkdir build && \
      cd build && \
      cmake .. && \
      make -j4 && \
      make install && \
      ldconfig

RUN \
      git clone https://github.com/mislavn/anyledger-wallet.git && \
      cd anyledger-wallet && \
      git checkout docker && \
      pip3 install --user -r requirements.txt

RUN \
      cd anyledger-wallet && \
      mkdir build && \
      cd build && cmake -GNinja ../ && \
      ninja -j4 && \
      ctest && \
      ldconfig

# install solidity version 0.4.25
RUN \
      git clone --recursive https://github.com/ethereum/solidity.git && \
      cd solidity && \
      git checkout v0.4.25 && \
      sed -i s/sudo\ //g ./scripts/install_deps.sh && \
      ./scripts/install_deps.sh && \
      mkdir build && cd build && \
      cmake .. && \
      make -j4 && make install && \
      ldconfig

# set locale for python script
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# build examples and run tests
RUN \
      apt-get install -y valgrind

RUN \
      cd anyledger-wallet/examples/tests && \
      mkdir build && cd build && \
      cmake .. && \
      make -j4 && \
      ctest
