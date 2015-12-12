package objects.states.player;

import objects.Player;
import objects.states.ObjectState;

class Walk extends ObjectState {

  var player : Player;

  public function new(Player:Player){

    super();

    name = 'walk';
    player = Player;

  }

  override function update(dt:Float):Void{

    super.update(dt);

    if(player.onRightWall){
      player.walkForce = 150;
    }

    if(player.onLeftWall){
      player.walkForce = -150;
    }

    player.body.velocity.x = player.walkForce;

    if(Luxe.input.inputpressed('jump') && player.onGround == true){

      machine.set('jump');

    }

  }

}