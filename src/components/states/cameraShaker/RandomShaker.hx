package components.states.cameraShaker;

import objects.states.ObjectState;
import components.CameraShaker;

class RandomShaker extends ObjectState {

  var cameraShaker : CameraShaker;

  public function new(CameraShaker : CameraShaker){

    super();

    name = 'random_shaker';
    cameraShaker = CameraShaker;

  }

  override function update(dt:Float):Void{

    cameraShaker.offset.x = Luxe.utils.random.int(-cameraShaker.force, cameraShaker.force);
    cameraShaker.offset.y = Luxe.utils.random.int(-cameraShaker.force, cameraShaker.force);

  }

}