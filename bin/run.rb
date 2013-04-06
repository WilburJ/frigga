#!/usr/bin/env ruby
#ecoding: utf-8
require "pathname"

Dir.chdir Pathname.new(__FILE__).realpath + "../.."
unless Dir.exist?(".bundle")
  puts "First run, install require gem to local dir"
  strap = %w(script/gem-install --binstubs bin --deployment --local --without development:test)
  abort "Can't bootstrap, dependencies are outdated." unless system *strap
end

DIR = File.expand_path("")
abort "God does not  exist..." unless File.exist?("#{DIR}/bin/god")

require "thor"
class Cli < Thor
  desc "start", "Start God, Frigga and #{DIR}/gods/*.god"
  def start
    #wake up god
    wakeup_god = %W(bin/god --no-syslog --no-events --log-level info --log #{DIR}/log/god.log  -c #{DIR}/conf/base.god)
    abort "Start God failed!" unless system *wakeup_god

    #use god to load frigga.god for wakeing frigga up
    wakeup_frigga = "bin/god load conf/frigga.god"
    `#{wakeup_frigga}`
    abort "Start Frigga failed!" unless $? == 0

    #start process
    Dir.glob(File.join(Dir.pwd, 'gods', "*.god")) do |god|
      start_process = "bin/god load #{god}"
      `#{start_process}`
      warn "Start process[#{god}] failed!" unless $? == 0
    end

    #check process status
    puts "Command: #{DIR}/bin/god status"
    system("bin/god status")
  end

  desc "stop", "Stop God and Frigga, Don't stop *.god"
  def stop
    #stop frigg
    stop_frigg = "bin/god stop frigga"
    `#{stop_frigg}`
    warn "Stop Frigga failed!" unless $? == 0

    #stop god
    stop_god = %W(bin/god quit)
    abort "Stop God failed!" unless system *stop_god
  end

  desc "nuke", "Stop God,Frigga and *.god"
  def nuke
    #terminate god
    nuke_god = %W(bin/god terminate)
    abort "Nuke all gods failed!" unless system *nuke_god
  end

end

Cli.start(ARGV)

