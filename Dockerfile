FROM arm64v8/alpine:latest
MAINTAINER docker@intrepid.de

COPY push-mqtt.sh /opt/push-mqtt.sh

RUN passwd -l root ; \
    apk --no-cache --update --upgrade add \
      mosquitto-clients \
      bc \
      bash && \
    chmod 755 /opt/push-mqtt.sh


# Run the command on container startup
CMD /opt/push-mqtt.sh

