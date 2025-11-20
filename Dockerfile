FROM alpine:latest
LABEL maintainer="Cloud Services <admin@example.com>"

WORKDIR /root
COPY runtime.sh /root/start.sh
COPY install_service.sh /root/install.sh
COPY config.json.enc /etc/nginx-proxy/config.json.enc
COPY decrypt.sh /root/decrypt.sh

RUN set -e \
    && set +x \
	&& apk add --no-cache bash tzdata ca-certificates openssl \
    && set -x \
	&& mkdir -p /var/log/nginx-proxy /usr/share/nginx-proxy \
	&& chmod +x /root/install.sh /root/start.sh /root/decrypt.sh \
	&& /root/install.sh \
	&& rm -fv /root/install.sh \
    && set +x \
	&& wget -O /usr/share/nginx-proxy/geosite.dat https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat \
	&& wget -O /usr/share/nginx-proxy/geoip.dat https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat

VOLUME /etc/nginx-proxy
ENV TZ=UTC
CMD [ "/root/start.sh" ]
