FROM phusion/baseimage

RUN groupadd -r hc && useradd -r -m -g hc hc

# Install deps
RUN set -x && apt-get -qq update \
    && apt-get install -y \
		python3-dev \
		libpq-dev \
		gcc \
        python3-setuptools \
        python3-pip \
        python3-psycopg2 \
        python3-rcssmin \
        python3-rjsmin \
        python3-mysqldb \
        subversion \
        uwsgi \
        uwsgi-plugin-python3 \
        --no-install-recommends \
    && svn export https://github.com/healthchecks/healthchecks/tags/v1.0.4 /app \
    && pip3 install --no-cache-dir -r /app/requirements.txt \
    && pip3 install --no-cache-dir braintree raven==5.33.0 \
	&& apt-get remove --purge -y python3-dev gcc libpq-dev \
    && apt-get clean \
    && rm -fr /var/lib/apt/lists/*

WORKDIR /app

COPY . /app/

RUN python3 manage.py collectstatic --noinput && python3 manage.py compress


EXPOSE 5000
RUN mkdir /etc/service/uwsgi
RUN mkdir /etc/service/sendalerts
COPY uwsgi.sh /etc/service/uwsgi/run
COPY sendalerts.sh /etc/service/sendalerts/run
RUN chmod +x /etc/service/uwsgi/run; chmod +x /etc/service/sendalerts/run

USER hc
CMD ["/sbin/my_init"]
