package;

import engine.TiledLevel;

import luxe.options.TilemapOptions;
import luxe.importers.tiled.TiledMap;
import luxe.Entity;
import luxe.Vector;
import luxe.Color;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

class Level extends TiledLevel{

  var body : Body;
  public var entrances : Map<String, MapEntrance>;
  public var entities : Map<String, engine.Sprite>;

  public function new(options:TiledMapOptions){

    super(options);

    entities = new Map();
    entrances = new Map();

    body = new Body(BodyType.STATIC);
    body.cbTypes.add(Main.types.Tilemap);
    body.cbTypes.add(Main.types.Floor);

    var polygons = collision_bounds_fitted();
    for(polygon in polygons) {
      body.shapes.add( polygon );
    }

    body.space = Luxe.physics.nape.space;

    loadObjects();

    for( entity in entities ){
      entity.onObjectsLoaded();
    }

  }

  function loadObjects(){

    for(objectsLayer in tiledmap_data.object_groups){
      for(object in objectsLayer.objects){

        entities.set( object.name, Type.createInstance( Type.resolveClass( 'objects.'+object.type ), [object, this] ) );

      }
    }

    for(layer in tiledmap_data.image_layers) {

      var background = new Background(layer, this);
      entities.set(background.name, background);

    }

  }

}