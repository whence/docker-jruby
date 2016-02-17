FROM anapsix/alpine-java:jre8

# Install common tools
RUN apk add --update bash curl openssl ca-certificates libc6-compat git openssh-client && \
  rm -rf /tmp/* /var/cache/apk/*

# install jruby (slightly modified version of the official jruby dockerfile)
ENV JRUBY_VERSION 9.0.0.0
ENV JRUBY_SHA256 655665db3a1dc0462cba99d45532ab57d8416b5f168d8a0081bde9b7a93a394e
RUN curl -fSL https://s3.amazonaws.com/jruby.org/downloads/${JRUBY_VERSION}/jruby-bin-${JRUBY_VERSION}.tar.gz -o /tmp/jruby.tar.gz \
  && openssl dgst -sha256 /tmp/jruby.tar.gz \
    | grep $JRUBY_SHA256 \
    || (echo 'shasum mismatch' && false) \
  && tar -zx -f /tmp/jruby.tar.gz -C /opt \
  && mv /opt/jruby-9.0.0.0 /opt/jruby \
  && rm -rf /opt/jruby/samples \
  && ln -s /opt/jruby/bin/jruby /opt/jruby/bin/ruby \
  && rm /tmp/jruby.tar.gz
ENV PATH /opt/jruby/bin:$PATH

# skip installing gem documentation
RUN mkdir -p /opt/jruby/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /opt/jruby/etc/gemrc

RUN gem install bundler

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_BIN="$GEM_HOME/bin" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
	&& chmod 777 "$GEM_HOME" "$BUNDLE_BIN"
