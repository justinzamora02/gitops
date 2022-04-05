#! /bin/bash

set -e

help() {
  cat <<EOF
Usage: ./scripts/seal-secret.sh $SECRETS.env $CERT
EOF
  exit 1
}

SECRET_ENV=$1
CERT=$2

# Check parameter count
[ $# = 2 ] || help

# Check if file exists
[ ! -f $SECRET_ENV ] && echo "Secret does not exist" && exit 1
[ ! -f $CERT ] && echo "Certificate does not exist" && exit 1

# Check secret env file extension
[[ "${SECRET_ENV##*.}" != env ]] && echo "Secrets must be an env file" && exit 1

SEALED_SECRET="${SECRET_ENV%.*}.yaml"
SECRET_NAME="${SEALED_SECRET%%/*}-secret"

SECRET=$(kubectl create secret generic "$SECRET_NAME" \
  --dry-run=client -oyaml \
  --from-env-file="$SECRET_ENV")

if [ -f $SEALED_SECRET ]; then
  echo -e "$SECRET" | kubeseal --scope cluster-wide --cert "$CERT" -oyaml --merge-into $SEALED_SECRET
else
  echo -e "$SECRET" | kubeseal --scope cluster-wide --cert "$CERT" -oyaml > $SEALED_SECRET
fi