package engine;

import luxe.importers.tiled.TiledMap;
import luxe.tilemaps.Tilemap;
import luxe.options.TilemapOptions;

import luxe.Rectangle;

import nape.shape.Polygon;

import luxe.Log.*;

import phoenix.geometry.QuadPackGeometry;

class TiledLevel extends TiledMap{

  var collision_layer_id : Int;
  var geom : Map<String, QuadPackGeometry>;

  public function new(options:TiledMapOptions){

    super(options);

    geom = new Map();

  }

  override  public function display( options:TilemapVisualOptions ):Void {

    for( layer in layers ) {

      if(layer.name != 'collision'){

        var _map_scaled_tw = tile_width*options.scale;
        var _map_scaled_th = tile_height*options.scale;

        var tileset = tileset_from_id( 5 );

        if(geom.get(layer.name) == null){

          geom.set(
            layer.name,

            new phoenix.geometry.QuadPackGeometry({
              visible : layer.visible,
              texture : (tileset != null) ? tileset.texture : null,
              depth : (layer.properties.get('depth') != null) ? Std.parseInt( layer.properties.get('depth') ) : 1,
              batcher : (options.batcher != null) ? options.batcher : Luxe.renderer.batcher,
            })
          );

          geom.get(layer.name).locked = true;
          geom.get(layer.name).texture.filter_min = geom.get(layer.name).texture.filter_mag = phoenix.Texture.FilterType.nearest;

        }

        var _scaled_tilewidth = tileset.tile_width*options.scale;
        var _scaled_tileheight = tileset.tile_height*options.scale;

        var _offset_x = 0;
        var _offset_y = _scaled_tileheight - _map_scaled_th;

        for( y in 0 ... height ) {
          for( x in 0 ... width ) {

            var tile = layer.tiles[y][x];

            if(tile.id != 0) {

              var image_coord = tileset.pos_in_texture( tile.id );

              var map_x = x * tileset.tile_width;
              var map_y = y * tileset.tile_height;

              var _quad = geom.get(layer.name).quad_add({
                x: pos.x + (tile.x * _map_scaled_tw) - (_offset_x),
                y: pos.y + (tile.y * _map_scaled_th) - (_offset_y),
                w: _scaled_tilewidth,
                h: _scaled_tileheight
              });

              geom.get(layer.name).quad_uv(_quad, new Rectangle(
                  tileset.margin + ((image_coord.x * tileset.tile_width) + (image_coord.x * tileset.spacing)),
                  tileset.margin + ((image_coord.y * tileset.tile_height) + (image_coord.y * tileset.spacing)),
                  tileset.tile_width,
                  tileset.tile_height
                 )
              );

              geom.get(layer.name).quad_flipx(_quad, tile.flipx);
              geom.get(layer.name).quad_flipy(_quad, tile.flipy);

            }

          } //for each tile
        } //for each row

      }

    }

  } //display

  override function _load_layers( options:TiledMapOptions ):Void {

      var layer_index : Int = 0;
      for(_layer in tiledmap_data.layers) {

        var _layer_properties:Map<String,String> = new Map();

        for(_prop in _layer.properties.keys()) {
          _layer_properties.set(_prop, _layer.properties.get(_prop));
        }

            //add the layer
        add_layer({
          name : _layer.name,
          layer : layer_index,
          opacity : _layer.opacity,
          visible : _layer.visible,
          properties : _layer_properties,
        });

        if(_layer.name == 'collision'){
          collision_layer_id = layer_index;
          return;
        }

        //create the tiles
        add_tiles_fill_by_id( _layer.name, 0 );

            //Now we iterate the layer and store the tiles id's
        var tilemap_layer : TileLayer = layers.get(_layer.name);
        var _gid_counter : Int = 0;

        for(_y in 0 ... _layer.height) {
          for(_x in 0 ... _layer.width) {

            var _layer_tile = _layer.tiles[_gid_counter];

            if(_layer_tile.id != 0) {
              var tile = tilemap_layer.tiles[_y][_x];
              tile.id = _layer_tile.id;
              tile.flipx = _layer_tile.flip_horizontal;
              tile.flipy = _layer_tile.flip_vertical;
              if(_layer_tile.flip_diagonal) {
                tile.angle = 90;
                tile.flipx = !tile.flipx;
              }
            }

            _gid_counter++;

          } //for x
        } //for y

        //increment the index
        layer_index++;

      } //for each layer

  } //load_layers

  public function collision_tile_at(x:Int, y:Int){

    if( tiledmap_data.layers[collision_layer_id] != null ) {

      if( tiledmap_data.layers[collision_layer_id].tiles[y * tiledmap_data.width + x] != null ){

        return tiledmap_data.layers[collision_layer_id].tiles[y * tiledmap_data.width + x];

      }

    }

    return null;

  }

  public function clear_quadPackGeometry() {

/*    for( g in geom.iterator() ){
      g.clear();
    }*/

  }

  public function collision_bounds_fitted():Array<Polygon> {

    var checked:Array<Null<Bool>> = [];
    var rectangles:Array<Polygon> = [];
    var startCol = -1;
    var index = -1;
    var tileID = -1;
    var width = width;
    var height = height;

    for(y in 0...height) {
      for(x in 0...width) {

        index = y * width + x;
        tileID = tiledmap_data.layers[collision_layer_id].tiles[index].id;

        if(tileID > 0 && (checked[index] == false || checked[index] == null)) {

          if(startCol == -1) {
            startCol = x;
          }

          checked[index] = true;

        } else if(tileID == 0 || checked[index] == true) {

          if(startCol != -1) {
            rectangles.push(find_bounds_rect(y, startCol, x, checked));
            startCol = -1;
          }

        }

      } //x in 0...width

      if(startCol != -1) {
        rectangles.push(find_bounds_rect(y, startCol, width, checked));
        startCol = -1;
      }

    } //each row

    return rectangles;

  } //bounds_fitted

    /** Finds the largest bounding rect around tiles with id > 0 between start_x and end_x, starting at start_y and going down as far as possible */
  function find_bounds_rect(start_y:Int, start_x:Int, end_x:Int, checked:Array<Null<Bool>>) {

    var index = -1;
    var tileID = -1;
    var width = width;
    var height = height;

    for(y in (start_y + 1)... height){
      for(x in start_x...end_x) {

        index = y * width + x;

        tileID = tiledmap_data.layers[collision_layer_id].tiles[index].id;

        if(tileID == 0 || checked[index] == true){

          //Set everything we've visited so far in this row to false again because it won't be included in the rectangle and should be checked again
          for(_x in start_x...x) {
              index = y * width + _x;
              checked[index] = false;
          }

          return new Polygon( Polygon.rect( start_x * tile_width, start_y * tile_height, (end_x - start_x) * tile_width, (y - start_y) * tile_height) );

        }

        checked[index] = true;

      } //each x
    } //each y

    return new Polygon( Polygon.rect(start_x * tile_width, start_y * tile_height, (end_x - start_x) * tile_width, (height - start_y) * tile_height) );

  } //find_bounds_rect

}

