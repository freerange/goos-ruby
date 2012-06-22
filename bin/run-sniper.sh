#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../../app", __FILE__))

require "main"

Main.main("localhost", "sniper", "sniper", "item-54321")
