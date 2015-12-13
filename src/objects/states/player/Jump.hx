package objects.states.player;

import objects.Player;

class Jump extends Move {

  var jumps : Float = 1;
  var jumpForce : Float = -300;

  public function new(Player:Player){

    super(Player);

    name = 'jump';

  }

  override function update(dt:Float):Void{

    super.update(dt);

    if(Luxe.input.inputpressed('jump') && jumps == 1 && player.onGround == false){

      player.body.velocity.y = jumpForce;
      jumps--;

    }

    if(player.onGround == true){
      machine.set('walk');
    }

  }

  override function onEnter():Void{

    super.onEnter();

    jumps = 1;
    player.onGround = false;
    player.body.velocity.y = jumpForce;

  }

}