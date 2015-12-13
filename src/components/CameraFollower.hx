package components;

import luxe.Component;

import luxe.Vector;
import objects.Player;
import luxe.tween.Actuate;

import luxe.Camera;

import luxe.Rectangle;

class CameraFollower extends Component {

  public var follower : Player;
  var camera : Camera;
  public static var cameraOffset : Vector;
  public static var screenMiddle : Vector;
  public static var tweenComplete;
  var zoom : Vector;
  public static var currentPositionNormal : Vector;

  override function init() {

    camera = cast entity;

    zoom = new Vector(0, 0);
    cameraOffset = new Vector(0, 0);
    screenMiddle = new Vector(0, 0);
    currentPositionNormal = new Vector();
    onWindowResized();
    follower = null;

    tweenComplete = true;

  }

  public function onWindowResized(){

    var zoom:Float = Math.max(0, Main.zoom - 1);

    cameraOffset.set_xy(Main.gameResolution.x * zoom, Main.gameResolution.y * zoom);
    screenMiddle.set_xy(((Main.gameResolution.x * Main.zoom) / 2), ((Main.gameResolution.y * Main.zoom) / 2));

    camera.pos.x = -(cameraOffset.x / 2);
    camera.pos.y =  (currentPositionNormal.y * 80) - screenMiddle.y;

    Main.backgroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.backgroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);
    Main.foregroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.foregroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);

  }

  public function resetCamera(){

    camera.pos.x = -(cameraOffset.x / 2);
    camera.pos.y =  (Math.floor(follower.pos.y / 80) * 80) - screenMiddle.y;

    currentPositionNormal.y = Math.floor(follower.pos.y / 80);

    Actuate.stop(camera.pos);
  }

  public function setFollower(Follower : Player){

    follower = Follower;

  }

  override function update(dt:Float):Void {

    if(follower == null) return null;

    var normal = Math.floor(follower.pos.y / 80);

    if(normal != currentPositionNormal.y && follower.onGround){

      Actuate.stop(camera.pos);

      Actuate.tween(camera.pos, 0.5, {y: (normal * 80) - screenMiddle.y} )
      .ease(luxe.tween.easing.Quad.easeInOut)
      .onComplete(function(){
        tweenComplete = true;
      })
      .snapping( true );

      currentPositionNormal.y = normal;

    }

  }

}