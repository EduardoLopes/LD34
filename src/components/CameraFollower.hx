package components;

import luxe.Component;

import luxe.Vector;
import luxe.Entity;
import luxe.tween.Actuate;

import luxe.Camera;

import luxe.Rectangle;

class CameraFollower extends Component {

  public var follower : Entity;
  var camera : Camera;
  var screenSize : Vector;
  var screenMiddle : Vector;
  var bounds : Rectangle;
  var tweenComplete : Bool;
  var tweenTarget:Vector;
  var zoom : Vector;

  override function init() {

    camera = cast entity;

    zoom = new Vector(0, 0);
    screenSize = new Vector(0, 0);
    screenMiddle = new Vector(0, 0);
    onWindowResized();
    follower = null;

    tweenTarget = new Vector(0, 0);
    bounds = new Rectangle(0, 0, 0, 0);

    tweenComplete = true;

  }

  public function onWindowResized(){

    var zoom:Float = Math.max(0, Main.zoom - 1);

    screenSize.set_xy(240 * zoom, 135 * zoom);
    screenMiddle.set_xy(((Main.gameResolution.x * (zoom + 1)) / 2), ((Main.gameResolution.y * (zoom + 1)) / 2));

  }

  public function setFollower(Follower : Entity){
    follower = Follower;

    camera.pos.x = follower.pos.x - screenMiddle.x;
    camera.pos.y = follower.pos.y - screenMiddle.y;
  }

  function distance(a:Vector, b:Vector) {
    return Math.sqrt(Math.pow( a.x - b.x, 2) + Math.pow( a.y - b.y, 2));
  };

  public function setBounds(x, y, w, h, tween){

    bounds.set(x, y, w, h);

    tweenComplete = !tween;

    if(tween == true){

      tweenTarget.x = limit_x_bounds();
      tweenTarget.y = limit_y_bounds();

      var dist = distance(camera.pos, tweenTarget);

      dist = Math.min(1, (dist / 80));

      Actuate.tween(camera.pos, 0.8 * dist, {x: tweenTarget.x, y: tweenTarget.y} )
      .ease(luxe.tween.easing.Expo.easeOut)
      .onComplete(function(){
        tweenComplete = true;
      })
      .snapping( true );

    }

  }

  function limit_x_bounds(){

    var bounds_x = bounds.x + camera.get('shaker').offset.x;
    var bounds_w = bounds.w + camera.get('shaker').offset.x;

    return Math.floor(
      Math.max(
        bounds_x - (screenSize.x / 2),
        Math.min(
          camera.pos.x,
          ( bounds_w ) - (screenSize.x / 2) - Main.gameResolution.x
        )
      )
    );

  }

  function limit_y_bounds(){

    var bounds_y = bounds.y + camera.get('shaker').offset.y;
    var bounds_h = bounds.h + camera.get('shaker').offset.y;

    return Math.floor(
      Math.max(
        bounds_y - (screenSize.y / 2),
        Math.min(
          camera.pos.y,
          ( bounds_h ) - (screenSize.y / 2) - Main.gameResolution.y
        )
      )
    );

  }

  override function update(dt:Float) {

    if(follower != null){

      if(tweenComplete == true){

        if(follower.onGround || follower.dashing == true){
          camera.pos.x += ((follower.pos.x - screenMiddle.x) - camera.pos.x) * 0.08;
        }

        if(follower.onGround){
          camera.pos.y += ((follower.pos.y - screenMiddle.y) - camera.pos.y) * 0.08;
        }

      }

    }

    if((bounds.w != 0 || bounds.h != 0) && tweenComplete == true){

      camera.pos.x = limit_x_bounds();
      camera.pos.y = limit_y_bounds();

    }

  }

}