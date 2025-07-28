# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Upgrade ruby version to v3.4.3 ([PR 740](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/740))

## [3.0.0] - 2025-06-16

### Changed

- Upgrade Rails to v7.2.2.1 ([PR 641](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/641))
- Use Bun to manage our assets ([PR 641](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/641))
- Upgrade GOV.UK Frontend version to v5.10.0 ([PR 672](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/672))
- Upgrade CCS Frontend version to v1.4.1 ([PR 672](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/672))
- Upgrade Rails to v8.0.2.0 ([PR 670](https://github.com/Crown-Commercial-Service/pmp-idam/pull/670))
- Replace Arask with Solid Queue ([PR 670](https://github.com/Crown-Commercial-Service/pmp-idam/pull/670))

## [2.2.1] - 2025-03-24

### Changed

- Upgrade GOV.UK Frontend version to v5.9.0 ([PR 616](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/616))
- Upgrade CCS Frontend version to v1.3.3 ([PR 616](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/616))

## [2.2.0] - 2025-01-23

### Changed

- Upgrade ruby version to v3.4.1 ([PR 540](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/540))
- Upgrade alpine version to v3.21 ([PR 540](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/540))
- Update ruby to v3.3.6 ([PR 489](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/489))
- Update Node to LTS Jod (v22.11.0) ([PR 488](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/488))
- Update alpine to v3.20 ([PR 395](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/395))
- Update ruby to v3.3.5 ([PR 393](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/393))
- Update ruby to v3.3.4 ([PR 391](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/391))

### Removed

- Remove Turbolinks as it is no longer supported ([PR 392](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/392))

## [2.1.1] - 2024-08-22

### Security

- Various dependency updates

## [2.1.0] - 2024-05-19

### Added

- Update how we manage assets for TailSpend ([PR 284](https://github.com/Crown-Commercial-Service/tailspend-idam/pull/284))

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
