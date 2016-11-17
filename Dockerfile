FROM armhf/alpine:3.4
MAINTAINER docker@intrepid.de

RUN apk add --no-cache mosquitto-clients bc bash

COPY push-mqtt.sh /opt/push-mqtt.sh

# Run the command on container startup
#ENTRYPOINT ["/opt/push-mqtt.sh"]
CMD /opt/push-mqtt.sh

