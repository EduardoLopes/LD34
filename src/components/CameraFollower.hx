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
  var screenSize : Vector;
  var screenMiddle : Vector;
  public static var tweenComplete;
  var zoom : Vector;
  var currentPositionNormal : Vector;

  override function init() {

    camera = cast entity;

    zoom = new Vector(0, 0);
    screenSize = new Vector(0, 0);
    screenMiddle = new Vector(0, 0);
    currentPositionNormal = new Vector();
    onWindowResized();
    follower = null;

    tweenComplete = true;

  }

  public function onWindowResized(){

    var zoom:Float = Math.max(0, Main.zoom - 1);

    screenSize.set_xy(240 * zoom, 135 * zoom);
    screenMiddle.set_xy((Main.gameResolution.x * Main.zoom) / 2, (Main.gameResolution.y * Main.zoom) / 2);

    camera.pos.x = -(screenSize.x / 2);
    camera.pos.y = (currentPositionNormal.y * 80) - screenMiddle.y - (screenSize.y / 2) + 12;

  }

  public function setFollower(Follower : Player){
    follower = Follower;
  }

  override function update(dt:Float):Void {

    if(follower == null) return null;

    var normal = Math.floor(follower.pos.y / 80);

    if(normal != currentPositionNormal.y && follower.onGround){

      Actuate.tween(camera.pos, 0.5, {y: (normal * 80) - screenMiddle.y - (screenSize.y / 2) + 12} )
      .ease(luxe.tween.easing.Quad.easeInOut)
      .onComplete(function(){
        tweenComplete = true;
      })
      .snapping( true );

      currentPositionNormal.y = normal;

    }

  }

}