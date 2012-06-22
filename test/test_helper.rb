require "minitest/spec"
require "minitest/autorun"

require "java"

$CLASSPATH << File.expand_path("../../lib/develop", __FILE__)

require "hamcrest-core-1.2.jar"
require "hamcrest-library-1.2.jar"
require "junit-dep-4.6.jar"
require "windowlicker-core-DEV.jar"
require "windowlicker-swing-DEV.jar"

$LOAD_PATH.unshift(File.expand_path("../../app", __FILE__))

require "env"
