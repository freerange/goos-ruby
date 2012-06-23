module Interfaces
  def implement(interface, methods)
    Class.new do
      include interface

      attr_reader :context

      def initialize(context)
        @context = context
      end

      def implement(*args)
        @context.implement(*args)
      end

      methods.each do |method, implementation|
        define_method(method, implementation)
      end
    end.new(self)
  end
end

class Object
  include Interfaces
end
