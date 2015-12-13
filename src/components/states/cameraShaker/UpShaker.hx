package components.states.cameraShaker;

import objects.states.ObjectState;
import components.CameraShaker;

class UpShaker extends ObjectState {

  var cameraShaker : CameraShaker;

  public function new(CameraShaker : CameraShaker){

    super();

    name = 'up_shaker';
    cameraShaker = CameraShaker;

  }

  override function update(dt:Float):Void{

    cameraShaker.offset.y = Luxe.utils.random.int(-(cameraShaker.force + 1), 0);

  }

}