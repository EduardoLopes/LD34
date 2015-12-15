package objects.states.player;

import objects.Player;
import objects.states.ObjectState;

class Walk extends Move {

  var animation_end_event_id : String;

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

    animation_end_event_id = player.events.listen('animation.shoot.end', function(_){

      player.anim.animation = 'walk';
      player.anim.play();

    });

  }

  override function onLeave(){

    super.onLeave();

    player.events.unlisten(animation_end_event_id);

  }

}