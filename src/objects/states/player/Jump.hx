package objects.states.player;

import objects.Player;

class Jump extends Walk {

  var jumps : Float = 1;

  public function new(Player:Player){

    super(Player);

    name = 'jump';

  }

  override function update(dt:Float):Void{

    super.update(dt);

    if(Luxe.input.inputpressed('jump') && jumps == 1 && player.onGround == false){

      player.body.velocity.y = -200;
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
    player.body.velocity.y = -200;

  }

}