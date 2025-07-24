#!/bin/bash

# Reads stdin (should be a yaml).
yaml="$(cat)"

# Returns with code 1 if the request failed.
unwrap() {
    success=$(jq -cr .success <<< "$1")

    if [ "$success" != 'true' ]; then
        return 1
    fi

    jq -cr .result <<< "$1"
}

# Fetch all subdomains of account.
get_subdomains() {
    >&2 echo "Fetching: zones"
    zones="$(curl "https://api.cloudflare.com/client/v4/zones" \
        -H "Authorization: Bearer $TOKEN" 2> /dev/null)"

    zones="$(unwrap "$zones")"
    if [ $? == 1 ]; then
        return 1
    fi

    zone_count=$(jq -r '. | length' <<< "$zones")
    zone_counter=1

    while read -r zone; do
        >&2 echo "Fetching: dns_records ($(jq -rc .name <<< "$zone"))" \
            "($zone_counter/$zone_count)"
        zone_counter=$(( $zone_counter + 1 ))

        records="$(curl "https://api.cloudflare.com/client/v4/zones/$(
                jq -rc .id <<< "$zone"
            )/dns_records" -H "Authorization: Bearer $TOKEN" 2> /dev/null)"

        records="$(unwrap "$records")"
        if [ $? == 1 ]; then
            return 1
        fi

        while read -r record; do
            record_type="$(jq -rc .type <<< "$record")"

            if [[ "$record_type" = @(A|AAAA|CNAME) ]]; then
                jq -rc .name <<< "$record"
            fi
        done <<< "$(jq -rc .[] <<< "$records")"
    done <<< "$(jq -rc .[] <<< "$zones")"
}

# Formats domains into YAML list.
format_list() {
    domains="[ "

    # Reads domains line by line from stdin
    while read -r domain; do
        if [[ "$domain" == \*\.* ]]; then
            if [ -n "$STAR_REPLACE" ]; then
                domain="$STAR_REPLACE${domain:1}"
            else
                domain="${domain:2}"
            fi
        fi

        domains+='"'"$domain"'",'
    done;

    echo "${domains::-1}]"
}

generate_blackbox_config() {
    yq -y ".scrape_configs[0].static_configs[0].targets = $1"
}


subdomains="$(get_subdomains)"

if [ $? != 0 ]; then
    >&2 echo "ERROR: get_subdomains failed!"
    exit 1
fi

generate_blackbox_config "$(format_list <<< "$subdomains")" <<< "$yaml"

>&2 echo "SUCCESS"
