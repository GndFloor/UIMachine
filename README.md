##### UIMachine - A ruby state machine built for working with UI's that have animations
##### Purpose built for Fittr

### UIMachine events (These are all JSON)

 1. Transition
 `{:type => "Transition", :from => "state_a", :to => "state_b", :info => {:group_ui_names => ["Warmup", "Chest"]}}`
   info is optional
