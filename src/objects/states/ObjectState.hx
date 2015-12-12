package objects.states;

class ObjectState {

  public var name:String;
  public var machine:StateMachine;

  public function new(){}

  public function update(dt:Float):Void{}

  public function onEnter():Void{}

  public function onLeave():Void{}

}