package objects.states.spikeBlock;

import objects.SpikeBlock;
import nape.phys.BodyType;

class Jump extends ObjectState {

  var jumpForce : Float = -300;
  var time : Float = 2;
  var timer : Float;
  var block : SpikeBlock;
  var onGround : Bool = true;

  public function new(Block:SpikeBlock){

    super();

    block = Block;

    name = 'jump';

  }

  override function update(dt:Float):Void{

    super.update(dt);

    timer -= dt;

    if(timer <= 0 && onGround == true){

      block.body.velocity.y = jumpForce;
      onGround = false;

      timer = time;

    }

  }



  override function onEnter():Void{

    super.onEnter();

    timer = time;

    block.body.type = BodyType.DYNAMIC;

    block.events.listen('block-floor_onBottom', function(_){
      onGround = true;
      block.body.setShapeMaterials(Materials.Ground);
    });

    block.events.listen('block-floor_offBottom', function(_){
      onGround = false;
      block.body.setShapeMaterials(Materials.Air);
    });

  }

  override function onLeave():Void{

    super.onLeave();

    block.events.unlisten('block-floor_onBottom');
    block.events.unlisten('block-floor_offBottom');

  }


}