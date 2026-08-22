FROM searxng/searxng:latest
COPY searxng/settings.yml /etc/searxng/settings.yml
RUN sed -i "s/ultrasecretkey/$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')/" /etc/searxng/settings.yml
