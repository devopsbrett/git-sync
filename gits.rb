class Gits

  def initialize(reponame)
    @repo = reponame
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


  def repo
    @repo
  end

  def self.all
    Dir.chdir(GITDIR) do
      @gits = Dir.glob(File.join("**", "*.git"))
    end
    @gits
  end

  def self.find(repo_json)
    pp repo_json
    if self.all.include?("#{repo_json['name']}.git")
      ret = self.new("#{repo_json['name']}.git")
    else
      ret = false
    end
    ret
  end
end