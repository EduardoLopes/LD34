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


class LaserSides extends engine.Sprite {

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
      name: 'LASER_SIDES',
      name_unique: true,
      pos: new Vector(x, y),
      size: new Vector(144, 12),
      depth: 3,
      texture: Luxe.resources.texture('assets/images/laser_sides.png'),
    });



    visible = false;

/*  states = new StateMachine();
    states.add( new Jump( this ) );
    states.add( new Walk( this ) );*/

    type = new CbType();

    physics = add(new BodySetup({
      bodyType: BodyType.KINEMATIC,
      types: [type, Main.types.Laser],
      polygon: Polygon.box(size.x, size.y)
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

    var anim_object = Luxe.resources.json('assets/jsons/laser_sides_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );

    events.listen('animation.shoot.end', function(_){

      visible = false;

    });


  }

  function laserSensor(cb:InteractionCallback){

    if(killTimer > 0){
      cb.int2.userData.kill();
    };

  }

  public function shoot(){

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

    if(shotTimer <= 0 && visible == false){

      anim.animation = 'shoot';
      anim.play();

      shotTimer = shotTime;
      killTimer = killTime;

      visible = true;

    }

  }

  override public function ondestroy(){

    if(this.geometry != null) this.geometry.drop(true);

    super.ondestroy();

    Game.drawer.remove(body);

    if(body != null){
      Luxe.physics.nape.space.bodies.remove( body );
    }
    body = null;
    core = null;

    //clean up state events
    //states.set('none');

  }

  override function update(dt:Float){

    shotTimer -= dt;
    killTimer -= dt;

  }

}