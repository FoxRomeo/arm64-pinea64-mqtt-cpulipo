FROM arm64v8/alpine:latest
MAINTAINER docker@intrepid.de

RUN passwd -l root ; \
    apk --no-cache --update --upgrade add \
      mosquitto-clients \
      bc \
      bash

COPY push-mqtt.sh /opt/push-mqtt.sh

# Run the command on container startup
#ENTRYPOINT ["/opt/push-mqtt.sh"]
CMD /opt/push-mqtt.sh

