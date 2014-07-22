class Gits
  attr_reader :githuburl
  attr_accessor :repo

  def initialize(opts = {})
    @repo = opts.fetch('repo', nil)
    @githuburl = opts.fetch('githuburl', nil)
  end

  def githuburl=(url)
    @githuburl = url
    @repo = get_repo_from_url(url)
  end

  #def repo
  #  if @repo.nil?
  #    unless @githuburl.nil?
  #      mdata = /.*\/(\w+.git)$/.match(myvar)
  #      @repo = mdata.captures[0] unless mdata.nil?
  #    end
  #  end
  #  @repo
  #end

  def clone
    Dir.chdir(GITDIR) do
      `git clone --mirror #{@githuburl}`
    end
  end


  def sync
    Dir.chdir(File.join(GITDIR, @repo)) do 
      update = IO.popen(['git', 'fetch', '--all', '-p']) {|git_io|
        @msglog = git_io.read
      }
      puts @msglog unless $?.exitstatus == 0
      #puts update.inspect
    end
  end

  def self.exists?(url)
    #git = self.new({'githuburl' => url})
    repo = self.get_repo_from_url(url)
    puts repo
    File.exists?(File.join(GITDIR, repo))
  end

  def self.all
    Dir.chdir(GITDIR) do
      @gits = Dir.glob(File.join("**", "*.git"))
    end
    @gits
  end

  def self.find(repo_json)
    pp repo_json
    pp self.all
    if self.all.include?("#{repo_json['name']}.git")
      ret = self.new({'repo' => "#{repo_json['name']}.git"})
      pp ret
    else
      ret = false
    end
    ret
  end

  def self.get_repo_from_url(url)
    mdata = /.*\/([a-zA-Z0-9._-]+.git)$/.match(url)
    pp [url, mdata]
    repo = mdata.captures[0] unless mdata.nil?
    puts repo
    repo || nil
  end

end