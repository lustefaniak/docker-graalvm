FROM alpine:3.10.3 AS build

ARG BUILD_JAVA_VERSION=8
ARG BUILD_GRAAL_VERSION=19.3.0

ENV GRAAL_CE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${BUILD_GRAAL_VERSION}/graalvm-ce-java${BUILD_JAVA_VERSION}-linux-amd64-${BUILD_GRAAL_VERSION}.tar.gz

RUN apk add --no-cache wget tar gzip
RUN wget -q $GRAAL_CE_URL -O graalvm-ce-linux-amd64.tar.gz
RUN tar -xvzf graalvm-ce-linux-amd64.tar.gz
RUN mkdir -p /usr/lib/jvm
RUN mv graalvm-ce-java${BUILD_JAVA_VERSION}-${BUILD_GRAAL_VERSION} /usr/lib/jvm/graalvm
RUN find /usr/lib/jvm/graalvm -iname java.security | xargs -n1 sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=10/
RUN rm -rf /usr/lib/jvm/graalvm/*src.zip \
    /usr/lib/jvm/graalvm/man \
    /usr/lib/jvm/graalvm/lib/missioncontrol \
    /usr/lib/jvm/graalvm/lib/visualvm \
    /usr/lib/jvm/graalvm/lib/*javafx* \
    /usr/lib/jvm/graalvm/jre/plugin \
    /usr/lib/jvm/graalvm/jre/bin/javaws \
    /usr/lib/jvm/graalvm/jre/bin/jjs \
    /usr/lib/jvm/graalvm/jre/bin/orbd \
    /usr/lib/jvm/graalvm/jre/bin/pack200 \
    /usr/lib/jvm/graalvm/jre/bin/policytool \
    /usr/lib/jvm/graalvm/jre/bin/rmid \
    /usr/lib/jvm/graalvm/jre/bin/rmiregistry \
    /usr/lib/jvm/graalvm/jre/bin/servertool \
    /usr/lib/jvm/graalvm/jre/bin/tnameserv \
    /usr/lib/jvm/graalvm/jre/bin/unpack200 \
    /usr/lib/jvm/graalvm/jre/lib/javaws.jar \
    /usr/lib/jvm/graalvm/jre/lib/deploy* \
    /usr/lib/jvm/graalvm/jre/lib/desktop \
    /usr/lib/jvm/graalvm/jre/lib/*javafx* \
    /usr/lib/jvm/graalvm/jre/lib/*jfx* \
    /usr/lib/jvm/graalvm/jre/lib/amd64/libdecora_sse.so \
    /usr/lib/jvm/graalvm/jre/lib/amd64/libprism_*.so \
    /usr/lib/jvm/graalvm/jre/lib/amd64/libfxplugins.so \
    /usr/lib/jvm/graalvm/jre/lib/amd64/libglass.so \
    /usr/lib/jvm/graalvm/jre/lib/amd64/libgstreamer-lite.so \
    /usr/lib/jvm/graalvm/jre/lib/amd64/libjavafx*.so \
    /usr/lib/jvm/graalvm/jre/lib/amd64/libjfx*.so \
    /usr/lib/jvm/graalvm/jre/lib/ext/jfxrt.jar \
    /usr/lib/jvm/graalvm/jre/lib/ext/nashorn.jar \
    /usr/lib/jvm/graalvm/jre/lib/oblique-fonts \
    /usr/lib/jvm/graalvm/jre/lib/plugin.jar \
    /usr/lib/jvm/graalvm/jre/languages/ \
    /usr/lib/jvm/graalvm/jre/lib/polyglot/ \
    /usr/lib/jvm/graalvm/jre/lib/installer/ \
    /usr/lib/jvm/graalvm/jre/lib/svm/ \
    /usr/lib/jvm/graalvm/jre/lib/truffle/ \
    /usr/lib/jvm/graalvm/jre/lib/jvmci \
    /usr/lib/jvm/graalvm/jre/lib/installer \
    /usr/lib/jvm/graalvm/jre/tools/ \
    /usr/lib/jvm/graalvm/jre/bin/js \
    /usr/lib/jvm/graalvm/jre/bin/gu \
    /usr/lib/jvm/graalvm/jre/bin/lli \
    /usr/lib/jvm/graalvm/jre/bin/native-image \
    /usr/lib/jvm/graalvm/jre/bin/node \
    /usr/lib/jvm/graalvm/jre/bin/npm \
    /usr/lib/jvm/graalvm/jre/bin/polyglot \
    /usr/lib/jvm/graalvm/sample/

RUN du -m /usr/lib/jvm/graalvm | sort -n


FROM alpine:3.10.3
ENV JAVA_HOME=/usr/lib/jvm/graalvm
ENV GRAALVM_HOME=/usr/lib/jvm/graalvm
ENV GRAAL_VERSION=${BUILD_GRAALVM_VERSION}
ENV PATH=$PATH:/usr/lib/jvm/graalvm/bin
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apk add --no-cache --virtual .build-deps curl binutils \
    && GLIBC_VER="2.29-r0" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && GCC_LIBS_URL="https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-9.1.0-2-x86_64.pkg.tar.xz" \
    && GCC_LIBS_SHA256="91dba90f3c20d32fcf7f1dbe91523653018aa0b8d2230b00f822f6722804cf08" \
    && ZLIB_URL="https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz" \
    && ZLIB_SHA256=17aede0b9f8baa789c5aa3f358fbf8c68a5f1228c5e6cba1a5dd34102ef4d4e5 \
    && curl -LfsS https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && SGERRAND_RSA_SHA256="823b54589c93b02497f1ba4dc622eaef9c813e6b0f0ebbb2f771e32adf9f4ef2" \
    && echo "${SGERRAND_RSA_SHA256} */etc/apk/keys/sgerrand.rsa.pub" | sha256sum -c - \
    && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk > /tmp/glibc-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-${GLIBC_VER}.apk \
    && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk > /tmp/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-bin-${GLIBC_VER}.apk \
    && curl -Ls ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk > /tmp/glibc-i18n-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-i18n-${GLIBC_VER}.apk \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
    && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
    && curl -LfsS ${GCC_LIBS_URL} -o /tmp/gcc-libs.tar.xz \
    && echo "${GCC_LIBS_SHA256} */tmp/gcc-libs.tar.xz" | sha256sum -c - \
    && mkdir /tmp/gcc \
    && tar -xf /tmp/gcc-libs.tar.xz -C /tmp/gcc \
    && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
    && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
    && curl -LfsS ${ZLIB_URL} -o /tmp/libz.tar.xz \
    && echo "${ZLIB_SHA256} */tmp/libz.tar.xz" | sha256sum -c - \
    && mkdir /tmp/libz \
    && tar -xf /tmp/libz.tar.xz -C /tmp/libz \
    && mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib \
    && apk del --purge .build-deps glibc-i18n \
    && rm -rf /tmp/*.apk /tmp/gcc /tmp/gcc-libs.tar.xz /tmp/libz /tmp/libz.tar.xz /var/cache/apk/*

RUN apk add --no-cache alpine-baselayout ca-certificates bash curl procps

COPY --from=build /usr/lib/jvm/graalvm /usr/lib/jvm/graalvm

CMD java -version
