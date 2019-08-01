#!/usr/bin/env bash

# This is inspired by:
# https://github.com/travis-infrastructure/terraform-config/blob/master/runtests

set -euo pipefail

main() {
  echo -e '\n-----> Validating JSON'
  for f in $(git ls-files '*.json'); do
    echo -en "${f} "
    python -m json.tool <"${f}" >/dev/null
    echo "✓"
  done

  echo -e '\n-----> Running shellcheck'
  for f in $(git grep -El '^#!/.+\b(bash|sh)\b' -- './*' ':(exclude)*.tmpl'); do
    echo -en "${f} "
    shellcheck "${f}"
    echo "✓"
  done

  echo -e '\n-----> Running terraform validate'
  export TF_IN_AUTOMATION=true
  for d in $(git ls-files '*.tf' | xargs -n1 dirname | LC_ALL=C sort | grep -E -v '^\.$|^terraform$' | uniq); do
    echo -en "${d} "
    cd "${d}" || exit 1
    terraform init -backend=false -input=false
    terraform validate
    cd -
    echo "✓"
  done

  echo -e '\n-----> Success!'
}

main "$@"
