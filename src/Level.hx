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
import objects.Player;

import states.Game;
import components.CameraFollower;

class Level extends TiledLevel{

  var body : Body;
  var entities : Map<String, engine.Sprite>;
  var level_ID : Int = 0;

  public function new(options:TiledMapOptions){

    super(options);

    entities = new Map();

    body = new Body(BodyType.STATIC);
    body.cbTypes.add(Main.types.Tilemap);
    body.cbTypes.add(Main.types.Floor);

    var collision_polygons = collision_bounds_fitted('collision');
    for(polygon_1 in collision_polygons) {
      body.shapes.add( polygon_1 );
    }

    var one_way_polygons = collision_bounds_fitted('one_way_plataforms');
    for(polygon_2 in one_way_polygons) {
      polygon_2.cbTypes.add(Main.types.OneWay);
      body.shapes.add( polygon_2 );
    }

    body.userData.name = 'tilemap ' + pos.x + '/' + pos.y;

    body.space = Luxe.physics.nape.space;

    loadObjects();

    for( entity in entities ){
      entity.onObjectsLoaded();
    }

    //Game.drawer.add(body);

  }

  public function setID(ID : Int){
    level_ID = ID;
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

  public function update(dt:Float){

    if(pos.y < Luxe.camera.pos.y + Main.gameResolution.y && CameraFollower.tweenComplete == true){
      display({ visible: false, scale:1 });
      clear_quadPackGeometry();
      destroy(true);
      Game.levels.remove(level_ID);
      body.space = null;
      body = null;
      Luxe.events.fire('create_one_level');
    }

  }

}