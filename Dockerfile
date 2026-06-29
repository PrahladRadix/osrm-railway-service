FROM osrm/osrm-backend:latest

WORKDIR /data

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY start.sh /usr/local/bin/start-osrm
RUN chmod +x /usr/local/bin/start-osrm

EXPOSE 5000

CMD ["/usr/local/bin/start-osrm"]
