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


class Laser extends engine.Sprite {

  public var type : CbType;
  public var body : Body;
  public var physics : BodySetup;
  public var core : Shape;

  function new (x:Float, y:Float){

    super({
      name: 'LASER',
      name_unique: true,
      pos: new Vector(x + 8, y + 8),
      size: new Vector(144, 12),
      color: new Color().rgb(0xe0f038),
      depth: 3
    });

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
      CbEvent.BEGIN, InteractionType.SENSOR,
      Main.types.Laser,
      Main.types.Block,
      laserSensor
    ));

    Game.drawer.add(body);

  }

  function laserSensor(cb:InteractionCallback){

    cb.int2.userData.kill();

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

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

  }

}