package components.states.cameraShaker;

import objects.states.ObjectState;
import components.CameraShaker;

class DownShaker extends ObjectState {

  var cameraShaker : CameraShaker;

  public function new(CameraShaker : CameraShaker){

    super();

    name = 'down_shaker';
    cameraShaker = CameraShaker;

  }

  override function update(dt:Float):Void{

    cameraShaker.offset.y = Luxe.utils.random.int(0, (cameraShaker.force + 1));

  }

}