# ssl-monitor
Retrieves DNS records from Cloudflare DNS and generates a Prometheus Blackbox
Exporter configuration based on the discovered subdomains. It is designed to
automate the setup of blackbox.yml targets for SSL or HTTP monitoring.

## Configuration and Running
Use `main.sh` to fetch and generate the `blackbox.yaml` file. Run `main.sh`
with the `-f` flag to ignore previously fetched subdomains and force a fresh
fetch of current ones.

See `.example.env` for configuration.

## How It Works
- `get-subdomains.sh`
  Fetches all DNS records (usually A, AAAA, and CNAME) using Cloudflare's API.
- `generate-blackbox-config.sh`
  Reads the subdomains and injects them into a `blackbox.yml` configuration by
  modifying the targets field of a provided template file.
- `prometheus-blackbox.template.yml`
  This file serves as the template for the actual `blackbox.yml`. Only the
  targets section is modified automatically, all other settings remain
  untouched and can be customized as needed.
- Output is written to `dist/blackbox.yml`

## Template File
You are expected to provide a valid prometheus-blackbox.template.yml file.
The script only overwrites the targets field in it. Any additional modules,
configuration options, or probe settings can be customized freely in the
template and will be preserved.

| Dependencies | |
|--|--|
| Prometheus `>= 2.43.0` | Monitoring database. |
| Blackbox Exporter | Used for HTTP status/SSL certificate checking. |
| cURL | |
| jq | Command-line JSON processor. |
