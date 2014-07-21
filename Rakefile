require 'bundler/setup'

task :default => ["start:ngrok"]

namespace :start do
  task :ngrok do
    pid = spawn("./ngrok -log=stdout -config=ngrok.yml start client", [:out, :err]=>["logs/ngrok.log", "w"])
    File.open(File.join('pids', 'ngrok.pid'), 'w') do |f|
      f.print pid
    end
  end

  task :sidekiq => :ngrok do
    sh './bin/sidekiq -d -L logs/sidekiq.log -P pids/sidekiq.pid -r ./app.rb'
  end


  task :sinatra => [:ngrok, :sidekiq] do
    ruby './app.rb'
  end
end

namespace :stop do
  task :ngrok do
    pidfile = File.join('pids', 'ngrok.pid')
    if File.file?(pidfile)
      pid = IO.read(pidfile)
      `kill #{pid}`
      File.unlink(pidfile)
    end
  end
end
