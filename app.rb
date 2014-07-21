require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pp'
require 'redis'
require 'sidekiq'

also_reload 'gits.rb'

#$redis = Redis.new

configure do 
  GITDIR = '/srv/git-mirrors'
end

require './gits'

class SinatraWorker
  include Sidekiq::Worker

  def perform(mirror)
    git = Gits.new(mirror)
    git.sync
  end
end

get '/' do
  @mirrors = Gits.all
  puts @mirrors
  erb :index
end

post '/webhook' do
  halt 400, "Required parameter 'payload' missing" unless params.has_key?('payload')
  mirror = Gits.find(JSON.parse(params['payload'])["repository"])
  halt 400, "Not mirroring this repo" unless mirror
  puts mirror.repo
  SinatraWorker.perform_async mirror.repo
end