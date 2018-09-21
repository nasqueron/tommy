# Changelog
All notable changes to this project will be documented in this file.
This project adheres to [semantic versioning](https://semver.org/).

## [1.0.0] - 2018-09-21
### Added
- Jenkins 2.0 multi-branch pipelines are supported.

### Changed
- JENKINS_URL must be used instead of HUDSON_URL to configure instance.
- An exit code 1 is provided when the configuration is missing.
- Recommended Docker image is now nasqueron/tommy. 
- Documentation is improved.

### Fixed
- Dependencies and suggested Ruby version upgrade
- Code style has been improve to adhere to another
  bunch of Ruby community conventions.
  
## [0.7.0] - 2016-08-01
### Added
- Favicon and associated mobile/browsers artifacts are provided. 

## [0.6.0] - 2016-07-25
### Changed
- CSS units are simplified.
- Documentation is improved.

## [0.5.0] - 2016-07-21
### Added
- /status route to ease infrastructure test.

## [0.4.0] - 2016-07-11
### Changed
- Code has been refactored to ease maintainability
  and adhere to most Ruby community conventions.
- Dependencies: crack is no longer used, as we parse
  JSON natively.

### Fixed
- Ensure compatibility with new Jenkins jobs not yet built.

## [0.3.0] - 2016-01-07
### Fixed
- Template projects (so non buildable) won't break
  the dashboard anymore.
- Dependencies: active_support → activesupport.

## [0.2.0] - 2012-03-15
### Fixed
- Various fixes by Brian Carstensen.

## [0.1.0] - 2012-03-08
### Changed
- New design.
- Dependencies: removed Shotgun in production.
- Various fixes by Brian Carstensen.

## [0.0.1] - 2011-09-14
### Added
- Initial version by Arfon Smith.
