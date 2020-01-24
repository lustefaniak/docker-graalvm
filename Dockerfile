FROM alpine:3.10.3 AS build

ARG BUILD_JAVA_VERSION=11
ARG BUILD_GRAAL_VERSION=19.3.1

ENV GRAAL_CE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${BUILD_GRAAL_VERSION}/graalvm-ce-java${BUILD_JAVA_VERSION}-linux-amd64-${BUILD_GRAAL_VERSION}.tar.gz

RUN apk add --no-cache wget tar gzip
RUN wget -q $GRAAL_CE_URL -O graalvm-ce-linux-amd64.tar.gz
RUN tar -xzf graalvm-ce-linux-amd64.tar.gz
RUN mkdir -p /usr/lib/jvm
RUN mv graalvm-ce-java${BUILD_JAVA_VERSION}-${BUILD_GRAAL_VERSION} /usr/lib/jvm/graalvm
RUN find /usr/lib/jvm/graalvm -iname java.security | xargs -n1 sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=10/
RUN JRE_DIR=$(find /usr/lib/jvm/graalvm -name languages | sed 's/\/languages//') && echo $JRE_DIR && rm -rf /usr/lib/jvm/graalvm/*src.zip \
    /usr/lib/jvm/graalvm/lib/missioncontrol \
    /usr/lib/jvm/graalvm/lib/visualvm \
    /usr/lib/jvm/graalvm/lib/*javafx* \
    ${JRE_DIR}/plugin \
    ${JRE_DIR}/legal \
    ${JRE_DIR}/bin/javaws \
    ${JRE_DIR}/bin/jjs \
    ${JRE_DIR}/bin/orbd \
    ${JRE_DIR}/bin/pack200 \
    ${JRE_DIR}/bin/policytool \
    ${JRE_DIR}/bin/rmid \
    ${JRE_DIR}/bin/rmiregistry \
    ${JRE_DIR}/bin/servertool \
    ${JRE_DIR}/bin/tnameserv \
    ${JRE_DIR}/bin/unpack200 \
    ${JRE_DIR}/lib/javaws.jar \
    ${JRE_DIR}/lib/deploy* \
    ${JRE_DIR}/lib/desktop \
    ${JRE_DIR}/lib/*javafx* \
    ${JRE_DIR}/lib/*jfx* \
    ${JRE_DIR}/lib/amd64/libdecora_sse.so \
    ${JRE_DIR}/lib/amd64/libprism_*.so \
    ${JRE_DIR}/lib/amd64/libfxplugins.so \
    ${JRE_DIR}/lib/amd64/libglass.so \
    ${JRE_DIR}/lib/amd64/libgstreamer-lite.so \
    ${JRE_DIR}/lib/amd64/libjavafx*.so \
    ${JRE_DIR}/lib/amd64/libjfx*.so \
    ${JRE_DIR}/lib/ext/jfxrt.jar \
    ${JRE_DIR}/lib/ext/nashorn.jar \
    ${JRE_DIR}/lib/oblique-fonts \
    ${JRE_DIR}/lib/plugin.jar \
    ${JRE_DIR}/languages/ \
    ${JRE_DIR}/lib/polyglot/ \
    ${JRE_DIR}/lib/installer/ \
    ${JRE_DIR}/lib/svm/ \
    ${JRE_DIR}/lib/installer \
    ${JRE_DIR}/tools/ \
    ${JRE_DIR}/bin/js \
    ${JRE_DIR}/bin/gu \
    ${JRE_DIR}/bin/lli \
    ${JRE_DIR}/bin/native-image \
    ${JRE_DIR}/bin/node \
    ${JRE_DIR}/bin/npm \
    ${JRE_DIR}/bin/polyglot

RUN du -k /usr/lib/jvm/graalvm | sort -n | tail -n 100


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
