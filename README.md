#UIMachine

**UIMachine** is a javascript/ruby state-machine decoupled view manager that supports many traditional forms of navigation and works especially well with animations.  UIMachine was purpose built for **Fittr®**  because we mave multiple platforms to support and a view hierarchy during our workouts that is unrepresentable by apple's storyboard system.  That's not to say that UIMachine is a replacement for typical view management systems, (The majority of our iOS client uses Storyboards), but serves a different purpose.  If you're doing a presentation-like application with lots of animations and the occasional user interaction, this might be the right fit for you.

We built **UIMachine** with ruby and uses the [OpalRB](http://opalrb.org) implementation; For those unfamiliar, OpalRB is a ruby implementation ontop of javascript.  UIMachine is written in ruby but exports to a generic single **application.js** file that you interface with.  It has been tested with **WebKit DOM-LESS** runtime.

For those worried about performance or the use of an implementation like OpalRB; rest assured, OpalRB maintains specs that are very rigid and well tested.  These specs very closely follow the MRI standards; we have had very few issues with the implementation.  Performance and size are more of an issue here; we are able to run UIMachine on the iPhone with a typical controller dispatch time of around 2ms which is acceptable; our controllers and actions generally emit events and segues in the range of 10-20 seconds minimum so we are well within our specs; The size of OpalRB is of some concern, our package typically exports at around 480kilo-bytes which is more than we would like but given the niceties of ruby, we are inclined you will agree this is worth it.

## Sessions (Persistant and variable storage)
You should never define global or local variables when defining actions and controllers.  You should always use either 

  - `$_["my_var"]` - **Controller lifetime**
  - `$__["my_var"]` - **Global lifetime**

The controller lifetime is destroyed in the case of ``move_segue`` and ``pop_segue`` for the from controller.  During a ``push_segue`` the from controller's `$_` session is saved and restored during a ``pop_segue``

## Special events

####Server Generated Events
 - segue
 - to_action
 - custom

####Client Generated Events
 - initialize
 - segue_completed
 - tick
 - custom

## Defining a controller and associated actions

Controllers represent one screen in your application.  Typically, this screen may have a few buttons on it, and may have some internal states that it animates between.  Here we are creating a new controller called paperclip.

```ruby
controller "paperclip" do
	on_entry do
		#Declare variables
		$_["n_times_said_something"] = 0     #A variable that will be destroyed when this controller is changed with a move_segue operation
		$__["n_times_shown_paperclip"] += 1  #A variable that is global to the app
		
		#Return information for outgoing segue's toInfo
		{:annoy => true}
  end
end
```

Actions are bound to a specific controller

```ruby
#Notice the connecting # operator.  This means :controller => "paperclip", :action => "default"
action "paperclip#default" do
	on_entry do
		#Declare variables
		# $_["my_variable"] = "test"  #It is not recommended to declar variables here, they have the same scope and lifetime as the controller on_entry and 
		# are not destroyed when this action exits, nor should they be.
		
		#Return additional information to merge with the controller's on_entry
		{:last_opened_document => get_last_opened_document}
	end
	
	#Do something every 1 second, similar to setInterval in javascript
	interval 1 do
		#Send an event to the client with the type "speech"
		send_event "speech", {:say => "It looks like you're trying to save a document"}
	end
	
	#Do something once after 5 seconds
	timeout 5 do
		#Go to the action "annoying_animations" below, this will not call the on_entry of the annoying_animations.
		to_action "annoying_animations"
	end
	
	#React to a client custom event with a type "exit"
	on :exit do
		#Push a modal on top of this controller, this controller will maintain it's session information in $_ although it will be un-accessible to the pushed controller
		push_segue "confirm_dialog"
	end
	
	on :change_character do
		#Move to a different controller, this will destroy $_ and the client should actually remove the controller
		move_segue "hitler"
	end
end

#Define another action
action "paperclip#annoying_animations" do
	on_entry do
		{:animation => get_next_annoying_animation_name}
	end
	
	on :animation_completed do
		to_action "default"
	end
end
```

## Routes

```ruby
#One-to-One route with the associated name and the destination controller and actions
get "overview" => "overview#current_status"
get "completed_breakdown" => "completed_breakdown#start"
get "paused" => "paused#default"
```

## Segue

There are 3 kinds of segues

 - ``move_segue``
 - ``push_segue``
 - ``pop_segue``

The client is expected to transmit back a ``completed_segue`` after completing the given segue.  Failure to do so will result in an exception.
