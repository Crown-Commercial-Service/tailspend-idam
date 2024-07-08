# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2024-05-19

### Added

- Update how we manage assets for TailSpend ([PR 284](https://github.com/Crown-Commercial-Service/pmp-idam/pull/284))

### Security

- Various dependency updates

## [2.0.3] - 2024-05-16

### Fixed

- Update ruby to v3.3.1 ([PR 252](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/252))
- Update ruby to v3.3.0 ([PR 213](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/213))
- Remove config related to GPaaS as we do not want it to be used anymore and may cause confusion ([PR 165](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/165))

### Security

- Various dependency updates

## [2.0.2] - 2023-12-13

### Fixed

- Target a specific alpine version ([PR 161](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/161))
- Rename cookie_preferences cookie to cookie_preferences_tailspend so that it does not conflict with corporate website ([PR 157](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/157))
- Optimise dockerfile ([PR 150](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/150))

### Security

- Various dependency updates

## [2.0.1] - 2023-11-27

### Fixed

- Make 503 status page return 200 status code so that Barracuda does not block it ([PR 141](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/141))

### Security

- Various dependency updates

## [2.0.0] - 2023-11-14

### Added

- Update dockerfile to use alpine image ([PR 577](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/127))
- Add the ability to deploy to GPaaS via GitHub actions ([PR 576](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/126))
- Create the service unavailable page ([PR 573](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/125))
- Upgrade rails to v7.1.1 ([PR 562](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/114))

### Security

- Various dependency updates
