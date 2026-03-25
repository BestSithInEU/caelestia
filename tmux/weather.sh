#!/usr/bin/env bash
# Drop-in replacement for dracula's weather.sh using Open-Meteo (free, no API key)
# Original used wttr.in which is unreliable/down
export LC_ALL=en_US.UTF-8

CACHE_DIR="${TMPDIR:-/tmp}/dracula-weather"
CACHE_TTL=600 # 10 minutes
GEO_CACHE_TTL=86400 # 24 hours

mkdir -p "$CACHE_DIR"

function cache_valid() {
  local _file="$1" _ttl="$2"
  [[ -f "$_file" ]] && (( $(date +%s) - $(stat -c %Y "$_file" 2>/dev/null || echo 0) < _ttl ))
}

function get_geolocation() {
  local _location="$1" _cache_file="$CACHE_DIR/geo_${_location:-auto}.json"

  if cache_valid "$_cache_file" "$GEO_CACHE_TTL"; then
    cat "$_cache_file"
    return
  fi

  local _geo
  if [[ -n "$_location" ]]; then
    _geo=$(curl -sf --max-time 5 \
      "https://geocoding-api.open-meteo.com/v1/search?name=${_location// /+}&count=1" 2>/dev/null)
    if [[ -n "$_geo" ]]; then
      local _lat _lon _city _country
      _lat=$(printf '%s' "$_geo" | sed -n 's/.*"latitude":\([0-9.-]*\).*/\1/p' | head -1)
      _lon=$(printf '%s' "$_geo" | sed -n 's/.*"longitude":\([0-9.-]*\).*/\1/p' | head -1)
      _city=$(printf '%s' "$_geo" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p' | head -1)
      _country=$(printf '%s' "$_geo" | sed -n 's/.*"country":"\([^"]*\)".*/\1/p' | head -1)
      if [[ -n "$_lat" && -n "$_lon" ]]; then
        printf '{"lat":"%s","lon":"%s","city":"%s","country":"%s"}' "$_lat" "$_lon" "$_city" "$_country" | tee "$_cache_file"
        return
      fi
    fi
  fi

  # Fallback: IP-based geolocation
  _geo=$(curl -sf --max-time 5 "http://ip-api.com/json/?fields=lat,lon,city,country" 2>/dev/null)
  if [[ -n "$_geo" ]]; then
    local _lat _lon _city _country
    _lat=$(printf '%s' "$_geo" | sed -n 's/.*"lat":\([0-9.-]*\).*/\1/p')
    _lon=$(printf '%s' "$_geo" | sed -n 's/.*"lon":\([0-9.-]*\).*/\1/p')
    _city=$(printf '%s' "$_geo" | sed -n 's/.*"city":"\([^"]*\)".*/\1/p')
    _country=$(printf '%s' "$_geo" | sed -n 's/.*"country":"\([^"]*\)".*/\1/p')
    printf '{"lat":"%s","lon":"%s","city":"%s","country":"%s"}' "$_lat" "$_lon" "$_city" "$_country" | tee "$_cache_file"
    return
  fi

  return 1
}

function wmo_to_icon() {
  local _code="$1"
  case "$_code" in
    0)          printf '☀' ;;
    1|2|3)      printf '⛅' ;;
    45|48)      printf '🌫' ;;
    51|53|55|56|57) printf '🌧' ;;
    61|63|65|66|67) printf '☂' ;;
    71|73|75|77)    printf '❄' ;;
    80|81|82)   printf '☂' ;;
    85|86)      printf '❄' ;;
    95|96|99)   printf '⛈' ;;
    *)          printf '☁' ;;
  esac
}

function fetch_weather() {
  local _lat="$1" _lon="$2" _unit="$3"
  local _cache_file="$CACHE_DIR/weather_${_lat}_${_lon}.json"

  if cache_valid "$_cache_file" "$CACHE_TTL"; then
    cat "$_cache_file"
    return
  fi

  local _temp_unit="celsius"
  [[ "$_unit" == "fahrenheit" ]] && _temp_unit="fahrenheit"

  local _resp
  _resp=$(curl -sf --max-time 5 \
    "https://api.open-meteo.com/v1/forecast?latitude=${_lat}&longitude=${_lon}&current=temperature_2m,weather_code&temperature_unit=${_temp_unit}" 2>/dev/null)

  if [[ -n "$_resp" ]]; then
    printf '%s' "$_resp" | tee "$_cache_file"
    return
  fi

  return 1
}

function main() {
  local _show_fahrenheit="${1:-true}"
  local _show_location="${2:-true}"
  local _location="$3"
  local _hide_errors="${4:-false}"

  local _geo
  if ! _geo=$(get_geolocation "$_location"); then
    "$_hide_errors" && printf '' || printf 'Weather Unavailable'
    return
  fi

  local _lat _lon _city
  _lat=$(printf '%s' "$_geo" | sed -n 's/.*"lat":"\([^"]*\)".*/\1/p')
  _lon=$(printf '%s' "$_geo" | sed -n 's/.*"lon":"\([^"]*\)".*/\1/p')
  _city=$(printf '%s' "$_geo" | sed -n 's/.*"city":"\([^"]*\)".*/\1/p')

  local _unit="celsius"
  "$_show_fahrenheit" && _unit="fahrenheit"

  local _weather
  if ! _weather=$(fetch_weather "$_lat" "$_lon" "$_unit"); then
    "$_hide_errors" && printf '' || printf 'Weather Unavailable'
    return
  fi

  local _temp _code _icon _deg
  _temp=$(printf '%s' "$_weather" | sed -n 's/.*"temperature_2m":\([0-9.-]*\).*/\1/p')
  _code=$(printf '%s' "$_weather" | sed -n 's/.*"weather_code":\([0-9]*\).*/\1/p')
  _icon=$(wmo_to_icon "$_code")

  "$_show_fahrenheit" && _deg="°F" || _deg="°C"

  if "$_show_location"; then
    printf '%s %s%s %s' "$_icon" "$_temp" "$_deg" "$_city"
  else
    printf '%s %s%s' "$_icon" "$_temp" "$_deg"
  fi
}

main "$@"
