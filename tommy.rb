require 'sinatra'
require 'rest-client'
require 'active_support/all'
require 'hashie'
require 'erb'

HUDSON_URL = ENV['HUDSON_URL'] || 'http://username:password@my.hudsonurl.com'

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

  def self.parse_incoming_json(json)
    returned_projects = []
    projects = json['jobs']

    projects.each do |project|
      next unless project['buildable']

      returned_projects << Project.new(
        name: project['displayName'].tr('-', ' '),
        build_score: project['healthReport'].first['score'].to_i,
        last_build_number: project['builds'].first['number'],
        last_build_url: (project['lastBuild'].blank? ? '' : project['lastBuild']['url']),
        last_stable_build: (project['lastStableBuild'].blank? ? '' : project['lastStableBuild']['number']),
        health_report: project['healthReport'].first['description'],
        last_complete_url: (project['lastCompletedBuild'].blank? ? '' : project['lastCompletedBuild']['url']),
        last_failed_url: (project['lastFailedBuild'].blank? ? '' : project['lastFailedBuild']['url']),
        colour: project['color']
      )
    end

    return returned_projects
  end

  def green?
    last_stable_build == last_build_number
  end

  def building?
    colour.include?('anime')
  end
end

get '/' do
  json = RestClient::Resource.new("#{HUDSON_URL}/api/json?depth=1")
  @projects = Project.parse_incoming_json(JSON.parse(json.get))

  erb :index
end

helpers do
  def css_for_project(project)
    score = project.build_score
    if project.green?
      if score == 100
        'best'
      elsif score >= 80
        'better'
      elsif score >= 60
        'good'
      elsif score >= 40
        'bad'
      else
        'worse'
      end
    elsif project.building?
      'building'
    else
      'worst'
    end
  end
end
