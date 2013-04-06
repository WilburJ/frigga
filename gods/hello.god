God.watch do |w|
  w.name = "hello"
  w.start = "ruby /home/wilbur/dev/frigga/bin/hello.rb"
  w.keepalive
end
