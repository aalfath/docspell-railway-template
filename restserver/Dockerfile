# Docspell REST server (web UI + API), official image pinned by version and digest.
FROM ghcr.io/docspell/restserver:v0.43.0@sha256:bc8f0c0e072726aca121f07b9f4519ea8360ee3e0a6464f4cd960d3260093826

COPY --chmod=755 start.sh /opt/railway-start.sh

EXPOSE 7880
ENTRYPOINT ["/opt/railway-start.sh"]
