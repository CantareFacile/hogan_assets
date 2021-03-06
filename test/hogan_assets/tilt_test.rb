require 'test_helper'

module HoganAssets
  class TiltTest < Test::Unit::TestCase
    include TestSupport

    def teardown
      HoganAssets::Config.reset!
    end

    def test_mime_type
      assert_equal 'application/javascript', HoganAssets::Tilt.default_mime_type
    end

    def test_render
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
define("path/to/template", ["hogan"], function(Hogan) {
  return new Hogan({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }});
});
~.strip
    end

    def test_remove_comments
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "<!-- html comment -->This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
define("path/to/template", ["hogan"], function(Hogan) {
  return new Hogan({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }});
});
~.strip
    end

    def test_hamstache_render
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.hamstache'

      template = HoganAssets::Tilt.new(scope.s_path) { "%p This is {{hamstache}}" }

      assert_equal template.render(scope, {}), %Q~
define("path/to/template", ["hogan"], function(Hogan) {
  return new Hogan({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"<p>This is \");t.b(t.v(t.f(\"hamstache\",c,p,0)));t.b(\"</p>\");return t.fl(); },partials: {}, subs: {  }});
});
~.strip
    end

    def test_render_with_lambdas
      HoganAssets::Config.configure do |config|
        config.lambda_support = true
      end

      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
define("path/to/template", ["hogan"], function(Hogan) {
  return new Hogan({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }});
});
~.strip
    end


    def test_strip_whitespace
      HoganAssets::Config.configure do |config|
      end

      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'
      template = HoganAssets::Tilt.new(scope.s_path) { "
        <p>
          This is {{mustache}}
        </p>
        " }
      assert_equal template.render(scope, {}), %Q~
define("path/to/template", ["hogan"], function(Hogan) {
  return new Hogan({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"<p> This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));t.b(\" </p>\");return t.fl(); },partials: {}, subs: {  }});
});
~.strip
    end

    def test_path_prefix
      HoganAssets::Config.configure do |config|
        config.path_prefix = 'app/templates'
      end

      scope = make_scope '/myapp/app/assets/javascripts', 'app/templates/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
define("template", ["hogan"], function(Hogan) {
  return new Hogan({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }});
});
~.strip
    end

    def test_template_namespace
      HoganAssets::Config.configure do |config|
        config.template_namespace = 'HoganTemplates'
      end

      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
define("path/to/template", ["hogan"], function(Hogan) {
  return new Hogan({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }});
});
~.strip
    end

    def test_haml_options
      HoganAssets::Config.configure do |config|
        config.haml_options[:ugly] = true
        config.hamstache_extensions = ['hamlhbs']
      end
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.hamlhbs'
      template = HoganAssets::Tilt.new(scope.s_path) { "%p\n  This is {{mustache}}" }
      assert_match /<p>/, template.render(scope, {})
    end

    def test_slim_options
      HoganAssets::Config.configure do |config|
        config.slim_options[:pretty] = false
        config.slimstache_extensions = ['slimhbs']
      end
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.slimhbs'
      template = HoganAssets::Tilt.new(scope.s_path) { "p This is {{mustache}}" }
      assert_match /<p>/, template.render(scope, {})
    end
  end
end
