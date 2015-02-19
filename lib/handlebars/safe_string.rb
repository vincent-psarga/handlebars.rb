module Handlebars
  class SafeString
    def self.new(string)
      if context = Context.current
        context.js.call('(function (str) {return new Handlebars.SafeString(str)})', string)
      else
        fail "Cannot instantiate Handlebars.SafeString outside a running template Evaluation"
      end
    end
  end
end