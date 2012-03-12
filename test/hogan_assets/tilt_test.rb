require 'test_helper'

module HoganAssets
  class TiltTest < Test::Unit::TestCase
    def test_mime_type
      assert_equal 'application/javascript', HoganAssets::Tilt.default_mime_type
    end

    def test_render
      template = HoganAssets::Tilt.new { "This is {{mustache}}" }
      assert_equal template.render(nil, {}),
%Q/new Hogan.Template(function(c,p,i){var _=this;_.b(i=i||\"\");_.b(\"This is \");_.b(_.v(_.f(\"mustache\",c,p,0)));return _.fl();;});/
    end
  end
end
