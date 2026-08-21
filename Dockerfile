FROM python:3.12-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
WORKDIR /src
COPY pyproject.toml uv.lock ./
COPY src ./src
RUN uv sync --frozen --no-dev
EXPOSE 8090
HEALTHCHECK --interval=5s --timeout=3s --start-period=10s --retries=10 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8090/healthz')" || exit 1
ENTRYPOINT ["uv", "run", "fraud-check"]
