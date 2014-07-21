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

class GitSync
  include Sidekiq::Worker

  def perform(mirror)
    git = Gits.new(mirror)
    git.sync
  end
end

class GitClone
  include Sidekiq::Worker

  def perform(url)
    git = Gits.clone(url)
  end
end

get '/' do
  @mirrors = Gits.all
  puts @mirrors
  erb :index
end

get '/add' do
  erb :add
end

post '/add' do
  halt 400, "Required parameter 'repo' missing" unless params.has_key?('repo')
  halt 409, "Repo already being mirrored" if Gits.exist?(params['repo'])
  GitClone.perform_async params['repo']
  redirect '/'
end


post '/webhook' do
  halt 400, "Required parameter 'payload' missing" unless params.has_key?('payload')
  mirror = Gits.find(JSON.parse(params['payload'])["repository"])
  halt 400, "Not mirroring this repo" unless mirror
  puts mirror.repo
  GitSync.perform_async mirror.repo
end
