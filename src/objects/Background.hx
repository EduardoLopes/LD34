 package objects;

import engine.Sprite;
import luxe.Vector;
import luxe.importers.tiled.TiledImageLayer;

import phoenix.Texture.ClampType;

class Background extends engine.Sprite {

  public var scroll:Vector = new Vector(0,0);
  public var scrollVelocity:Vector = new Vector(0,0);
  public var scrollFactor:Vector = new Vector(0,0);
  public static var leftCameraPoxition:Vector = new Vector(0,0);

  public function new (layer : TiledImageLayer, level : Level){

    super({
      name:'image_layer.${layer.name}',
      centered: false,
      batcher : Main.backgroundBatcher,
      pos: new Vector(0, 0),
      texture: Luxe.resources.texture(background_image_path_filter('assets/'+layer.image.source)),
      visible: layer.visible
    });

  }

  function background_image_path_filter(Path : String):String{

    var regex = ~/\.\.\//;

    return regex.replace(Path, "");

  }

  override function ondestroy(){

    leftCameraPoxition.x = Luxe.camera.pos.x;
    leftCameraPoxition.y = Luxe.camera.pos.y;

  }

  public function setRepeatHorizontal(){

    texture.clamp_s = ClampType.repeat;

  }

  public function setRepeatVertical(){

    texture.clamp_t = ClampType.repeat;

  }

  override function update(dt:Float) {

    super.update(dt);

    scroll.x += scrollVelocity.x * dt;
    scroll.y += scrollVelocity.y * dt;

    if(scroll.x > texture.width || scroll.x < -texture.width){
      scroll.x = 0;
    }

    if(scroll.y > texture.width || scroll.y < -texture.width){
      scroll.y = 0;
    }

    uv.x = ((Luxe.camera.pos.x + leftCameraPoxition.x) * scrollFactor.x) + scroll.x;
    uv.y = ((Luxe.camera.pos.y + leftCameraPoxition.y) * scrollFactor.y) + scroll.y;

  }

}