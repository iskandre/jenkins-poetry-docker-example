# python-base sets up all our shared environment variables
FROM python:3.7-slim as python-base 
# https://python-poetry.org/docs/configuration/#using-environment-variables
# make poetry create the virtual environment in the project's root
# it gets named `.venv`
ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_PATH=/opt/poetry \
    VENV_PATH=/opt/venv \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 
# poetry and venv to path
ENV PATH="$POETRY_PATH/bin:$VENV_PATH/bin:$PATH"
WORKDIR /app

# builder-base stage is used to build deps + create the virtual environment
FROM python-base as poetry
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential \
    \
    # install poetry - uses $POETRY_VERSION internally, respects $POETRY_VERSION & $POETRY_HOME
    && curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python \
    && mv /root/.poetry $POETRY_PATH \
    # cleanup
    && rm -rf /var/lib/apt/lists/*

ENV PATH="$POETRY_PATH/bin:$PATH"
RUN poetry --version
# pyproject.toml will be copied among other files
COPY . ./
# poetry will build the lock file from scratch if it's missing
RUN rm poetry.lock
# install [tool.poetry.dependencies]
# this will install virtual environment into /.venv because of POETRY_VIRTUALENVS_IN_PROJECT=true
# see: https://python-poetry.org/docs/configuration/#virtualenvsin-project
RUN poetry install --no-interaction --no-root
ENV PATH="/app/.venv/bin:$PATH"

# production stage used for runtime
FROM python-base as runtime
COPY --from=poetry /app /app
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8090
USER root
RUN chmod +x entrypoints/pytest_entrypoint.sh
ENTRYPOINT ["entrypoints/pytest_entrypoint.sh"]