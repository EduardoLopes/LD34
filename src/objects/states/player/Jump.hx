package objects.states.player;

import objects.Player;

class Jump extends Move {

  var jumps : Float = 1;
  var jumpForce : Float = -300;
  var animation_end_event_id : String;

  public function new(Player:Player){

    super(Player);

    name = 'jump';

  }

  override function update(dt:Float):Void{

    super.update(dt);

    if(Luxe.input.inputpressed('jump') && jumps == 1){

      player.body.velocity.y = jumpForce;
      jumps--;

    }

    if(player.anim.animation != 'jump' && player.anim.animation != 'shoot') {
      player.anim.animation = 'jump';
      player.anim.play();
    }

    if(Luxe.input.inputpressed('shoot')){
      player.laserSides.body.position.x = player.body.position.x;
      player.laserSides.body.position.y = player.body.position.y;

      player.laserSides.shoot();
      player.anim.animation = 'shoot';

      player.anim.play();
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

    animation_end_event_id = player.events.listen('animation.shoot.end', function(_){

        player.anim.animation = 'jump';
        player.anim.play();

    });

  }

  override function onLeave(){

    super.onLeave();

    player.events.unlisten(animation_end_event_id);

  }

}