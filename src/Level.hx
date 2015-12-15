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

import objects.SpikeBlock;
import objects.Player;



class Level extends TiledLevel{

  var body : Body;
  var entities : Map<String, engine.Sprite>;
  var level_ID : Int;
  static public var spike_blockID = 0;
  public var destroyed : Bool = false;

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

  }

  public function setID(ID : Int){
    level_ID = ID;

  }

  function loadObjects(){

    for(objectsLayer in tiledmap_data.object_groups){
      for(object in objectsLayer.objects){

        switch object.type {
          case 'SpikeBlock':

            var block = new SpikeBlock(object, this);
            entities.set( block.name, block );

          case 'Player':
            Game.player = new Player(object, this);

        }

      }
    }

    for(layer in tiledmap_data.image_layers) {

      var background = new Background(layer, this);
      entities.set(background.name, background);

    }

  }

  public function clear(){

    destroyed = true;

    for( entity in entities ){

      entity.destroy();
      entity = null;

    }

    if(body != null){
      Luxe.physics.nape.space.bodies.remove( body );
    }

    clear_quadPackGeometry();
    Game.levels.set(level_ID, null);
    Game.levels.remove(level_ID);

    destroy(true);
    body = null;

  }

  public function update(dt:Float){

    if(CameraFollower.currentPositionNormal.y < -2 && Math.abs(CameraFollower.currentPositionNormal.y) - 3 == level_ID){

      Luxe.events.fire('create_level');
      clear();

    }

  }

}