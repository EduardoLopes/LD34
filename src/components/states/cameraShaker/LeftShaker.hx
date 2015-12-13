package components.states.cameraShaker;

import objects.states.ObjectState;
import components.CameraShaker;

class LeftShaker extends ObjectState {

  var cameraShaker : CameraShaker;

  public function new(CameraShaker : CameraShaker){

    super();

    name = 'left_shaker';
    cameraShaker = CameraShaker;

  }

  override function update(dt:Float):Void{

    cameraShaker.offset.x = Luxe.utils.random.int(-(cameraShaker.force + 1), 0);

  }

}