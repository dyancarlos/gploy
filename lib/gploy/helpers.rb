require 'logger'

module Gploy
  module Helpers  
    
    def log(msg)
      puts "--> #{msg}"
    end
    
    def run_remote(command)
      log(command)
      @shell.exec!(command)
    end

    def dirExists?(dir)
      File.directory? dir
    end

    def run_local(command)
      log(command)
      Kernel.system command
    end

    def sys_link(name)
      run_remote "ln -s ~/rails_app/#{name}/public ~/public_html/#{name}"
    end

    def read_hook_sample(name)
      puts "Escrevendo Hook File"
      path = "~/repos/#{name}.git/hooks/post-receive"
      File.open("config/post-receive", "r") do |fline|
        while(line = fline.gets)
          @shell.exec!("echo '#{line}' >> #{path}")
        end
      end
    end

    def update_hook_into_server(username, url, name)
      run_local "chmod +x config/post-receive && scp config/post-receive #{username}@#{url}:repos/#{name}.git/hooks/"
    end

    def update_hook(username, url, name)
      run_local "scp config/post-receive #{username}@#{url}:repos/#{name}.git/hooks/"
    end

    def migrate(name)
      run_remote "cd rails_app/#{name}/ && rake db:migrate RAILS_ENV=production"
    end

    def restart_server(name)
      run_remote "cd rails_app/#{name}/tmp && touch restart.txt"
      puts "Server Restarted"
    end

    def post_commands
      commands = <<CMD
        #!/bin/sh
        cd ~/rails_app/#{@app_name}
        env -i git reset --hard 
        env -i git pull #{@origin} master
        env -i rake db:migrate RAILS_ENV=production
        env -i touch ~/rails_app/#{@app_name}/tmp/restart.txt 
CMD
        puts commands
    end

    def post_commands_server
      commands = <<CMD
        config:
        url: <user_server>
        user: <userbae>
        password: <password>
        app_name: <app_name>
        origin: <git origin>
CMD
        puts commands
    end
  end
end