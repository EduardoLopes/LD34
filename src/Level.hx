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

import objects.Background;

class Level extends TiledLevel{

  var body : Body;
  public var entities : Map<String, engine.Sprite>;

  public function new(options:TiledMapOptions){

    super(options);

    entities = new Map();

    body = new Body(BodyType.STATIC);
    body.cbTypes.add(Main.types.Tilemap);
    body.cbTypes.add(Main.types.Floor);

    var collision_polygons = collision_bounds_fitted('collision');
    for(polygon in collision_polygons) {
      body.shapes.add( polygon );
    }

    var one_way_polygons = collision_bounds_fitted('one_way_plataforms');
    for(polygon in one_way_polygons) {
      polygon.cbTypes.add(Main.types.OneWay);
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