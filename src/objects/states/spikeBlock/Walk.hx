package objects.states.spikeBlock;

import objects.SpikeBlock;
import nape.phys.BodyType;

class Walk extends ObjectState {

  var walkForce : Float = 100;
  var block : SpikeBlock;
  var direction : Bool = false;

  public function new(Block:SpikeBlock){

    super();

    block = Block;

    name = 'walk';

  }

  override function update(dt:Float):Void{

    super.update(dt);

    if(direction){
      walkForce = 150;
    } else {
      walkForce = -150;
    }

    block.body.velocity.x = walkForce;

  }



  override function onEnter():Void{

    super.onEnter();

    block.body.type = BodyType.DYNAMIC;

    block.events.listen('block-floor_onLeft', function(_){
      direction = !direction;
    });

    block.events.listen('block-floor_onRight', function(_){
      direction = !direction;
    });

    block.events.listen('block-block_collading', function(_){
      direction = !direction;
    });

    block.events.listen('block-block_collading', function(_){
      direction = !direction;
    });

  }

  function flipDirection(_){
    direction = !direction;
  }

  override function onLeave():Void{

    super.onLeave();

    block.events.unlisten('block-floor_onLeft');
    block.events.unlisten('block-floor_onRight');
    block.events.unlisten('block-block_collading');
    block.events.unlisten('block-block_collading');

  }


}