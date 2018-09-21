# docker-tommy

### Run the container

To run the container:

`docker run -dt -p 4567:4567 --name=tommy -e JENKINS_URL=http://ci.nasqueron.org nasqueron/tommy`

The JENKINS_URL variable environment should point
to your Jenkins or Hudson instance.

If a login is required to use the API,
use https://login:password@jenkins.domain.tld as syntax.
