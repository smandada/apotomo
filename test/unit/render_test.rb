require 'test_helper'

class RenderTest < ActionView::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "Rendering a single widget" do
    setup do
      @mum = mouse_mock('mum', :eating)
    end
    
    should "per default display the state content framed in a div" do
      assert_equal '<div id="mum">burp!</div>', @mum.invoke(:eating)
    end
    
    context "with :text" do
      setup do
        @mum.instance_eval { def eating; render :text => "burp!!!"; end }
      end
      
      should "render the :text" do
        assert_equal "burp!!!", @mum.invoke(:eating)
      end
    end
    
    
    context "with :suppress_js" do
      setup do
        @mum.instance_eval do
          def snuggle; render; end
          self.class.send :attr_reader, :suppress_js
        end
      end
      
      should "per default be false" do
        @mum.invoke :eating
        assert !@mum.suppress_js
      end
      
      should "be true when set" do
        @mum.instance_eval do
          def eating; render :suppress_js => true; end
        end
        @mum.invoke :eating
        assert @mum.suppress_js
      end
    end
    
    should "expose its instance variables in the rendered view" do
      @mum = mouse_mock('mum', :educate) do
        def educate
          @who  = "the cat"
          @what = "run away"
          render
        end
      end
      assert_equal 'If you see the cat do run away!', @mum.invoke(:educate)
    end
    
    context "with #emit" do
      context "and :text" do
        setup do
          @mum.instance_eval do
            def squeak
              emit :text => "squeak();"
            end
          end
        end
        
        should "just return the plain :text" do
          assert_equal 'squeak();', @mum.invoke(:squeak)
        end
      end
      
      context "and no options" do
        setup do
          @mum.instance_eval do
            def squeak
              emit
            end
          end
        end
        
        should "render the view" do
          assert_equal "<div id=\"mum\">burp!</div>",  @mum.invoke(:eating)
        end
      end
      
      context "and :view" do
        setup do
          @mum.instance_eval do
            def squeak
              emit :view => :eating
            end
          end
        end
        
        should "render the :view" do
          assert_equal "<div id=\"mum\">burp!</div>", @mum.invoke(:squeak)
        end
      end
    end
    
    context "with #update" do
      setup do
        Apotomo.js_framework = :prototype
      end
      
      should "wrap the :text in an update statement" do
        @mum.instance_eval do
          def squeak
            update :text => "squeak!"
          end
        end
        assert_equal "$(\"mum\").update(\"squeak!\")", @mum.invoke(:squeak)
      end
      
      should "accept :selector" do
        @mum.instance_eval do
          def squeak
            update :text => '<div id="mum">squeak!</div>', :selector => "div#mouse"
          end
        end
        assert_equal "$(\"div#mouse\").update(\"<div id=\\\"mum\\\">squeak!<\\/div>\")", @mum.invoke(:squeak)
      end
    end
    
    context "with #replace" do
      setup do
        Apotomo.js_framework = :prototype
      end
      
      should "wrap the :text in a replace statement" do
        @mum.instance_eval do
          def squeak
            replace :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "$(\"mum\").replace(\"<div id=\\\"mum\\\">squeak!<\\/div>\")", @mum.invoke(:squeak)
      end
      
      should "accept :selector" do
        @mum.instance_eval do
          def squeak
            replace :text => '<div id="mum">squeak!</div>', :selector => "div#mouse"
          end
        end
        assert_equal "$(\"div#mouse\").replace(\"<div id=\\\"mum\\\">squeak!<\\/div>\")", @mum.invoke(:squeak)
      end
    end
  end  
end
