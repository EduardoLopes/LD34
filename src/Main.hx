
import luxe.Input;
import luxe.Camera;
import luxe.Color;
import luxe.Vector;
import luxe.Screen;

import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.States;

import phoenix.Texture;

import components.CameraFollower;
import components.CameraShaker;

import states.Game;

class Main extends luxe.Game {

  public static var zoom : Int = 1;
  public static var pressingGamepadLeft : Bool;
  public static var pressingGamepadRight : Bool;
  public static var gameResolution : Vector;
  public static var zoomRatio : Vector;
  public static var backgroundBatcher : phoenix.Batcher;
  public static var foregroundBatcher : phoenix.Batcher;
  public static var backgroundBatcherCamera : Camera;
  public static var foregroundBatcherCamera : Camera;
  public static var types : Types;
  public static var state: States;
  public static var materials : Materials;

  override function config(config:luxe.AppConfig) {

    gameResolution = new Vector(config.window.width, config.window.height);

    config.window.width = config.window.width * zoom;
    config.window.height = config.window.height * zoom;

    return config;

  } //config

  override function ready() {

    var parcel = new Parcel({
      fonts : [
        { id:'assets/fonts/font.fnt' },
      ],
      jsons : [
        { id : 'assets/jsons/block_spike_animation.json' },
        { id : 'assets/jsons/laser_sides_animation.json' },
        { id : 'assets/jsons/laser_up_animation.json' },
        { id : 'assets/jsons/player_animation.json' }
      ],
      texts : [
        {id : 'assets/maps/map_0.tmx'},
        {id : 'assets/maps/map_1.tmx'},
        {id : 'assets/maps/map_2.tmx'},
        {id : 'assets/maps/map_3.tmx'},
        {id : 'assets/maps/map_4.tmx'},
        {id : 'assets/maps/map_5.tmx'},
        {id : 'assets/maps/map_6.tmx'},
        {id : 'assets/maps/map_7.tmx'},
        {id : 'assets/maps/map_8.tmx'},
        {id : 'assets/maps/map_9.tmx'},
        {id : 'assets/maps/map_10.tmx'},
        {id : 'assets/maps/map_11.tmx'},
        {id : 'assets/maps/map_12.tmx'},
        {id : 'assets/maps/map_13.tmx'},
        {id : 'assets/maps/map_14.tmx'},
        {id : 'assets/maps/map_15.tmx'},
        {id : 'assets/maps/map_16.tmx'},
        {id : 'assets/maps/map_17.tmx'},
        {id : 'assets/maps/map_18.tmx'},
        {id : 'assets/maps/map_19.tmx'},
        {id : 'assets/maps/map_20.tmx'},
        {id : 'assets/maps/map_21.tmx'},
        {id : 'assets/maps/map_22.tmx'},
        {id : 'assets/maps/map_23.tmx'},
        {id : 'assets/maps/map_24.tmx'},
        {id : 'assets/maps/map_25.tmx'},
        {id : 'assets/maps/map_26.tmx'},
        {id : 'assets/maps/map_27.tmx'}
      ],
      textures : [
        {id : 'assets/images/collision-tile.png'},
        {id : 'assets/images/tiles.png'},
        {id : 'assets/images/spike_block.png'},
        {id : 'assets/images/spike_block_2.png'},
        {id : 'assets/images/laser_sides.png'},
        {id : 'assets/images/laser_up.png'},
        {id : 'assets/images/background_1.png'},
        {id : 'assets/images/background_2.png'},
        {id : 'assets/images/player.png'}
      ],
      sounds : []
    });

    phoenix.Texture.default_filter = FilterType.nearest;

    new ParcelProgress({
      parcel      : parcel,
      background  : new Color(1,1,1,0.85),
      oncomplete  : onLoaded
    });

    zoomRatio = new Vector(Luxe.screen.w / gameResolution.x, Luxe.screen.h / gameResolution.y);

    backgroundBatcherCamera = new Camera({
      name: 'background_camera'
    });

    foregroundBatcherCamera = new Camera({
      name: 'foreground_camera'
    });

    backgroundBatcher = Luxe.renderer.create_batcher({
      layer: -1,
      name:'background_batcher',
      camera: backgroundBatcherCamera.view
    });

    foregroundBatcher = Luxe.renderer.create_batcher({
      layer: 3,
      name:'foreground_batcher',
      camera: foregroundBatcherCamera.view
    });

    state = new States({ name:'state' });
    state.add( new Game() );

    types = new Types();
    materials = new Materials();

    Luxe.camera.add(new CameraShaker({name: 'shaker'}));
    Luxe.camera.add(new CameraFollower({name: 'follower'}));



    parcel.load();

  } //ready

  function onLoaded(_){

      update_camera_scale();

    state.set('game');

  }

  override function ongamepadaxis( event:GamepadEvent ) {

    var dead = 0.21;

    if((event.value > dead && (event.value > 0 && event.value <= 1 )) || (event.value < -dead && (event.value < 0 && event.value <= 1)) ) {

      if(event.axis == 0) {

        pressingGamepadLeft = false;
        pressingGamepadRight = false;

        if(event.value < 0) pressingGamepadLeft = true;
        if(event.value > 0) pressingGamepadRight = true;
      }

    } else {

      if(event.axis == 0) {
        pressingGamepadLeft = false;
        pressingGamepadRight = false;
      }

    }

    if(event.axis == 1){

      /*up/down buttons*/

    }

  }

  function update_camera_scale(){

    zoomRatio.x = Math.floor(Luxe.screen.w / gameResolution.x);
    zoomRatio.y = Math.floor(Luxe.screen.h / gameResolution.y);

    zoom = Math.floor(Math.max(1, Math.min(zoomRatio.x, zoomRatio.y)));

    var width = gameResolution.x * zoom;
    var height = gameResolution.y * zoom;
    var x = (Luxe.screen.w / 2) - (width / 2);
    var y = (Luxe.screen.h / 2) - (height / 2);

    Luxe.camera.viewport.set(x, y, width, height);
    backgroundBatcherCamera.viewport.set(x, y, width, height);
    foregroundBatcherCamera.viewport.set(x, y, width, height);

    Luxe.camera.get('follower').onWindowResized();

  }

  override function onwindowsized( e:WindowEvent ):Void {

    update_camera_scale();

  }

  override function onkeyup( e:KeyEvent ) {

    if(e.keycode == Key.escape) {
      Luxe.shutdown();
    }

  } //onkeyup

  override function update(dt:Float) {

  } //update


} //Main
