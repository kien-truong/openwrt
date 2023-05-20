#!/bin/sh

OUT_DIR="/var/prometheus"
TMP_FILE="$OUT_DIR/thermal_zone.tmp"
PROM_FILE="$OUT_DIR/thermal_zone.prom"
SLEEP="$1"

cleanup () {
  echo "Stop updating thermal zone metrics"
  kill -TERM "$!" 2>/dev/null
  exit 0
}
trap cleanup INT TERM

dump_temp() {
  find /sys/class/thermal -maxdepth 1 -name 'thermal_*' | while IFS= read -r p; do
    DIR_NAME=$(basename "$p")
    TYPE=$(cat "$p/type")
    ZONE=$(echo "$DIR_NAME" | sed -r 's/thermal_zone([0-9]+)/\1/g')
    METRIC_NAME="node_thermal_zone_temp{type=\"$TYPE\",zone=\"$ZONE\"}"
    TEMP=$(echo "scale=3; $(cat "$p/temp") / 1000" | bc)
    echo "$METRIC_NAME $TEMP" > "$TMP_FILE" && mv -f "$TMP_FILE" "$PROM_FILE"
  done
}


if [ "$1" = '' ]; then
  SLEEP="30"
else
  SLEEP="$1"
fi

echo "Start updating thermal zone metrics every $SLEEP seconds"

mkdir -p "$OUT_DIR"

while true; do
  if dump_temp ; then
    sleep "$SLEEP" &
    wait
  else
    exit 1
  fi
done
