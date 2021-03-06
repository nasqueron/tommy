## Tommy

Tommy is a little Sinatra app that likes to keep an eye on Jenkins (or Hudson)
build statuses.

It divides the screen into cards, each representing a build status
and offering quick links.

See https://builds.nasqueron.org for a live example.

### Getting started

Put your Jenkins URL in place (JENKINS_URL) and boot the app.
If you are password protecting your Hudson dashboard then encode like this:
https://username:password@instance.domain.tld

### Run with Docker

A Docker image is also provided. It exposes a WEBrick server on the port 4567.

```
docker pull nasqueron/tommy
docker run -dt -p 8080:4567 -e JENKINS_URL=https://ci.domain.tld nasqueron/tommy
```
 
### Exit codes

The app uses the following exit codes:

*   0: regular exit
*   1: required configuration environment variable is missing

### Contributors

* Written by [@arfon](https://twitter.com/arfon "Twitter")
* Currently maintained by
  [Sébastien Santoro aka Dereckson](https://www.dereckson.be/)
