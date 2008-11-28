# Copyright (c) 2008 Peter Houghton 
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.


require 'rubygems'
require 'test/unit'
require 'errfix'


class BSM__tests < Test::Unit::TestCase

	def setup
    # no setup
	end # end setup

 
  # Define a simple model with guarded transitions
  # Check guard itself
  #
	def test_guarded_simple_dsl
 		smc = StateModelCreator.new
    smc.define_action :action1 do
      @done_action1 = true
    end # end action
    
    smc.define_action :action2 do
      @done_action2 = true
    end # end action
    
    smc.define_guard_on :action2 do
      if @done_action1 && !@done_action2
        guard=true
      else
        guard=false
      end # end if   
      guard
    end # end guard
      
  	smc.attach_transition(:STATEA,:action1,:STATEB)
  	smc.attach_transition(:STATEB,:action2,:STATEA)
      
    sm = smc.state_machine 

    assert(sm.guarded_actions.include?(:action2) , "Check action2 is identified as being guarded")
    assert(!sm.guarded_actions.include?(:action1) , "Check action1 is identified as not being guarded")
    
    assert_equal(false , sm._guard_on_action2, "check guard returns false as default")
     
    # Create the Graphiz graph object, see if it fails...
  	sm_graph = sm.create_dot_graph	
  	sm_graph.output("../test/test_guard_dsl_1.dot")
  	
 		# Check standard length walk
 		#the_walk = sm.random_walk(:STATEA)
 		sm.state=:STATEA
 		assert_equal(:STATEB , sm.action1 , "Check at StateB")
 		assert_equal(true , sm._guard_on_action2 , "Check Guard returns correct value")
      
	end # end test
 	
 	
 	# Define a model with guarded transitions.
 	# Check it is correctly navigated,
 	#
 	def test_random_walk_guarded_complex_dsl
 	  
 		smc = StateModelCreator.new
 		smc.define_action :click_home
 		smc.define_action :view_content

 		smc.define_guard_on :view_content do
 		  # You can only view content if you are logged in.
 		  if @logged_in
 		      guard=true
		  else
		      guard=false
		  end # end if else
		  guard
		end # end guard

    smc.define_guard_on :click_log_in do
      # You can't log in if you are already logged in.
      if @logged_in
 		    guard=false
		  else
		    guard=true
		  end # end if else
		  guard
    end # end guard

    smc.define_action :click_log_in do
      @logged_in=true
    end # end action
    
    smc.define_action :show_more 
    
 		smc.attach_transition(:HOME,:view_content,:SHOWING_CONTENT)
 		smc.attach_transition(:SHOWING_CONTENT,:show_more,:MORE_CONTENT)
 		smc.attach_transition(:HOME,:click_log_in,:LOG_IN_COMPLETE)
 		smc.attach_transition(:LOG_IN_COMPLETE,:click_home,:HOME)
 		
 		sm = smc.state_machine
 		
    # Create the Graphiz graph object, see if it fails...
	  sm_graph = sm.create_dot_graph	
	  sm_graph.output("../test/test_guard_dsl_2.dot")
    
    assert_equal(3 , sm.states_store.length , "Check for 3 states")

 		# Check standard length walk
 		the_walk = sm.random_walk(:HOME)
 		assert_equal(Walk.new.class ,               the_walk.class ,    "Check random walk returns Walk instance" )
 		
 		# When guards are in place, walk cn only be length 3
 		assert_equal(3 ,the_walk.transitions.length , "Check Walk is length 3")
 	
 	end # end


  
	def teardown
	end # end teardown/clearup
	
end # end class

