# docker-tommy

### Run the container

To run the container:

`docker run -d -it -p 4567:4567 --name=tommy -e HUDSON_URL=http://ci.nasqueron.org dereckson/tommy`

The HUDSON_URL variable environment should point
to your Jenkins or Hudson instance.

If a login is required to use the API,
use https://login:password@jenkins.domain.tld as syntax.
