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

      if(block.anim.animation != 'fill_up') {
        block.anim.animation = 'fill_up';
        block.anim.play();
      }

    }
  }



  override function onEnter():Void{

    super.onEnter();

    timer = time;

    block.events.listen('animation.fill_up.end', function(_){

      block.body.velocity.y = jumpForce;
      onGround = false;

      timer = time;

      Luxe.timer.schedule(0.1, function(){

        if(block.anim.animation != 'jump') {
          block.anim.animation = 'jump';
          block.anim.play();
        }

      });



    });

    block.body.type = BodyType.DYNAMIC;

    block.events.listen('block-floor_onBottom', function(_){
      onGround = true;
      block.body.setShapeMaterials(Materials.Ground);

      if(block.anim.animation != 'idle') {
        block.anim.animation = 'idle';
        block.anim.play();
      }

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