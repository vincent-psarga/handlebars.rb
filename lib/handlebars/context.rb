require 'handlebars/source'
require 'execjs'
require 'pry'

require 'v8'


module Handlebars
  class Context
    def initialize
      src = File.open(Handlebars::Source.bundled_path, 'r').read
      @js = ExecJS.compile(src)

      @partials = handlebars['partials'] = Handlebars::Partials.new
    end

    def js
      @js
    end

    def compile(*args)
      ::Handlebars::Template.new(self, *args)
    end

    def precompile(*args)
      @js.call('Handlebars.precompile', *args)
    end

    def register_helper(name, &fn)
      @js.call('Handlebars.registerHelper', name, fn)
    end

    def register_partial(name, content)
      @js.call('Handlebars.registerpartial', name, content)
    end

    def partial_missing(&fn)
      @partials.partial_missing = fn
    end

    def handlebars
      @js.eval('Handlebars')
    end

    def []=(key, value)
      data[key] = value
    end

    def [](key)
      data[key]
    end

    class << self
      attr_accessor :current
    end

    private

    def data
      handlebars[:_rubydata] ||= @js.call('Handlebars.create')
    end
  end
end
