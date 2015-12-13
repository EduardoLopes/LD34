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

    if(player.anim.animation != 'walk' && player.anim.animation != 'shoot') {
      player.anim.animation = 'walk';
      player.anim.play();
    }

    if(Luxe.input.inputpressed('shoot')){

      player.laserUp.body.position.x = player.body.position.x;
      player.laserUp.body.position.y = player.body.position.y;

      player.laserUp.shoot();

      player.anim.animation = 'shoot';
      player.anim.play();

    }

  }

  override function onEnter(){
    super.onEnter();

    player.events.listen('animation.shoot.end', function(_){

      Luxe.timer.schedule(0.1, function(){
        player.anim.animation = 'walk';
        player.anim.play();
      });

    });

  }

}