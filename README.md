<p align="center"><a href="https://github.com/crazy-max/docker-msmtpd" target="_blank"><img height="128" src="https://raw.githubusercontent.com/crazy-max/docker-msmtpd/master/.github/docker-msmtpd.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/msmtpd/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-msmtpd?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-msmtpd/actions?workflow=build"><img src="https://img.shields.io/github/workflow/status/crazy-max/docker-msmtpd/build?label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/msmtpd/"><img src="https://img.shields.io/docker/stars/crazymax/msmtpd.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/msmtpd/"><img src="https://img.shields.io/docker/pulls/crazymax/msmtpd.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <a href="https://www.codacy.com/app/crazy-max/docker-msmtpd"><img src="https://img.shields.io/codacy/grade/5c62fcad87254c1f912d397b4fa33062.svg?style=flat-square" alt="Code Quality"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

Lightweight SMTP relay using [msmtpd](https://marlam.de/msmtp/) and based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other Docker images!

💡 Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun) project!

## Features

* Run as non-root user
* Latest [msmtp/msmtpd](https://marlam.de/msmtp/) release compiled from source
* Bind to [unprivileged port](#ports)
* Multi-platform image

## Docker

### Multi-platform image

Following platforms for this image are available:

```
$ docker run --rm mplatform/mquery crazymax/msmtpd:latest
Image: crazymax/msmtpd:latest
 * Manifest List: Yes
 * Supported platforms:
   - linux/amd64
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64
   - linux/386
   - linux/ppc64le
```

### Environment variables

* `TZ`: Timezone assigned to the container (default `UTC`)
* `PUID`: Daemon user id (default `1000`)
* `PGID`: Daemon group id (default `1000`)
* `SMTP_HOST`: SMTP relay server to send the mail to. **required**
* `SMTP_PORT`: Port that the SMTP relay server listens on. Default `25` or `465` if TLS.
* `SMTP_TLS`: Enable or disable TLS (also known as SSL) for secured connections (`on` or `off`).
* `SMTP_STARTTLS`: Start TLS from within the session (`on`, default), or tunnel the session through TLS (`off`).
* `SMTP_TLS_CHECKCERT`: Enable or disable checks of the server certificate (`on` or `off`). They are enabled by default.
* `SMTP_AUTH`: Enable or disable authentication and optionally [choose a method](https://marlam.de/msmtp/msmtp.html#Authentication-commands) to use. The argument `on` chooses a method automatically.
* `SMTP_USER`: Set the user name for authentication. Authentication must be activated with the `SMTP_AUTH` env var.
* `SMTP_PASSWORD`: Set the password for authentication. Authentication must be activated with the `SMTP_AUTH` env var.
* `SMTP_DOMAIN`: Argument of the `SMTP EHLO` command. Default is `localhost`.
* `SMTP_FROM`: Set the envelope-from address. Supported substitution patterns can be found [here](https://marlam.de/msmtp/msmtp.html#Commands-specific-to-sendmail-mode).

> 💡 `SMTP_USER_FILE` and `SMTP_PASSWORD_FILE` can be used to fill in the value from a file, especially for Docker's secrets feature.

> 💡 More info: https://marlam.de/msmtp/msmtp.html

### Ports

* `2500`: SMTP relay port

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. You can use the following [docker compose template](examples/compose/docker-compose.yml), then run the container:

```bash
docker-compose up -d
docker-compose logs -f
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
docker-compose pull
docker-compose up -d
```

## How can I help?

All kinds of contributions are welcome :raised_hands:! The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon: You can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max) :clap: or by making a [Paypal donation](https://www.paypal.me/crazyws) to ensure this journey continues indefinitely! :rocket:

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
