#!/bin/bash


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

domains="${domains::-1}]"

yq -y ".scrape_configs[0].static_configs[0].targets = $domains" < \
    prometheus-blackbox.template.yml
