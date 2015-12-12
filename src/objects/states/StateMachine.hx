package objects.states;

class StateMachine {

  public var currentState : ObjectState;
  public var states:Map<String, ObjectState>;

  public function new(){

    states = new Map<String, ObjectState>();

  }

  public function update(dt:Float):Void{

    if(currentState != null){
      currentState.update(dt);
    }

  }

  public function set(name:String):Void{

    if(currentState != null){
      currentState.onLeave();
    }
    currentState = states.get(name);
    currentState.onEnter();

  }

  public function get(name:String):Dynamic{

    return states.get(name);

  }

  public function add(state:ObjectState):Void{

    states.set(state.name, state);
    states.get(state.name).machine = this;

  }

}