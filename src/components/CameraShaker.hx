package components;

import luxe.Component;
import luxe.Camera;

import luxe.Vector;

import objects.states.StateMachine;

import components.states.cameraShaker.LeftShaker;
import components.states.cameraShaker.UpShaker;
import components.states.cameraShaker.RightShaker;
import components.states.cameraShaker.DownShaker;
import components.states.cameraShaker.RandomShaker;

enum ShakeDirection{
  LEFT;
  UP;
  RIGHT;
  DOWN;
  RANDOM;
}

class CameraShaker extends Component {

  var camera : Camera;
  var initialPos : Vector;
  var states : StateMachine;
  public var offset : Vector;
  public var amount : Float;
  public var force : Int;

  override function init() {

    camera = cast entity;


    offset = new Vector(0,0);
    initialPos = new Vector(camera.pos.x, camera.pos.y);
    amount = 0;
    force = 0;

    states = new StateMachine();

    states.add( new LeftShaker(this) );
    states.add( new UpShaker(this) );
    states.add( new RightShaker(this) );
    states.add( new DownShaker(this) );
    states.add( new RandomShaker(this) );

  }

  public function shake(direction:ShakeDirection, Amount:Float, Force:Int){

    cancel();

    amount = Amount;
    force = Force;

    switch direction {
      case ShakeDirection.LEFT: states.set('left_shaker');
      case ShakeDirection.UP: states.set('up_shaker');
      case ShakeDirection.RIGHT: states.set('right_shaker');
      case ShakeDirection.DOWN: states.set('down_shaker');
      case ShakeDirection.RANDOM: states.set('random_shaker');
    }

  }

  public function cancel(){

    camera.pos.x -= offset.x;
    camera.pos.y -= offset.y;

    amount = 0;
    force = 0;

    offset.x = 0;
    offset.y = 0;

    states.currentState = null;

  }

  override function update(dt:Float) {

    if(amount >= 0){

      camera.pos.x -= offset.x;
      camera.pos.y -= offset.y;

      states.update(dt);

      camera.pos.x += offset.x;
      camera.pos.y += offset.y;

    } else {

      cancel();

    }

    amount -= dt;

  }

}