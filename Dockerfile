FROM amazon/aws-cli
LABEL maintainer="julian3xl <julian3xl@gmail.com>"

RUN yum install -y jq python-pip && pip install --user crudini
ADD run.sh /root/

ENTRYPOINT [ "sh", "/root/run.sh" ]
