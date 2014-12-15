require 'json'

module UIMachine
  #State machine
  class UIMachine
    def initialize &block
      #A hash of arrays {:state_a => [:state_b, :state_c], :state_b => [:state_q]
      @legal_transitions = {}
      @states = []

      #Active information
      @current_state = nil
      @last_state = nil

      #Event queues for handling data exchange, these contain exactly one UIMachineEvent
      @outbound_queue = nil #Application must read this
      @inbound_queue = nil #We must read this

      instance_eval(&block)
    end

    #Definitions
    ###################################################################################################
    def state name, &block
      @states << name.to_s
    end

    def _verify_statez *statez
      statez = statez.flatten
      if (statez - @states).count != 0
        raise "The state(s), #{(statez - @states).inspect} were not defined as states with 'state :state_name do...'"
      end
    end

    def initial_state state
      state = state.to_s
      _verify_statez state

      @current_state = state
    end

    #Insert transitions
    def transition from, states
      from = from.to_s
      states = states.map{|e| e.to_s}
      _verify_statez(from)
      _verify_statez(states)

      #Add transitions
      @legal_transitions[from] ||= []

      states.each do |state|
        @legal_transitions[from] << state
      end

      #Set a transition as valid if the case is true
    end

    #Lambda expressions that can check if a transition is valid
    def valid_transition? &block
    end
    ###################################################################################################

    ###################################################################################################
    #Cause a transition
    def _goto state
      state = state.to_s
      _verify_statez state

      raise "Going from #{@current_state} => #{state} is not a legal transition" unless @legal_transitions[@current_state].include? state
      @last_state = @current_state
      @current_state = state

      @outbound_queue = {:type => "transition", :from => @last_state, :to => @current_state}
    end
    ###################################################################################################

    ###################################################################################################
    #Process, call this publicaly, it can also return an event in JSON format
    def raise_event json_event
      event = JSON.parse(json_event)

      _goto(@legal_transitions[@current_state].sample)

      out = @outbound_queue
      @outbound_queue = nil
      return out
    end
    ###################################################################################################
  end
end

my_machine = UIMachine::UIMachine.new do
  state :start do
  end

  state :end do
  end

  state :overview do
  end

  state :group_intro do
  end

  state :intra_exercise_rest do
  end

  state :normal_exercise do
  end

  state :weight_input do
  end

  state :paused do
    valid_transition? {|to| to == @last_state}
  end

  state :completed_breakdown do
  end

  state :swap_exercise do
  end

  state :before_transition do
  end

  #Define transitions
  transition :overview, [:group_intro, :paused, :completed_breakdown]
  transition :group_intro, [:intra_exercise_rest, :paused]
  transition :intra_exercise_rest, [:normal_exercise, :paused]
  transition :normal_exercise, [:overview, :intra_exercise_rest, :normal_exercise, :paused]
  transition :weight_input, [:overview, :intra_exercise_rest, :normal_exercise, :weight_input, :paused]
  transition :paused, [:overview, :group_intro, :intra_exercise_rest, :normal_exercise, :weight_input, :completed_breakdown, :swap_exercise]
  transition :completed_breakdown, [:end]
  transition :swap_exercise, [:normal_exercise, :paused]
  transition :start, [:overview]

  #Set the initial state
  initial_state :start
end

puts my_machine.raise_event({}.to_json)
