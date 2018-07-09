FROM debian:stable-slim
MAINTAINER james.mclean@gmail.com

ENV DOMAIN ""
ENV EMAILFROM ""
ENV MAILGUNKEY ""
ENV MAILGUNDOM ""
ENV ABUSEEMAIL ""
ENV COOKIESECRET ""

RUN apt-get update \
    && apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install nginx python-dev libpq-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /xsshunter
COPY . /xsshunter

COPY conf/default.conf /etc/nginx/default.conf
RUN sed -i "s|example.com|$DOMAIN|g" /etc/nginx/default.conf

RUN echo "email_from: $EMAILFROM > /xsshunter/config.yml"
RUN echo "mailgun_api_key: $MAILGUNKEY >> /xsshunter/config.yml"
RUN echo "mailgun_sending_domain: $MAILGUNDOM >> /xsshunter/config.yml"
RUN echo "domain: $DOMAIN >> /xsshunter/config.yml"
RUN echo "abuse_email: $ABUSEEMAIL >> /xsshunter/config.yml"
RUN echo "cookie_secret: $COOKIESECRET >> /xsshunter/config.yml"

# At this point we should have our LE cert ready.
COPY certs/$DOMAIN.crt /etc/nginx/ssl/
COPY certs/$DOMAIN.key /etc/nginx/ssl/

# Install the Python dependencies
RUN pip install -r /xsshunter/api/requirements.txt
RUN pip install -r /xsshunter/gui/requirements.txt

# Run the script that starts the API and the UI services
ENTRYPOINT /xsshunter/run.sh
