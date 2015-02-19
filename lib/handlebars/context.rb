require 'handlebars/source'
require 'execjs'
require 'pry'

require 'v8'


module Handlebars
  class Context
    def initialize
      src = File.open(Handlebars::Source.bundled_path, 'r').read
      @js = ExecJS.compile(src)

      @partials = Handlebars::Partials.new
      handlebars_set('partials', @partials)
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
      handlebars_set(key, value)
    end

    def [](key)
      handlebars_get(key)
    end

    class << self
      attr_accessor :current
    end

    private

    def handlebars_set(key, value)
      @js.call('(function (key, value) { Handlebars[key] = value; })', key, value);
    end

    def handlebars_get(key)
      @js.call('(function (key) {return Handlebars[key]; })', key);
    end

    def data
      handlebars[:_rubydata] ||= @js.call('Handlebars.create')
    end
  end
end
