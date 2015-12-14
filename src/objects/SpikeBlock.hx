package objects;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.callbacks.CbType;

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
import objects.states.spikeBlock.Jump;
import objects.states.spikeBlock.Walk;


class SpikeBlock extends engine.Sprite {

  public var type : CbType;
  public var body : Body;
  public var physics : BodySetup;
  public var core : Shape;
  public var states : StateMachine;
  public var onGround : Bool;
  public var anim : SpriteAnimation;
  public var invencible : Bool = false;


  function new (object:Dynamic, level : Level){

    super({
      name: object.type,
      name_unique: true,
      pos: new Vector(level.pos.x + object.pos.x + 8, level.pos.y + object.pos.y + 8),
      size: new Vector(16, 16),
      texture: Luxe.resources.texture('assets/images/spike_block.png'),
      depth: 3
    });

    if(Luxe.utils.random.bool(0.5)){

      texture = Luxe.resources.texture('assets/images/spike_block_2.png');
      invencible = true;

    }

    states = new StateMachine();
    states.add( new Jump( this ) );
    states.add( new Walk( this ) );

    type = new CbType();

    physics = add(new BodySetup({
      bodyType: BodyType.DYNAMIC,
      types: [type, Main.types.Floor, Main.types.Block],
      polygon: Polygon.box(16, 16)
    }));

    body = physics.body;
    core = physics.core;

    body.userData.kill = kill;

    body.position.x = pos.x;
    body.position.y = pos.y;

    add( new TouchingChecker('player-block', Main.types.Player, type) );
    add( new TouchingChecker('block-floor', type, Main.types.Floor) );
    add( new TouchingChecker('block-block', type, type) );

    events.listen('player-block_collading', function(_){
      Main.state.set('game');
    });

    if(object.properties.get('state') != null){
      states.set( object.properties.get('state') );
    }

    var anim_object = Luxe.resources.json('assets/jsons/block_spike_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );
    anim.animation = 'idle';
    anim.play();

    events.listen('animation.dead.end', function(_){

      visible = false;

      destroy();


    });

  }

  public function kill(){

    if(invencible == false){
      anim.animation = 'dead';
      anim.play();

      states.set('none');
    }


  };

  override public function ondestroy(){

    if(this.geometry != null) this.geometry.drop(true);

    if(has('player-block')){
      remove('player-block');
    }

    if(has('block-floor')){
      remove('block-floor');
    }

    if(has('block-block')){
      remove('block-block');
    }

    super.ondestroy();

    if(body != null){
      Luxe.physics.nape.space.bodies.remove( body );
    }
    body = null;
    core = null;

    states.set('none');

  }

  override function update(dt:Float){

    states.update(dt);

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

  }

}