package objects;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.callbacks.CbType;

import nape.callbacks.CbEvent;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;

import luxe.Vector;
import luxe.Color;
import luxe.Text;
import luxe.Rectangle;

import luxe.importers.tiled.TiledObjectGroup;
import luxe.components.sprite.SpriteAnimation;

import states.Game;
import components.BodySetup;
import components.TouchingChecker;

import objects.states.StateMachine;

import components.CameraShaker;


class LaserUp extends engine.Sprite {

  public var type : CbType;
  public var body : Body;
  public var physics : BodySetup;
  public var core : Shape;

  public var shotTime:Float = 0.2;
  public var shotTimer:Float = 0.2;
  public var killTime:Float = 0.08;
  public var killTimer:Float = 0;
  public var anim : SpriteAnimation;

  function new (x:Float, y:Float){

    super({
      name: 'LASER_UP',
      name_unique: true,
      pos: new Vector(x, y),
      size: new Vector(12, 96),
      depth: 3,
      texture: Luxe.resources.texture('assets/images/laser_up.png')
    });

    visible = false;

    type = new CbType();

    physics = add(new BodySetup({
      bodyType: BodyType.KINEMATIC,
      types: [type, Main.types.Laser],
      polygon: Polygon.rect(0, -(size.y + 8) , size.x, size.y)
    }));

    body = physics.body;
    core = physics.core;

    core.sensorEnabled = true;

    body.position.x = pos.x;
    body.position.y = pos.y;

    Luxe.physics.nape.space.listeners.add(new InteractionListener(
      CbEvent.ONGOING, InteractionType.SENSOR,
      type,
      Main.types.Block,
      laserSensor
    ));

    var anim_object = Luxe.resources.json('assets/jsons/laser_up_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );

    events.listen('animation.shoot.end', function(_){

      visible = false;

    });

  }

  function laserSensor(cb:InteractionCallback){

    if(killTimer > 0){
      cb.int2.userData.kill();
      Luxe.camera.get('shaker').shake(ShakeDirection.RANDOM, 0.06, 2);
    };

  }

  public function shoot(){

    pos.x = body.position.x;
    pos.y = body.position.y - 48;

    pos = pos.int();


    if(shotTimer <= 0 && visible == false){

      Luxe.camera.get('shaker').shake(ShakeDirection.RANDOM, 0.06, 1);

      anim.animation = 'shoot';
      anim.play();

      shotTimer = shotTime;
      killTimer = killTime;

      visible = true;

      Luxe.timer.schedule(0.1, function(){
        visible = false;
      });

    }

  }

  override public function ondestroy(){

    super.ondestroy();

    if(body != null){
      Luxe.physics.nape.space.bodies.remove( body );
    }

    body = null;
    core = null;

  }

  override function update(dt:Float){

    shotTimer -= dt;
    killTimer -= dt;

  }

}