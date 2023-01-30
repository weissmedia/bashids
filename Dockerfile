ARG image
FROM ${image}

USER root

COPY ./bashids /usr/local/bin/bashids

COPY ./entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint
RUN chmod +x /entrypoint

ENTRYPOINT ["/entrypoint"]