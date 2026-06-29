#!/bin/sh
set -eu

PORT="${PORT:-5000}"
PBF_URL="${PBF_URL:-${OSM_PBF_URL:-}}"
OSRM_PROFILE="${OSRM_PROFILE:-/opt/car.lua}"
OSRM_BASENAME="${OSRM_BASENAME:-map}"
OSRM_ALGORITHM="${OSRM_ALGORITHM:-mld}"
FORCE_REBUILD="${FORCE_REBUILD:-false}"

if [ -z "$PBF_URL" ]; then
  echo "ERROR: PBF_URL or OSM_PBF_URL is required."
  exit 1
fi

PBF_FILE="/data/${OSRM_BASENAME}.osm.pbf"
OSRM_FILE="/data/${OSRM_BASENAME}.osrm"

if [ "$FORCE_REBUILD" = "true" ]; then
  echo "FORCE_REBUILD=true, removing existing OSRM files."
  rm -f /data/"${OSRM_BASENAME}".osrm*
fi

if [ ! -f "$PBF_FILE" ]; then
  echo "Downloading OSM PBF from $PBF_URL"
  wget -O "$PBF_FILE" "$PBF_URL"
else
  echo "Using existing PBF: $PBF_FILE"
fi

if [ ! -f "$OSRM_FILE" ]; then
  echo "Extracting OSRM graph with profile $OSRM_PROFILE"
  osrm-extract -p "$OSRM_PROFILE" "$PBF_FILE"

  if [ "$OSRM_ALGORITHM" = "ch" ]; then
    echo "Contracting OSRM graph with CH"
    osrm-contract "$OSRM_FILE"
  else
    echo "Partitioning/customizing OSRM graph with MLD"
    osrm-partition "$OSRM_FILE"
    osrm-customize "$OSRM_FILE"
  fi
else
  echo "Using existing OSRM graph: $OSRM_FILE"
fi

echo "Starting OSRM on port $PORT with algorithm $OSRM_ALGORITHM"
exec osrm-routed --algorithm "$OSRM_ALGORITHM" --port "$PORT" "$OSRM_FILE"
