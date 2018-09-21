## Tommy

Tommy is a little Sinatra app that likes to keep an eye on Jenkins (or Hudson)
build statuses.

It divides the screen into cards, each representing a build status
and offering quick links.

See https://builds.nasqueron.org for a live example.

### Getting started

Put your Jenkins URL in place (HUDSON_URL) and boot the app.
If you are password protecting your Hudson dashboard then encode like this:
http://username:password@instance.domain.tld

A Docker image is also provided:

```
docker pull nasqueron/tommy
docker run -dt -p 8080:4567 -e JENKINS_URL=http://ci.domain.tld nasqueron/tommy
```
 
### Exit codes

The app uses the following exit codes:

*   0: regular exit
*   1: required configuration environment variable is missing

### Contributors

* Written by [@arfon](http://twitter.com/arfon "Twitter")
* Currently maintained by
  [Sébastien Santoro aka Dereckson](https://www.dereckson.be/)
