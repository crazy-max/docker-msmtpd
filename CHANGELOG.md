# Changelog

## 1.8.15-r2 (2021/04/20)

* alpine-s6 3.13-2.2.0.3
* Add `SMTP_SET_FROM_HEADER` env var (#23)
* Add `SMTP_SET_DATE_HEADER` env var
* Add `SMTP_REMOVE_BCC_HEADERS` env var
* Add `SMTP_UNDISCLOSED_RECIPIENTS` env var

## 1.8.15-r1 (2021/03/18)

* Upstream Alpine update

## 1.8.15-r0 (2021/03/13)

* msmtp 1.8.15
* Switch to buildx bake

## 1.8.14-RC1 (2020/12/25)

* msmtp 1.8.14
* Do not fail on permission issue (#21)

## 1.8.11-RC1 (2020/08/07)

* msmtp 1.8.11
* Now based on [Alpine Linux 3.12 with s6 overlay](https://github.com/crazy-max/docker-alpine-s6/)

## 1.8.10-RC3 (2020/05/22)

* Set `S6_BEHAVIOUR_IF_STAGE2_FAILS` behavior

## 1.8.10-RC2 (2020/05/18)

* Fix `SMTP_DOMAIN` impl

## 1.8.10-RC1 (2020/05/18)

* Initial version based on [msmtp](https://marlam.de/msmtp/) 1.8.10
