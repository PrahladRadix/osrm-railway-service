FROM osrm/osrm-backend:latest

WORKDIR /data

RUN printf '%s\n' \
    'deb http://archive.debian.org/debian stretch main' \
    'deb http://archive.debian.org/debian-security stretch/updates main' \
    > /etc/apt/sources.list \
  && printf '%s\n' \
    'Acquire::Check-Valid-Until "false";' \
    'Acquire::AllowInsecureRepositories "true";' \
    > /etc/apt/apt.conf.d/99archive \
  && apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY start.sh /usr/local/bin/start-osrm
RUN chmod +x /usr/local/bin/start-osrm

EXPOSE 5000

CMD ["/usr/local/bin/start-osrm"]
