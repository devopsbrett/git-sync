God.pid_file_directory = File.expand_path('../pids', __FILE__)

God.watch do |w|
  w.name = 'ngrok'
  w.start = "./ngrok -log=stdout -config=ngrok.yml start client"

  w.log = File.expand_path('../logs/ngrok.log', __FILE__)
  w.group = 'githooks'
  w.dir = File.dirname(File.expand_path('.', __FILE__))

  w.interval = 30.seconds

  w.transition(:init, {true => :up, false => :start}) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end

    on.condition(:tries) do |c|
      c.times = 8
      c.within = 2.minutes
      c.transition = :start
    end
  end

  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end

    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
    end
  end
end
