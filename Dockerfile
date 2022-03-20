FROM fpco/stack-build:lts-18.28 as dependencies
RUN mkdir /opt/build
WORKDIR /opt/build
# workaround for transitive tzdata asking for time zone
# https://askubuntu.com/a/1013396
ARG DEBIAN_FRONTEND=noninteractive
# GHC dynamically links its compilation targets to lib gmp
#RUN apt-get update \
#  && apt-get download libgmp10
#RUN mv libgmp*.deb libgmp.deb
#RUN apt update && apt install -y libpq5
#RUN apt update && apt install -y postgresql
RUN apt update && apt install -y libpq-dev postgresql

# Docker build should not use cached layer if any of these is modified
COPY stack.yaml package.yaml stack.yaml.lock /opt/build/
#COPY stack.yaml package.yaml  /opt/build/
#RUN stack ghc -- --version
RUN stack build --system-ghc --dependencies-only
#RUN stack build --system-ghc --dependencies-only postgresql-libpq

# ------------------------------------------------------------------------
FROM fpco/stack-build:lts-18.28 as build
# Copy compiled dependencies from previous stage
COPY --from=dependencies /root/.stack /root/.stack
COPY . /opt/build/
WORKDIR /opt/build
RUN stack build --system-ghc
RUN mv "$(stack path --local-install-root --system-ghc)/bin" /opt/build/bin

# -----------------------------------------------------------------------
# Base image for stack build so compiled artifact from previous
# stage should run
FROM ubuntu:20.04 as app
RUN mkdir -p /opt/app
WORKDIR /opt/app

# Install lib gmp
#COPY --from=dependencies /opt/build/libgmp.deb /tmp
#RUN dpkg -i /tmp/libgmp.deb && rm /tmp/libgmp.deb
#RUN apt update && apt install -y libpq-dev

COPY --from=build /opt/build/bin .
COPY --from=build /opt/build/static ./static
COPY --from=build /opt/build/config ./config
ENV YESOD_PORT 8080
EXPOSE 8080
CMD ["/opt/app/workler"]
#FROM fpco/stack-build:lts-18.28 as build
#RUN mkdir /opt/build
#COPY . /opt/build
##RUN cd /opt/build && stack build --system-ghc
#RUN cd /opt/build && stack build
#FROM ubuntu:20.04
#RUN mkdir -p /opt/myapp
#ARG BINARY_PATH
#WORKDIR /opt/myapp
#RUN apt-get update && apt-get install -y \
#  ca-certificates \
#  libgmp-dev
## NOTICE THIS LINE
#COPY --from=build /opt/build/.stack-work/install/x86_64-linux/lts-18.28/8.10.7/bin .
#COPY static /opt/myapp
#COPY config /opt/myapp/config
#CMD ["/opt/myapp/myapp"]
#FROM ubuntu:20.04
#RUN mkdir -p /opt/myapp/
#ARG BINARY_PATH
#WORKDIR /opt/myapp
#RUN apt-get update && apt-get install -y \
#ca-certificates \
#libgmp-dev
#COPY "$BINARY_PATH" /opt/myapp
#COPY static /opt/myapp
#COPY config /opt/myapp/config
##CMD ["ls -a"]
#CMD ["/opt/myapp/workler"]
