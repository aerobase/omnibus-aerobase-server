require 'file/tail'

add_command 'tail', 'Print service logs', 2 do |cmd_name, props|
  if !::File.exists? "#{etc_path}/aerobase.rb" then
    abort('It looks like aerobase has not been installed yet; skipping tail '\
      'script.')
  end
  
  if props.nil? || props == "" 
    abort("Unknown service name: #{props}, windows tail support service names only. e.g (aerobase-server|nginx|postgresql)")
  end	
  
  servicename = props
  path = "#{log_path}/#{servicename}/logs"
  
  if props == "aerobase-server" 
    files = ["#{path}/server.log", "#{path}/audit.log"]
	number = 200
  else
    files = Dir.glob("#{path}/*.*").reject{ |e| File.directory? e }
	number = 50  
  end
   
  files.each { |file|
    File::Tail::Logfile.open("#{file}", :break_if_eof => true) do |log|
	  puts ""
	  puts "==> #{file} <=="
      puts ""	  
	  log.backward(number).tail { |line| puts line }
	  rescue File::Tail::BreakException	
    end
  }  
 end