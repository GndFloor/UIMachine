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

#### Implementation guarantees
All implementations must be able to guarantee that they are able to support all valid transitions.  The implementation will be given both a snapshot of the last state immediately before the transition took place, and the previous transition, (n-2), and some location of the current state. Upon restoring, there are no guarentees on the values of the current state, however, the last state's snapshot will still be available.  This is to support blur overviews, and in general, dialog based views.\

In the event you have something like a blurred modal view that has the possibility of unwinding to a different view than the last view, you may want to implement this by having two code paths.  One code path will be in the case that a restored state carries the same hash information, and therefore, can be considiered a simple de-blurring event. In the other event, the backing blur view will need to be trashed.

#### Non-snapshotable
A -> M1 -> M2 -> M1 -> M2 -> M1              [A -> M1]    A -> M1 -> M2
Recovering to a previous state will be seen as a pop animation...

A
A -> M1
A -> M1 -> M2
A -> M1

Transitions that revert back to previous states are assumed to be "Back" states.  The history timeline will not be constructed like 

A -> M1 -> M2 -> M1 but rather A -> M1

A -> B -> C -> B => N-2 -> A -> B
A -> B -> C => A -> B -> C
