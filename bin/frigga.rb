#!/usr/bin/env ruby
#ecoding: utf-8
$: << "../lib" << "./lib"

require "pathname"

Dir.chdir Pathname.new(__FILE__).realpath + "../.."

DIR = File.expand_path("")

VER        = '0.0.1'

#http-server port
HTTP_PORT   = 9001

#gos's sock
GOD_SOCK = "/tmp/god.17165.sock"

#log level: debug > info > warn > fatal
#LOG_LEVEL  = 'debug'

require "bundler/setup"
require 'frigga'

#ok, let's go
Frigga::WebServer.run!
