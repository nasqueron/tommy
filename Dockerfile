#
# Tommy Docker image
# A simple Jenkins dashboard view
#

FROM ruby:3.2
MAINTAINER Sébastien Santoro aka Dereckson <dereckson+nasqueron-docker@espace-win.org>

#
# Prepare the container
#

ENV LANG C.UTF-8

RUN mkdir -p /usr/src/app
COPY . /usr/src/app/
RUN cd /usr/src/app && bundle install

#
# Run the container
#

EXPOSE 4567
WORKDIR /usr/src/app
CMD ["ruby", "/usr/src/app/tommy.rb", "-o", "0.0.0.0"]
