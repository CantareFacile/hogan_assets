require 'test_helper'

module HoganAssets
  class TiltTest < Test::Unit::TestCase
   # Try to act like sprockets.
    def make_scope(root, file)
      Class.new do
        define_method(:logical_path) { pathname.to_s.gsub(root + '/', '').gsub(/\..*/, '') }

        define_method(:pathname) { Pathname.new(root) + file }

        define_method(:root_path) { root }

        define_method(:s_path) { pathname.to_s }
      end.new
    end

    def teardown
      HoganAssets::Config.lambda_support = false
      HoganAssets::Config.path_prefix = 'templates'
    end

    def test_mime_type
      assert_equal 'application/javascript', HoganAssets::Tilt.default_mime_type
    end

    def test_render
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
(function() {
this.JST || (this.JST = {});
this.JST[\"path/to/template\"] = new Hogan.Template({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }}, "", Hogan, {});
}).call(this);
~.strip
    end

    def test_hamstache_render
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.hamstache'

      template = HoganAssets::Tilt.new(scope.s_path) { "%p This is {{hamstache}}" }

      assert_equal template.render(scope, {}), %Q~
(function() {
this.JST || (this.JST = {});
this.JST[\"path/to/template\"] = new Hogan.Template({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"<p>This is \");t.b(t.v(t.f(\"hamstache\",c,p,0)));t.b(\"</p>\");return t.fl(); },partials: {}, subs: {  }}, \"\", Hogan, {});
}).call(this);
~.strip
    end

    def test_render_with_lambdas
      HoganAssets::Config.configure do |config|
        config.lambda_support = true
      end

      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
(function() {
this.JST || (this.JST = {});
this.JST[\"path/to/template\"] = new Hogan.Template({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }}, "This is {{mustache}}", Hogan, {});
}).call(this);
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
(function() {
this.JST || (this.JST = {});
this.JST[\"path/to/template\"] = new Hogan.Template({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"<p> This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));t.b(\" </p>\");return t.fl(); },partials: {}, subs: {  }}, "", Hogan, {});
}).call(this);
~.strip
    end

    def test_path_prefix
      HoganAssets::Config.configure do |config|
        config.path_prefix = 'app/templates'
      end

      scope = make_scope '/myapp/app/assets/javascripts', 'app/templates/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
(function() {
this.JST || (this.JST = {});
this.JST[\"template\"] = new Hogan.Template({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }}, "", Hogan, {});
}).call(this);
~.strip
    end

    def test_template_namespace
      HoganAssets::Config.configure do |config|
        config.template_namespace = 'HoganTemplates'
      end

      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
(function() {
this.HoganTemplates || (this.HoganTemplates = {});
this.HoganTemplates[\"path/to/template\"] = new Hogan.Template({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }}, "", Hogan, {});
}).call(this);
~.strip
    end

    def test_strip_namespace_initialization
      HoganAssets::Config.configure do |config|
        config.skip_initialize_namespace = true
      end
      scope = make_scope '/myapp/app/assets/javascripts', 'path/to/template.mustache'

      template = HoganAssets::Tilt.new(scope.s_path) { "This is {{mustache}}" }

      assert_equal template.render(scope, {}), %Q~
(function() {
this.JST[\"path/to/template\"] = new Hogan.Template({code: function (c,p,i) { var t=this;t.b(i=i||\"\");t.b(\"This is \");t.b(t.v(t.f(\"mustache\",c,p,0)));return t.fl(); },partials: {}, subs: {  }}, "", Hogan, {});
}).call(this);
~.strip
    end
  end
end