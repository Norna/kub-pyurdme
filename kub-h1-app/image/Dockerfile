# Builds a Docker image with pyURDME stable version built from
# git sources. The image is at:
#
#     https://registry.hub.docker.com/u/fenicsproject/
#
# Authors:
# Raingsei V, Haisocheat <raingsei.hai@gmail.com>

FROM raingsei/pyurdme:latest

RUN easy_install pip
RUN pip install redis

ENV CELERY_VERSION 3.1.19

RUN pip install celery=="$CELERY_VERSION"


# --link some-rabbit:rabbit "just works"
#ENV CELERY_BROKER_URL amqp://guest@rabbit

# install celery
RUN pip install Celery

ENV C_FORCE_ROOT=true

RUN mkdir /data
COPY mesh /mesh
COPY app_h1.py /app_h1.py
COPY io_parameter.py /io_parameter.py
COPY celery_conf.py /celery_conf.py
COPY controller.py /controller.py
COPY run.sh /run.sh
COPY run_tasks.py /run_tasks.py 


CMD ["/usr/bin/python","/controller.py"]

