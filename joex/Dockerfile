# Docspell job executor (OCR, text extraction, conversion), official image
# pinned by version and digest. Contains ocrmypdf, tesseract, unoconv etc.
FROM ghcr.io/docspell/joex:v0.43.0@sha256:19c8daf22de5ff7625c16abb319c6bcb1354ada0782bd546d91b2be72acbb34f

COPY --chmod=755 start.sh /opt/railway-start.sh

EXPOSE 7878
ENTRYPOINT ["/opt/railway-start.sh"]
