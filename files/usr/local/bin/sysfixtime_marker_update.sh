#!/bin/sh

SYSFIXTIME_MARKER="/etc/sysfixtime_marker"
SLEEP="$1"

cleanup () {
  echo "Stop updating sysfixtime marker"
  kill -TERM "$!" 2>/dev/null
  exit 0
}
trap cleanup INT TERM

if [ "$1" = '' ]; then
  SLEEP="30"
else
  SLEEP="$1"
fi

echo "Start updating sysfixtime marker every $SLEEP seconds"

while true; do
  if touch "$SYSFIXTIME_MARKER" ; then
    sleep "$SLEEP" &
    wait
  else
    exit 1
  fi
done

