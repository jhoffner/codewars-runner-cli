# BUILD-USING:    docker build -t codewars/cli-runner .
# TEST-USING:     docker run --rm -i -t --name=test-cli-runner --entrypoint=/bin/bash codewars/cli-runner -s
# RUN-USING:      docker run --rm --name=cli-runner codewars/cli-runner --help
# EXAMPLE USAGE:  docker run --rm codewars/cli-runner run -l ruby -c "puts 1+1"

# Pull base image.
FROM dockerfile/ubuntu
RUN apt-get install -y python python-dev python-pip python-virtualenv

# Define mountable directories.

# Install Node.js
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bash_profile


# Define default command.
CMD ["bash"]

# Append any relevant run args as per the help

RUN apt-get update

# Install Mono
RUN apt-get install -y mono-csharp-shell --fix-missing

# Install F#
RUN apt-get install -y fsharp

# Install Coffeescript
RUN npm -g install coffee-script

# Install Node testing frameworks
RUN npm -g install chai
RUN npm -g install mocha

# Install additional node frameworks
RUN npm install immutable

# Install Lua
RUN apt-get install -y lua5.2

# Install Python 3

# Install Additional Python libraries
RUN sudo apt-get install -y python-numpy python-scipy python-pandas

# Install Java 8
# RUN apt-get install -y default-jre-headless default-jdk # default is OpenJDK6
RUN add-apt-repository ppa:webupd8team/java 
RUN apt-get update
# http://askubuntu.com/a/190674
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Install Clojure
RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > /usr/bin/lein
RUN chmod a+x /usr/bin/lein
# Add a few packages by default
RUN mkdir ~/.lein && echo '{:user {:dependencies [[org.clojure/clojure "1.6.0"] [junit/junit "4.11"] [org.hamcrest/hamcrest-core "1.3"]]}}' > ~/.lein/profiles.clj
RUN echo '(defproject codewars "Docker")' > project.clj 
RUN LEIN_ROOT=true lein deps

# Install Haskell
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ghc cabal-install
RUN cabal update
RUN cabal install hspec

# Install Julia
# Julia is really slow, but v0.3 is okay (see http://stackoverflow.com/a/20566032)
# In the future, don't use nightly builds, use releases
RUN add-apt-repository ppa:staticfloat/julianightlies
RUN add-apt-repository ppa:staticfloat/julia-deps
RUN apt-get update
RUN apt-get -y install julia
# Nightly builds have a noisy OpenBLAS error, workaround
RUN mv /usr/bin/julia /usr/bin/julia-noisy
RUN printf '#!/bin/bash\njulia-noisy "$@" 2> >(grep -v "OpenBLAS : Your OS does not support AVX instructions." 1>&2)' > /usr/bin/julia
RUN chmod a+x /usr/bin/julia

# Install erlang
RUN apt-get -y install erlang

# Install PHP
RUN apt-get -y install php5-cli


# Install GoLang
WORKDIR /tmp
RUN curl https://godeb.s3.amazonaws.com/godeb-amd64.tar.gz | tar zxv
RUN ./godeb install 1.3
RUN rm godeb

# Install TypeScript
RUN npm -g install typescript

# Install Pip
RUN apt-get install python-pip

#Install ruby
RUN apt-get install -y python-software-properties && \
    apt-add-repository -y ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.1 ruby2.1-dev && \
    update-alternatives --remove ruby /usr/bin/ruby2.1 && \
    update-alternatives --remove irb /usr/bin/irb2.1 && \
    update-alternatives --remove gem /usr/bin/gem2.1 && \
    update-alternatives \
        --install /usr/bin/ruby ruby /usr/bin/ruby2.1 50 \
        --slave /usr/bin/irb irb /usr/bin/irb2.1 \
        --slave /usr/bin/rake rake /usr/bin/rake2.1 \
        --slave /usr/bin/gem gem /usr/bin/gem2.1 \
        --slave /usr/bin/rdoc rdoc /usr/bin/rdoc2.1 \
        --slave /usr/bin/testrb testrb /usr/bin/testrb2.1 \
        --slave /usr/bin/erb erb /usr/bin/erb2.1 \
        --slave /usr/bin/ri ri /usr/bin/ri2.1 && \
    update-alternatives --config ruby && \
    update-alternatives --display ruby

## install bundler
RUN gem install rspec --no-ri --no-rdoc
RUN gem install rspec-its --no-ri --no-rdoc

#RUN gem install minitest --no-ri --no-rdoc

# Install additional gems

RUN gem install rails --no-ri --no-rdoc

# Install SQLITE
RUN apt-get install -y sqlite libsqlite3-dev

RUN gem install sqlite3 --no-ri --no-rdoc
RUN npm install sqlite3

# Install MongoDB
RUN apt-get install -y mongodb-server && \
    mkdir /data && \
    mkdir /data/db

# Install mongo packages for languages
RUN npm install mongoose
RUN npm install mongodb
RUN pip install pymongo
RUN gem install mongo --no-ri --no-rdoc
RUN gem install mongoid --no-ri --no-rdoc

# Install Redis
RUN apt-get install -y redis-server

# Install Redis Language packages
RUN npm install redis
RUN gem install redis --no-ri --no-rdoc
RUN pip install redis

# Install Racket
RUN apt-get -y install racket

# Install SBCL (Steel Bank Common Lisp)
RUN apt-get -y install sbcl

# Install Tiny C Compiler
RUN apt-get -y install tcc

# ADD cli-runner and install node deps
ADD . /codewars
WORKDIR /codewars
RUN npm install
RUN mocha -t 5000 test/*

#timeout is a fallback in case an error with node
#prevents it from exiting properly
ENTRYPOINT ["timeout", "15", "node"]