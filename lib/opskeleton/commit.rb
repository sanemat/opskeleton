
def add_writable(g,with)
  readonly = g.remotes.first.url
  writable = readonly.gsub(/git\:\/\/*\//,with)
  unless readonly.eql?(writable)
    g.add_remote('writable',writable) 
  end
end

module  Opsk
  class Commit < Thor::Group
    include Thorable, Thor::Actions

    class_option :message, :type=> :string, :desc => 'optional commit message'
    class_option :writable_remote, :type=> :string, :desc => 'add remote write repo', :default => 'git@'

    def validate
	check_root
    end


    def commit
	Dir["modules/*"].reject{|o| not File.directory?(o)}.each do |d|
	  if File.exists?("#{d}/.git")
	    g = Git.init(d)
	    if g.status.changed.keys.length > 0
		puts "Changes found for #{d}:\n\n"
		puts "#{g.show}\n"
		g.checkout('master')
		if options['message']
		  g.commit_all(options['message']) 
		else 
		  puts 'Please provide commit message:'
		  g.commit_all(STDIN.gets.chomp) 
		end
		add_writable(g,options['writable_remote']) if options['writable_remote']
	    end
	  end
	end
    end


  end
end
