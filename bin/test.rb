#File.open("/proc/8266/stat", "r") do |f|
#  puts  f.readline.strip.split(" ")[21]
#end
#File.open("/proc/8266/stat", "r") do |f|
#  puts  f.readline.strip.split(" ")[21]
#end
jiffies =  IO.read("/proc/8266/stat").split(/\s/)[21].to_i
uptime = IO.readlines("/proc/stat").find {|t| t =~ /^btime/ }.split(/\s/)[1].strip.to_i
time = Time.at(uptime + jiffies / 100)
a =  time.strftime("%Y-%m-%d %H:%M:%S")
puts IO.read("/proc/8266/cmdline").gsub(/\^@/, " ").chop
