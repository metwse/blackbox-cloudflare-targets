# ssl-monitor
Retrieves DNS records from Cloudflare DNS and generates a Prometheus Blackbox
Exporter configuration based on the discovered subdomains. It is designed to
automate the setup of blackbox.yml targets for SSL or HTTP monitoring.

## Configuration and Running
Use `main.sh` to fetch and generate the `yaml` file. See
`.example.env` for configuration.

## How It Works
The template is read from `stdin` and the processed output is written to
`stdout`. Example usage:
```sh
TOKEN=1234 ./main.sh \
    < prometheus-blackbox.template.yml \
    > prometheus-blackbox.yml
```

- `get_subdomains`
  Fetches all DNS records (A, AAAA, and CNAME) using Cloudflare's API.
- `generate_blackbox_config`
  Reads the subdomains and injects them into the `.yml` configuration by
  modifying the `targets` field of a provided template file.
- `prometheus-blackbox.template.yml`
  Example template file. Only the targets section is modified in templates,
  all other settings remain untouched and can be customized as needed.

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
| yq `>= 4.46` | Command-line YAML processor. |

## Automation
Prometheus can reload its configuration at runtime with Lifecycle API. See
[configuration section](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
for enabling it.

Once enabled, you can reload the configuration by running:
```sh
curl -X POST http://localhost:9090/-/reload
```

### Sample Setup

Since version `2.43.0`, Prometheus supports include directive.\
Add following line to your `prometheus.yml`:
```yml
scrape_config_files:
   - /path/to/autogenerated/prometheus-blackbox.yml
```

You can automate the update and reload process with a cronjob like this:
```cron
0 0 * * * TOKEN=CLOUDFLARETOKEN /path/to/main.sh < /path/to/prometheus-blackbox.template.yml > /path/to/autogenerated/prometheus-blackbox.yml && curl -X POST http://localhost:9090/-/reload
```
