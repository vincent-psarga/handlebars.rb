module Handlebars
  class Template
    def initialize(context, fn)
      @context, @fn = context, fn
    end

    def call(*args)
      current = Handlebars::Context.current
      Handlebars::Context.current = @context

      @context.js.call("(function (tmpl, args) {return Handlebars.compile(tmpl).apply(null, args)})", @fn, args)
    ensure
      Handlebars::Context.current = current
    end
  end
end