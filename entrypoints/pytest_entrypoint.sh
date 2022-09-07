#! /bin/sh
set -e
#alias python="python -m pytest"

python -m pytest -v --cov=. --cov-report=xml:/output/coverage.xml

# replace the current pid 1 with original entrypoint
exec "$@"