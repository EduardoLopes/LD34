package objects;

import engine.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;

import nape.phys.Body;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.phys.BodyType;
import nape.phys.Material;

import states.Game;

import luxe.importers.tiled.TiledObjectGroup;

import objects.states.StateMachine;
import objects.states.player.Jump;
import objects.states.player.Walk;
import objects.states.player.Move;

import components.BodySetup;
import components.TouchingChecker;

enum FacingDirection {
  LEFT;
  RIGHT;
  NONE;
}

class Player extends Sprite {

  public var body : Body;
  public var physics : BodySetup;
  public var onGround : Bool;
  public var onWall : Bool;
  public var onLeftWall : Bool;
  public var onRightWall : Bool;
  public var facing : FacingDirection;
  /*public var anim : SpriteAnimation;*/
  public var moving : Bool;
  public var canMove: Bool;
  public var core : Shape;
  public var walkForce : Float = 150;

  public var AirMaterial = new Material(0, 0, 1, 2);
  public var GroundMaterial = new Material(0, 3, 1, 2);

  public var states : StateMachine;

  public var laserSides : LaserSides;
  public var laserUp : LaserUp;
  public var anim : SpriteAnimation;

  static public var public_position : Vector;

  public function new (object:TiledObject, level : Level){

    super({
      pos: new Vector(level.pos.x + object.pos.x, level.pos.y + object.pos.y),
      texture: Luxe.resources.texture('assets/images/player.png'),
      name: object.name,
      depth: 3.4,
      size: new Vector(16, 16)
    });

    public_position = new Vector();

    laserSides = new LaserSides(pos.x, pos.y);
    laserUp = new LaserUp(pos.x, pos.y);

    states = new StateMachine();
    states.add( new Jump( this ) );
    states.add( new Walk( this ) );
    states.add( new Move( this ) );

    canMove = true;
    onGround = false;

    facing = FacingDirection.RIGHT;

    physics = add(new BodySetup({
      bodyType: BodyType.DYNAMIC,
      types: [Main.types.Player, Main.types.Movable],
      polygon: Polygon.box(16, 16),
      isBullet: true
    }));

    body = physics.body;
    core = physics.core;

    core.filter.collisionGroup = 1 | 4;
    core.filter.collisionMask = ~4;

    Luxe.camera.get('follower').setFollower(this);

    add( new TouchingChecker('player-floor', Main.types.Player, Main.types.Floor) );

    events.listen('player-floor_onBottom', function(_){
      onGround = true;
      body.setShapeMaterials(Materials.Ground);
    });

    events.listen('player-floor_offBottom', function(_){
      onGround = false;
      body.setShapeMaterials(Materials.Air);
    });

    events.listen('player-floor_onSide', function(_){
      onWall = true;
    });

    events.listen('player-floor_offSide', function(_){
      onWall = false;
    });

    events.listen('player-floor_onLeft', function(_){
      onLeftWall = true;
    });

    events.listen('player-floor_offLeft', function(_){
      onLeftWall = false;
    });

    events.listen('player-floor_onRight', function(_){
      onRightWall = true;
    });

    events.listen('player-floor_offRight', function(_){
      onRightWall = false;
    });

    body.userData.name = 'player';

    var anim_object = Luxe.resources.json('assets/jsons/player_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );

    states.set('walk');

  }

  override public function ondestroy(){

    super.ondestroy();

    states.set('none');

    events.unlisten('player-floor_onBottom');
    events.unlisten('player-floor_offBottom');
    events.unlisten('player-floor_onSide');
    events.unlisten('player-floor_offSide');
    events.unlisten('player-floor_onLeft');
    events.unlisten('player-floor_offLeft');
    events.unlisten('player-floor_onRight');
    events.unlisten('player-floor_offRight');

    laserSides.destroy();
    laserSides = null;
    laserUp.destroy();
    laserUp = null;

    if(body != null){
      Luxe.physics.nape.space.bodies.remove(body);
    }

    body = null;
    core = null;

  }

  override function update(dt:Float) {

    super.update(dt);

    states.update(dt);

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

    public_position.x = pos.x;
    public_position.y = pos.y;

  }

}
