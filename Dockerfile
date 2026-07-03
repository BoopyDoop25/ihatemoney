FROM python:3.11-slim as builder

ENV PORT="8000" \
    # Keeps Python from generating .pyc files in the container
    PYTHONDONTWRITEBYTECODE=1 \
    # Turns off buffering for easier container logging
    PYTHONUNBUFFERED=1

# ihatemoney configuration
ENV DEBUG="False" \
    ACTIVATE_ADMIN_DASHBOARD="False" \
    ACTIVATE_DEMO_PROJECT="True" \
    ADMIN_PASSWORD="" \
    ALLOW_PUBLIC_PROJECT_CREATION="True" \
    BABEL_DEFAULT_TIMEZONE="UTC" \
    GREENLET_TEST_CPP="no" \
    MAIL_DEFAULT_SENDER="Budget manager <admin@example.com>" \
    MAIL_PASSWORD="" \
    MAIL_PORT="25" \
    MAIL_SERVER="localhost" \
    MAIL_USE_SSL="False" \
    MAIL_USE_TLS="False" \
    MAIL_USERNAME="" \
    SECRET_KEY="tralala" \
    SESSION_COOKIE_SECURE="True" \
    SHOW_ADMIN_EMAIL="True" \
    SQLALCHEMY_DATABASE_URI="sqlite:////database/ihatemoney.db" \
    SQLALCHEMY_TRACK_MODIFICATIONS="False" \
    APPLICATION_ROOT="/" \
    ENABLE_CAPTCHA="False" \
    LEGAL_LINK=""

ADD . /src

RUN echo "**** install build dependencies ****" &&\
    apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev

ADD . /src

RUN echo "**** install pip packages ****" && \
    pip install --user --no-cache-dir \
    gunicorn && \
    pip install --user --no-cache-dir -e /src[database]


FROM python:3.11-slim

RUN echo "**** install runtime packages ****" && \
    apt-get update && apt-get install -y --no-install-recommends \
    libpq5 && \
    echo "**** create runtime folder ****" && \
    mkdir -p /etc/ihatemoney &&\
    echo "**** create user abc:abc ****" && \
    useradd -u 1000 -U -d /src abc && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

COPY --from=builder /root/.local /home/abc/.local

VOLUME /database
EXPOSE ${PORT}
USER abc
ENV PATH=/home/abc/.local/bin:$PATH
ENTRYPOINT ["/src/conf/entrypoint.sh"]
