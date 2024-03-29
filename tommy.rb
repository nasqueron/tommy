# frozen_string_literal: true

#   -------------------------------------------------------------
#   Tommy - Visualisation dashboard for Jenkins
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Author:         Arfon Smitn (Zooniverse)
#   Maintainer:     Sebastien Santoro aka Dereckson
#   Project:        Nasqueron
#   Created:        2011-09-14
#   Dependencies:   Sinatra
#   -------------------------------------------------------------

require 'rest-client'
require 'active_support/all'
require 'hashie'
require 'erb'
require 'sinatra'

#   -------------------------------------------------------------
#   Table of contents
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#   :: Environment
#   :: Project class
#   :: Controller
#   :: Routes
#   :: Helpers
#
#   -------------------------------------------------------------

#   -------------------------------------------------------------
#   Environment
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

begin
  JENKINS_URL = ENV.fetch('JENKINS_URL')
rescue KeyError
  # HUDSON_URL is deprecated and will be removed in Tommy 2.0.
  if ENV.include? 'HUDSON_URL'
    JENKINS_URL = ENV['HUDSON_URL']
    $stderr.write %(\e[31m
╔══════════════════════════════════════════════════════════╗
║                 *** DEPRECATION NOTICE ***               ║
╟──────────────────────────────────────────────────────────╢
║                                                          ║
║ You currently use the HUDSON_URL environment variable    ║
║ to configure your Jenkins (or Hudson?) instance URL.     ║
║                                                          ║
║ As Hudson isn't maintained anymore, we're migrating this ║
║ setting to JENKINS_URL.                                  ║
║                                                          ║
║ Simply replace HUDSON_URL by JENKINS_URL in your Docker  ║
║ or service configuration.                                ║
║                                                          ║
║ The current setting is deprecated and will be dropped    ║
║ in a future version (plan is Tommy 2.0).                 ║
║                                                          ║
║ Reference: https://devcentral.nasqueron.org/T1448        ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
\e[0m
)
  else
    $stderr.write %(You must define the JENKINS_URL environment variable
to point to your Jenkins instance URL, without trailing slash.

If you need to pass credentials, you can use the following syntax:
https://username:password@jenkins.domain.tld
)
    exit 1

  end
end

begin
  JENKINS_MULTI_BRANCH = !!ENV.fetch('JENKINS_MULTI_BRANCH')
rescue KeyError
  JENKINS_MULTI_BRANCH = false
end

#   -------------------------------------------------------------
#   Project class
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

##
# This class represents a defined or discrete hash for a Jenkins project.
class Project < Hashie::Dash
  property :name
  property :build_score
  property :last_build_number
  property :last_build_url
  property :last_stable_build
  property :health_report
  property :last_complete_url
  property :last_failed_url
  property :colour

  ##
  # Builds a project name from a name and a prefix
  # Returns a string.
  def self.build_name(name, prefix)
    return name if prefix.nil?

    [prefix, name.tr('-', ' ')].join(' / ')
  end

  ##
  # Parses a job element of the Jenkins API.
  # Returns a Project instance.
  def self.parse_project(data, prefix = nil)
    name = build_name(data['displayName'], prefix)

    project = Project.new(
      name: name,
      last_build_number: data['builds'].first['number'],
      colour: data['color']
    )

    if data['healthReport']
      project.build_score = data['healthReport'].first['score'].to_i
      project.health_report = data['healthReport'].first['description']
    end

    unless data['lastStableBuild'].blank?
      project.last_stable_build = data['lastStableBuild']['number']
    end

    urls = {
      'lastBuild' => 'last_build_url=',
      'lastCompletedBuild' => 'last_complete_url=',
      'lastFailedBuild' => 'last_failed_url='
    }
    urls.each do |api_property, local_property|
      next if data[api_property].blank?

      project.send(local_property, data[api_property]['url'])
    end

    project
  rescue NoMethodError
    nil
  end

  def self.multi_project?(data)
    data['_class'].start_with?('org.jenkinsci.plugins.workflow.multibranch')
  end

  ##
  # Parses a JSON API reply into an array of Project instances
  def self.parse_incoming_json(json)
    projects = []

    json['jobs'].each do |job|
      parse_projects(job).each do |project|
        projects << project unless project.nil?
      end
    end

    projects
  end

  def self.parse_projects(job)
    if multi_project?(job)
      parse_multi_projects(job)
    else
      [parse_project(job)]
    end
  end

  def self.parse_multi_projects(root_job)
    projects = []
    prefix = root_job['name']

    root_job['jobs'].each do |job|
      projects << parse_project(job, prefix)
    end

    projects
  end

  ##
  # Determines if a build is green
  def green?
    last_stable_build == last_build_number
  end

  ##
  # Determines if a build is still building
  def building?
    colour.include?('anime')
  end
end

#   -------------------------------------------------------------
#   Controller
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def build_jenkins_url
  if JENKINS_MULTI_BRANCH
    "#{JENKINS_URL}/api/json?depth=2"
  else
    "#{JENKINS_URL}/api/json?depth=1"
  end
end

def prepare_dashboard
  url = build_jenkins_url
  client = RestClient::Resource.new(url)
  response = JSON.parse(client.get)
  @projects = Project.parse_incoming_json(response)

  erb :index
end

#   -------------------------------------------------------------
#   Routes
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

get '/' do
  prepare_dashboard
end

get '/manifest.json' do
  content_type 'application/json'
  erb :manifest
end

get '/status' do
  'ALIVE'
end

#   -------------------------------------------------------------
#   Helpers
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

helpers do
  def css_scores
    {
      100 => 'best',
      80 => 'better',
      60 => 'good',
      40 => 'bad',
      0 => 'worse'
    }
  end

  def css_for_score(score)
    css_scores.each do |threshold, css_class|
      return css_class if score >= threshold
    end
    raise 'Specify in scores a value for the lower score you can get.'
  end

  def css_for_project(project)
    if project.green?
      css_for_score(project.build_score)
    elsif project.building?
      'building'
    else
      'worst'
    end
  end
end
