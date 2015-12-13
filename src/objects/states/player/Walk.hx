package objects.states.player;

import objects.Player;
import objects.states.ObjectState;

class Walk extends Move {

  public function new(Player:Player){

    super(Player);

    name = 'walk';

  }

  override function update(dt:Float):Void{

    super.update(dt);

    if(Luxe.input.inputpressed('jump') && player.onGround == true){

      machine.set('jump');

    }

    if(Luxe.input.inputpressed('shoot')){
      player.laserUp.shoot();
    }

  }

}