module HoganAssets
  # Change config options in an initializer:
  #
  # HoganAssets::Config.template_extensions = ['mustache']
  #
  # Or in a block:
  #
  # HoganAssets::Config.configure do |config|
  #   config.lambda_support = false
  #   config.path_prefix = 'templates'
  #   config.template_extensions = ['mustache', 'hamstache']
  # end
  #
  module Config
    extend self

    attr_writer :lambda_support, :path_prefix, :template_extensions, :template_namespace, :skip_initialize_namespace

    def configure
      @skip_initialize_namespace = false
      @path_prefix = 'templates'
      yield self
    end

    def haml_available?
      defined? ::Haml::Engine
    end

    def lambda_support?
      @lambda_support
    end

    def path_prefix
      @path_prefix
    end

    def template_namespace
      @template_namespace ||= 'JST'
    end

    def template_extensions
      @template_extensions ||= if haml_available?
                                 ['mustache', 'hamstache']
                               else
                                 ['mustache']
                               end
    end

    def skip_initialize_namespace?
      @skip_initialize_namespace
    end
  end
end
