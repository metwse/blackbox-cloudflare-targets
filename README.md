# ssl-monitor
Retrieves DNS records from Cloudflare DNS and generates a Prometheus Blackbox
Exporter configuration based on the discovered subdomains. It is designed to
automate the setup of blackbox.yml targets for SSL or HTTP monitoring.

## Configuration and Running
Use `main.sh` to fetch and generate the `yaml` file. See
`.example.env` for configuration.

## How It Works
- `get_subdomains`
  Fetches all DNS records (A, AAAA, and CNAME) using Cloudflare's API.
- `generate_blackbox_config`
  Reads the subdomains and injects them into the `.yml` configuration by
  modifying the `targets` field of a provided template file.
- `prometheus-blackbox.template.yml`
  The template for the actual `.yml`. Only the targets section is modified
  automatically, all other settings remain untouched and can be customized
  as needed.
- Output is written to `stdout`

## Template File
You are expected to provide a valid prometheus-blackbox.template.yml file.
The script only overwrites the targets field in it. Any additional modules,
configuration options, or probe settings can be customized freely in the
template and will be preserved.

## Setup
Tested in `bash >= 5.1`, `ubuntu-server 22.04` and `linux-mint 22.1`.

| Dependencies | |
|--|--|
| Prometheus `>= 2.43.0` | Monitoring database. |
| Blackbox Exporter | Used for HTTP status/SSL certificate checking. |
| cURL | |
| jq | Command-line JSON processor. |
| yq | Command-line YAML processor. |
