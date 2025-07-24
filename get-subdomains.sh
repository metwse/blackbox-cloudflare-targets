#!/bin/bash


# Exits with code 1 if the request failed.
unwrap() {
    success=$(jq -cr .success <<< "$1")

    if [ "$success" != 'true' ]; then
        exit 1
    fi

    jq -cr .result <<< "$1"
}


>&2 echo "Fetching: zones"
zones="$(curl "https://api.cloudflare.com/client/v4/zones" \
    -H "Authorization: Bearer $TOKEN" 2> /dev/null)"
zones="$(unwrap "$zones")"

zone_count=$(jq -r '. | length' <<< "$zones")
zone_counter=1

while read -r zone; do
    >&2 echo "Fetching: dns_records ($(jq -rc .name <<< "$zone"))" \
        "($zone_counter/$zone_count)"
    zone_counter=$(( $zone_counter + 1 ))

    records="$(curl "https://api.cloudflare.com/client/v4/zones/$(
            jq -rc .id <<< "$zone"
        )/dns_records" -H "Authorization: Bearer $TOKEN" 2> /dev/null)"

    while read -r record; do
        record_type="$(jq -rc .type <<< "$record")"

        if [[ "$record_type" = @(A|AAAA|CNAME) ]]; then
            jq -rc .name <<< "$record"
        fi
    done <<< "$(unwrap "$records" | jq -rc .[])"
done <<< "$(jq -rc .[] <<< "$zones")"
