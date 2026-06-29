# OSRM Railway Service

This folder deploys the actual OSRM routing engine for driving distance/duration.

It is lighter and simpler than Valhalla for this use case:

```txt
pickup -> partners
pickup -> drop
driving road distance / duration
```

Official OSRM docs:

- https://project-osrm.org/docs/v5.24.0/api/
- https://github.com/Project-OSRM/osrm-backend

## Deploy To Railway

Move this folder to its own GitHub repo, or set Railway's root directory to:

```txt
osrm-railway-service
```

Railway will build from:

```txt
Dockerfile
```

The Dockerfile installs `curl` because the base OSRM image does not include `wget`. The image currently uses Debian Stretch, so the Dockerfile points apt to `archive.debian.org` before installing curl.

Set env vars:

```txt
PBF_URL=https://download2.bbbike.org/osm/extract/planet_76.029,10.075_77.921,11.548.osm.pbf
OSRM_PROFILE=/opt/car.lua
OSRM_BASENAME=map
OSRM_ALGORITHM=mld
OSRM_THREADS=1
FORCE_REBUILD=false
```

Railway provides `PORT` automatically.

Keep `OSRM_THREADS=1` on Railway. Without it, `osrm-extract` may detect many CPUs and use too much memory, causing Railway to kill the container during preprocessing.

## Map File

Do not use the 529 MB Southern Zone file on Railway Free.

Use a smaller `.osm.pbf`:

```txt
Coimbatore + 30-50 km buffer
```

Create it using:

- https://extract.bbbike.org/
- or clip a larger PBF locally with `osmium`

Then upload the `.osm.pbf` to a stable public URL:

- Cloudflare R2
- S3
- Google Cloud Storage
- GitHub Release asset

Set that URL as:

```txt
PBF_URL=https://...
```

Current Coimbatore extract URL:

```txt
PBF_URL=https://download2.bbbike.org/osm/extract/planet_76.029,10.075_77.921,11.548.osm.pbf
```

## Storage Note

OSRM creates processed files:

```txt
map.osrm*
```

These are larger than the input PBF. Attach a Railway volume if available so restarts do not rebuild every time.

## Test Requests

Health-style route:

```bash
curl "https://your-osrm-service.up.railway.app/route/v1/driving/76.9558,11.0168;76.9600,11.0200?overview=false"
```

Distance matrix equivalent:

```bash
curl "https://your-osrm-service.up.railway.app/table/v1/driving/76.9558,11.0168;76.9600,11.0200;76.9700,11.0300?sources=0&destinations=1;2&annotations=distance,duration"
```

Important OSRM coordinate order:

```txt
longitude,latitude
```

HelloDriver usually stores:

```txt
lat,lng
```

So convert `lat,lng` to `lng,lat` before calling OSRM.

## Response Mapping

OSRM `/table` returns:

```txt
distances: meters
durations: seconds
```

Convert:

```txt
distanceKm = meters / 1000
durationSeconds = seconds
```

## Railway Free vs Hobby

Railway Free is likely too small for anything except a tiny city extract.

Railway Hobby is a better starting point:

```txt
OSRM + Coimbatore extract: likely workable
OSRM + Tamil Nadu extract: possible
OSRM + Southern Zone: risky
```
