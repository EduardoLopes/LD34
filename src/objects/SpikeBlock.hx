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

class SpikeBlock extends engine.Sprite {

  public var type : CbType;
  public var body : Body;
  public var physics : BodySetup;
  public var core : Shape;

  function new (object:Dynamic, level : Level){

    super({
      name: object.type,
      name_unique: true,
      pos: new Vector(level.pos.x + object.pos.x + 8, level.pos.y + object.pos.y + 8),
      size: new Vector(16, 16),
      texture: Luxe.resources.texture('assets/images/spike_block.png'),
      depth: 3
    });

    type = new CbType();

    physics = add(new BodySetup({
      bodyType: BodyType.STATIC,
      types: [type, Main.types.Floor],
      polygon: Polygon.box(16, 16)
    }));

    body = physics.body;
    core = physics.core;

    body.position.x = pos.x;
    body.position.y = pos.y;

  }

  override function update(dt:Float){


  }

}