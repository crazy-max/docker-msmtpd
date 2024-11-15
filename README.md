<p align="center"><a href="https://github.com/crazy-max/docker-msmtpd" target="_blank"><img height="128" src="https://raw.githubusercontent.com/crazy-max/docker-msmtpd/master/.github/docker-msmtpd.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/msmtpd/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-msmtpd?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-msmtpd/actions?workflow=build"><img src="https://img.shields.io/github/actions/workflow/status/crazy-max/docker-msmtpd/build.yml?branch=master&label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/msmtpd/"><img src="https://img.shields.io/docker/stars/crazymax/msmtpd.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/msmtpd/"><img src="https://img.shields.io/docker/pulls/crazymax/msmtpd.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

Lightweight SMTP relay using [msmtpd](https://marlam.de/msmtp/) as a Docker
image.

> [!TIP] 
> Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun)
> project!

___

* [Features](#features)
* [Build locally](#build-locally)
* [Image](#image)
* [Environment variables](#environment-variables)
* [Ports](#ports)
* [Usage](#usage)
  * [Docker Compose](#docker-compose)
  * [Kubernetes](#kubernetes)
  * [Command line](#command-line)
* [Upgrade](#upgrade)
* [Contributing](#contributing)
* [License](#license)

## Features

* Run as non-root user
* Latest [msmtp/msmtpd](https://marlam.de/msmtp/) release compiled from source
* Bind to [unprivileged port](#ports)
* Multi-platform image

## Build locally

```shell
git clone https://github.com/crazy-max/docker-msmtpd.git
cd docker-msmtpd

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

## Image

| Registry                                                                                         | Image                           |
|--------------------------------------------------------------------------------------------------|---------------------------------|
| [Docker Hub](https://hub.docker.com/r/crazymax/msmtpd/)                                            | `crazymax/msmtpd`                 |
| [GitHub Container Registry](https://github.com/users/crazy-max/packages/container/package/msmtpd)  | `ghcr.io/crazy-max/msmtpd`        |

Following platforms for this image are available:

```
$ docker buildx imagetools inspect crazymax/msmtpd --format "{{json .Manifest}}" | \
  jq -r '.manifests[] | select(.platform.os != null and .platform.os != "unknown") | .platform | "\(.os)/\(.architecture)\(if .variant then "/" + .variant else "" end)"'

linux/386
linux/amd64
linux/arm/v6
linux/arm/v7
linux/arm64
linux/ppc64le
linux/s390x
```

## Environment variables

* `TZ`: Timezone assigned to the container (default `UTC`)
* `PUID`: Daemon user id (default `1500`)
* `PGID`: Daemon group id (default `1500`)
* `SMTP_HOST`: SMTP relay server to send the mail to. **required**
* `SMTP_PORT`: Port that the SMTP relay server listens on. Default `25` or `465` if TLS.
* `SMTP_TLS`: Enable or disable TLS (also known as SSL) for secured connections (`on` or `off`).
* `SMTP_STARTTLS`: Start TLS from within the session (`on`, default), or tunnel the session through TLS (`off`).
* `SMTP_TLS_CHECKCERT`: Enable or disable checks of the server certificate (`on` or `off`). They are enabled by default.
* `SMTP_AUTH`: Enable or disable authentication and optionally [choose a method](https://marlam.de/msmtp/msmtp.html#Authentication-commands) to use. The argument `on` chooses a method automatically.
* `SMTP_USER`: Set the username for authentication. Authentication must be activated with the `SMTP_AUTH` env var.
* `SMTP_PASSWORD`: Set the password for authentication. Authentication must be activated with the `SMTP_AUTH` env var.
* `SMTP_DOMAIN`: Argument of the `SMTP EHLO` command (default `localhost`)
* `SMTP_FROM`: Set the envelope-from address. Supported substitution patterns can be found [here](https://marlam.de/msmtp/msmtp.html#Commands-specific-to-sendmail-mode).
* `SMTP_ALLOW_FROM_OVERRIDE`: Allow configured envelope-from address to be overriden by actual SMTP MAIL FROM . Can be [`on` or `off`](https://marlam.de/msmtp/msmtp.html#Commands-specific-to-sendmail-mode) (default `on`)
* `SMTP_SET_FROM_HEADER`: When to set a From header. Can be [`auto`, `on` or `off`](https://marlam.de/msmtp/msmtp.html#Commands-specific-to-sendmail-mode) (default `auto`)
* `SMTP_SET_DATE_HEADER`: When to set a Date header. Can be [`auto` or `off`](https://marlam.de/msmtp/msmtp.html#Commands-specific-to-sendmail-mode) (default `auto`)
* `SMTP_REMOVE_BCC_HEADERS`: Controls whether to remove Bcc headers. Can be [`on` or `off`](https://marlam.de/msmtp/msmtp.html#Commands-specific-to-sendmail-mode) (default `on`)
* `SMTP_UNDISCLOSED_RECIPIENTS`: When set, the original To, Cc, and Bcc headers of the mail are removed and a single new header line `To: undisclosed-recipients:;` is added. Can be [`on` or `off`](https://marlam.de/msmtp/msmtp.html#Commands-specific-to-sendmail-mode) (default `off`)
* `SMTP_DSN_NOTIFY`: Set the condition(s) under which the mail system should send DSN (Delivery Status Notification) messages as comma separated values. Available values are [`off`, `never`, `failure`, `delay` and `success`](https://marlam.de/msmtp/msmtp.html#index-dsn_005fnotify) (default `off`)
* `SMTP_DSN_RETURN`: Controls how much of a mail should be returned in DSN (Delivery Status Notification) messages. Can be [`headers`, `full` or `off`](https://marlam.de/msmtp/msmtp.html#index-dsn_005freturn) (default `off`)

> 💡 `SMTP_USER_FILE` and `SMTP_PASSWORD_FILE` can be used to fill in the value from a file, especially for Docker's secrets feature.

> 💡 More info: https://marlam.de/msmtp/msmtp.html

## Ports

* `2500`: SMTP relay port

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. You can use the following
[docker compose template](examples/compose/compose.yml), then run the container:

```bash
docker compose up -d
docker compose logs -f
```

### Kubernetes

To install on a Kubernetes cluster, you can use the following
[kubernetes deployment template](examples/kubernetes/deployment.yaml), then create the deployment:

```bash
kubectl apply -f deployment.yaml
```

### Command line

You can also use the following minimal command:

```bash
$ docker run -d -p 2500:2500 --name msmtpd \
  -e "SMTP_HOST=smtp.example.com" \
  crazymax/msmtpd
```

## Upgrade

Recreate the container whenever I push an update:

```bash
docker compose pull
docker compose up -d
```

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star
the project, or to raise issues. You can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max)
or by making a [PayPal donation](https://www.paypal.me/crazyws) to ensure this
journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
