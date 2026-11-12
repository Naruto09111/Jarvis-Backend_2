# Railway Dockerfile for the OpenJarvis backend.
# The source ships as a zip archive (OpenJarvis-Backend-NoDocker.zip), so it is
# extracted at build time. Python 3.10-3.13 is supported (see pyproject.toml).
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOME=/app \
    # hatch-vcs needs a version because the zip has no .git directory
    SETUPTOOLS_SCM_PRETEND_VERSION=1.0.0

WORKDIR /app

COPY ["requirements (1).txt", "OpenJarvis-Backend-NoDocker.zip", "./"]

# Extract the archive (python's zipfile avoids needing unzip in the image)
RUN python -c "import zipfile; zipfile.ZipFile('OpenJarvis-Backend-NoDocker.zip').extractall('/app/src')"

RUN pip install --no-cache-dir -r "requirements (1).txt"

# Install the OpenJarvis package with its server extra
RUN pip install --no-cache-dir "/app/src/OpenJarvis-main[server]"

# Binding 0.0.0.0 requires OPENJARVIS_API_KEY to be set (see deploy/systemd/openjarvis.service)
CMD ["sh", "-c", "jarvis serve --host 0.0.0.0 --port ${PORT:-8000}"]

