#!/bin/bash
set -e

export LOGDIR=/var/log/airnotifier
export LOGFILE=$LOGDIR/airnotifier.log
export LOGFILE_ERR=$LOGDIR/airnotifier.err

if [ ! -f "./config.py" ]; then
  cp config.py-sample config.py
fi

sed -i 's/https = True/https = False/g' ./config.py

if [ ! -f "./logging.ini" ]; then
  cp logging.ini-sample logging.ini
fi

MONGO_AUTH_PART=""
if [ -n "$MONGO_USERNAME" ] && [ -n "$MONGO_PASSWORD" ]; then
  MONGO_AUTH_PART="$(python -c "import urllib.parse; print(urllib.parse.quote_plus('$MONGO_USERNAME'))"):$(python -c "import urllib.parse; print(urllib.parse.quote_plus('$MONGO_PASSWORD'))")@"
fi

sed -i "s|mongouri = \"mongodb://localhost:27017/\"|mongouri = \"mongodb://${MONGO_AUTH_PART}${MONGO_SERVER-localhost}:${MONGO_PORT-27017}\"/g" ./config.py


if [ ! -f "$LOGFILE" ]; then
  touch "$LOGFILE"
fi

if [ ! -f "$LOGFILE_ERR" ]; then
  touch "$LOGFILE_ERR"
fi

echo "Installing AirNotifier ..."
pipenv run ./install.py
echo "Starting AirNotifier ..."
pipenv run python -m pdb -c continue ./app.py >> "$LOGFILE"
