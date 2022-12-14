FROM python:3.10-alpine3.16

LABEL maintainer="Fletcher <miguel.gueifao@42lisboa.com>"

COPY requirements.txt /tmp/requirements.txt

RUN apk add --no-cache --virtual .build-deps gcc libc-dev

RUN apk add --no-cache git
RUN git clone -b 0.4.17 --depth 1 https://github.com/python-greenlet/greenlet.git /greenlet
RUN sed -i 's/use_tracing/tracing/g' /greenlet/greenlet.c
RUN pip install -e /greenlet
RUN apk del git

RUN pip install --no-cache-dir -r /tmp/requirements.txt
RUN apk del .build-deps gcc libc-dev

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

COPY ./gunicorn_conf.py /gunicorn_conf.py

COPY ./app /app
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Meinheld
CMD ["/start.sh"]
