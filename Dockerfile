FROM centos:latest
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone

ARG BT_VERSION="http://download.bt.cn/install/install_6.0.sh"
ENV BT_VERSION=${BT_VERSION}

COPY ./sh /zyb/shell

RUN yum update -y \
    && yum install -y git \
    && yum install -y expect \
    && yum install -y crontabs \
    && yum install -y sudo \
    && yum install -y wget \
    && yum install -y python3 \
    && yum clean all

RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip
 

RUN wget -O install.sh ${BT_VERSION}
RUN yes y | /bin/bash install.sh

RUN echo "/zyb" > /www/server/panel/data/admin_path.pl \
    && echo "8888" > /www/server/panel/data/port.pl \
    && python3 /www/server/panel/tools.py panel zyb \
    && expect /zyb/shell/expect.sh

RUN ln -sfv /zyb/shell/run.sh /usr/bin/run-bt && chmod a+x /usr/bin/run-bt

EXPOSE 8888 443 80 21 20

CMD ["/bin/bash","/usr/bin/run-bt"]
