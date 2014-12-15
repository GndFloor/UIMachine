##### UIMachine - A ruby state machine built for working with UI's that have animations
##### Purpose built for Fittr

### UIMachine events (These are all JSON)

 1. Transition
 `{:type => "Transition", :from => "state_a", :to => "state_b", :info => {:group_ui_names => ["Warmup", "Chest"]}}`
   info is optional

### Substates
Substates are embedded states.  For example, a music play may have 3 states, playing, paused, or buffering. These sub-states must be able to return
Enough information to fully reconstruct last states, e.g. blur overlay needs last state

### States
All states have some embedded information that is given on transition entering. This information is actually the entire state's information pool. All future substates, events, etc.
must only alter information in this pool.  Additionally, snapshots of this state's information is made during substate transitions and major transiitons. This snapshot provides
all the necessary information for reconstruction of this state at the time of the transition
