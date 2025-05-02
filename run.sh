#!/bin/bash

set -e #if any line fails the entire program fails

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>& 1 && pwd )"

function try-load-dotenv {
    if [ ! -f "${THIS_DIR}/.env" ]; then
        echo "no .env file found"
        return 1
    fi
        # load environment variables from .env file
        while read -r line; do
                export "$line"
        done < <(grep -v '^#' "${THIS_DIR}/.env" | grep -v '^$')
}

function usage {
    echo "Usage: $0 <task> <args>"
    echo "Tasks:"
    echo "  install       Install the package and its dependencies"
    echo "  build         Build the package"
    echo "  publish       Publish the package to PyPI"
    echo "  install_dev   Install the package in development mode"
    echo "  clean         Clean up cached files"
    echo "  test          Run tests"
    echo "  lint          Run linters"
    echo "  format        Run formatters"
    echo "  check         Run linters and formatters"
    echo "  run           Run the program"
}
function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

function install {
    # python -m pip install --upgrade pip
    python -m pip install --editable "$THIS_DIR/[dev]"
}

function build {
    python -m build --sdist --wheel  "$THIS_DIR/"
}

function publish:test {
    try-load-dotenv || true
    # publish the package to pypi
    python -m twine upload dist/* \
        --repository testpypi \
        --username "$TEST_PYPI_USERNAME" \
        --password "$TEST_PYPI_PASSWORD" \
        --skip-existing
}

function publish:prod {
    try-load-dotenv || true
    # publish the package to pypi
    python -m twine upload dist/* \
        --repository pypi \
        --username "$PROD_PYPI_USERNAME" \
        --password "$PROD_PYPI_PASSWORD" \
        --skip-existing
}

function release:test {
    lint
    clean
    build
    publish:test
}

function release:prod {
    release:test
    publish:prod
}

function install_dev {
    # install the package in development mode
    python -m pip install --editable "${THIS_DIR}/[dev]"
}

function clean {
    # clean up cached files
    rm -rf dist build
    find "${THIS_DIR}" \
      -type d \
      \( \
        -name "*cache*" \
        -o -name "*.dist-info" \
        -o -name "*.egg-info" \
        \) \
      -not -path "${THIS_DIR}/venv/*" \
      -exec rm -r {} +
}

function test {
    # run tests
    pytest -v --tb=short --disable-warnings --maxfail=1
}

function lint {
    pre-commit run --all-files
}

function lint:ci {
    SKIP=no-commit-to-branch pre-commit run --all-files
}

function format {
    # run formatters
    black --line-length 120
    isort --profile black
}

function check {
    # run linters
    flake8 --max-line-length=120 --ignore=E501,E203,E266,E402,W503,W504,E731,E722,E501,E722,E1101,E1102,E1103,E1104,E1105,E1106,E1107,E1108,E1109,E1110,E1111,E1112,W504,W505,W506,W507,W508,W509,W510,W511,W512,W513,W514,W515,W516,W517,W518,W519,W520,W521,W522,W523,W524,W525,W526,W527,W528,W529
    mypy --ignore-missing-imports --follow-imports=skip --strict --show-error-codes --show-column-numbers
    black --check --line-length 120
    isort --check-only --profile black
}
function run {
    # run the program
    python -m "${THIS_DIR}/src/main.py" "${@}"
}
function run_tests {
    # run tests
    pytest -v --tb=short --disable-warnings --maxfail=1
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help} # if nothing in @ do left
