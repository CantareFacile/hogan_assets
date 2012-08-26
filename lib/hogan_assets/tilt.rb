require 'tilt'
require 'htmlcompressor'

module HoganAssets
  class Tilt < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def initialize_engine
      require_template_library 'haml'
    rescue LoadError
      # haml not available
    end

    def evaluate(scope, locals, &block)
      text = if scope.pathname.extname == '.hamstache'
        raise "Unable to complile #{scope.pathname} because haml is not available. Did you add the haml gem?" unless HoganAssets::Config.haml_available?
        Haml::Engine.new(data, @options).render
      else
        data
      end

      text = compressor.compress(text)

      compiled_template = Hogan.compile(text)
      # template_name = scope.logical_path.inspect

      # Only emit the source template if we are using lambdas
      # text = '' unless HoganAssets::Config.lambda_support?
      # <<-TEMPLATE
      #   this.HoganTemplates || (this.HoganTemplates = {});
      #   this.HoganTemplates[#{template_name}] = new Hogan.Template(#{compiled_template}, #{text.inspect}, Hogan, {});
      # TEMPLATE
      text = '' unless HoganAssets::Config.lambda_support?
      "new Hogan.Template(#{compiled_template}, #{text.inspect}, Hogan, {});"
    end

    protected

    def prepare; end

    private

    def compressor
      @compressor ||= HtmlCompressor::Compressor.new({
        :enabled => true,
        :remove_multi_spaces => true,
        :remove_comments => true,
        :remove_intertag_spaces => true,
        :remove_quotes => true,
        :compress_css => true,
        :compress_javascript => true,
        :simple_doctype => true,
        :remove_script_attributes => true,
        :remove_style_attributes => true,
        :remove_link_attributes => true,
        :remove_form_attributes => true,
        :remove_input_attributes => true,
        :remove_javascript_protocol => true,
        :remove_http_protocol => true,
        :remove_https_protocol => true,
        :preserve_line_breaks => false,
        :simple_boolean_attributes => true
      })
    end
  end
end
