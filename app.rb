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

class GitAsync
  include Sidekiq::Worker

  def perform(githash = {}, action = nil)
    git = Gits.new(githash)
    git.send(action)
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
  halt 400, "Required parameter 'repo' missing" unless params.has_key?('githuburl')
  halt 409, "Repo already being mirrored" if Gits.exists?(params['githuburl'])
  GitAsync.perform_async({'githuburl' => params['githuburl']}, 'clone')
  redirect '/'
end


post '/webhook' do
  halt 400, "Required parameter 'payload' missing" unless params.has_key?('payload')
  mirror = Gits.find(JSON.parse(params['payload'])["repository"])
  halt 400, "Not mirroring this repo" unless mirror
  puts mirror.repo
  GitAsync.perform_async({'repo' => mirror.repo}, 'sync')
end
