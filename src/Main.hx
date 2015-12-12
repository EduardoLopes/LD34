
import luxe.Input;
import luxe.Camera;
import luxe.Color;
import luxe.Vector;
import luxe.Screen;

import luxe.Parcel;
import luxe.ParcelProgress;

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

  override function config(config:luxe.AppConfig) {

    return config;

  } //config

  override function ready() {

    var parcel = new Parcel({
      fonts : [],
      jsons : [],
      texts : [],
      textures : [],
       sounds : []
    });

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

  } //ready

  function onLoaded(_){

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

  override function onwindowsized( e:WindowEvent ):Void {

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

  }

  override function onkeyup( e:KeyEvent ) {

    if(e.keycode == Key.escape) {
      Luxe.shutdown();
    }

  } //onkeyup

  override function update(dt:Float) {

  } //update


} //Main
