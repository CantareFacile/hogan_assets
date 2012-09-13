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
      template_path = TemplatePath.new scope
      template_namespace = HoganAssets::Config.template_namespace

      text = if template_path.is_hamstache?
        raise "Unable to complile #{template_path.full_path} because haml is not available. Did you add the haml gem?" unless HoganAssets::Config.haml_available?
        Haml::Engine.new(data, @options).render
      else
        data
      end

      text = compressor.compress(text)

      compiled_template = Hogan.compile(text)
      template_name = scope.logical_path.inspect

      # Only emit the source template if we are using lambdas
      text = '' unless HoganAssets::Config.lambda_support?
      <<-TEMPLATE
        this.#{template_namespace} || (this.#{template_namespace} = {});
        this.#{template_namespace}[#{template_path.name}] = new Hogan.Template(#{compiled_template}, #{text.inspect}, Hogan, {});
      TEMPLATE
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

    class TemplatePath
      attr_accessor :full_path

      def initialize(scope)
        self.template_path = scope.logical_path
        self.full_path = scope.pathname
      end

      def is_hamstache?
        full_path.to_s.end_with? '.hamstache'
      end

      def name
        @name ||= relative_path.dump
      end

      private

      attr_accessor :template_path

      def relative_path
        @relative_path ||= template_path.gsub(/^#{HoganAssets::Config.path_prefix}\/(.*)$/i, "\\1")
      end
    end
  end
end
