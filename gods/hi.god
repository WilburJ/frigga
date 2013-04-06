God.watch do |w|
  w.name = "hi"
  w.start = "ruby /home/wilbur/dev/frigga/bin/hidd.rb"
  w.keepalive

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end

end
