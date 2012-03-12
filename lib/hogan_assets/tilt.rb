require 'tilt'

module HoganAssets
  class Tilt < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def evaluate(scope, locals, &block)
      "new Hogan.Template(#{Hogan.compile(data)});"
    end

    protected

    def prepare; end
  end
end
