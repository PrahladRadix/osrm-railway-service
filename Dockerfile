FROM osrm/osrm-backend:latest

WORKDIR /data

COPY start.sh /usr/local/bin/start-osrm
RUN chmod +x /usr/local/bin/start-osrm

EXPOSE 5000

CMD ["/usr/local/bin/start-osrm"]
