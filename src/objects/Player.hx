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

  public function new (object:TiledObject, level : Level){

    super({
      pos: new Vector(level.pos.x + object.pos.x, level.pos.y + object.pos.y),
      color: new Color().rgb(0xffffff),
      name: object.name,
      depth: 3.4,
      size: new Vector(16, 16)
    });

    states = new StateMachine();
    states.add( new Jump( this ) );
    states.add( new Walk( this ) );

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

    Luxe.camera.get('follower').setFollower(this);

    add( new TouchingChecker(Main.types.Player, Main.types.Floor) );

    events.listen('onBottom', function(_){
      onGround = true;
      body.setShapeMaterials(Materials.Ground);
    });

    events.listen('offBottom', function(_){
      onGround = false;
      body.setShapeMaterials(Materials.Air);
    });

    events.listen('onSide', function(_){
      onWall = true;
    });

    events.listen('offSide', function(_){
      onWall = false;
    });

    events.listen('onLeft', function(_){
      onLeftWall = true;
    });

    events.listen('offLeft', function(_){
      onLeftWall = false;
    });

    events.listen('onRight', function(_){
      onRightWall = true;
    });

    events.listen('offRight', function(_){
      onRightWall = false;
    });

    body.userData.name = 'player';

    states.set('walk');

  }

  override function ondestroy(){

    events.unlisten('onBottom');
    events.unlisten('offBottom');
    events.unlisten('onSide');
    events.unlisten('offSide');
    events.unlisten('offLeft');
    events.unlisten('onRight');
    events.unlisten('offRight');

    remove('ground_checker');

  }

  override function update(dt:Float) {

    super.update(dt);

    states.update(dt);

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

  }

}
