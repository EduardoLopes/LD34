package components;

import luxe.Component;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.callbacks.CbType;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.shape.Circle;
import nape.geom.Vec2;

enum BodyShape {
  Rectangle;
  Circle;
}

typedef BodyOptions = {
  var bodyType : BodyType;
  var types : Array<CbType>;
  @:optional var allowRotation : Bool;
  @:optional var polygon : Array<nape.geom.Vec2>;
  @:optional var isBullet : Bool;
  @:optional var shapeType : BodyShape;
  @:optional var radius : Float;
}

class BodySetup extends Component {

  public var body : Body;
  public var core : Shape;
  var options : BodyOptions;

  public function new(Options : BodyOptions){

    super({name: 'body_setup'});

    options = Options;

  }

  override function onadded() {

    body = new Body(options.bodyType);
    body.position.setxy(pos.x, pos.y);
    body.allowRotation = (options.allowRotation != null) ? options.allowRotation : false;
    body.isBullet = (options.isBullet != null) ? options.isBullet : false;

    for( type in options.types.iterator() ){
        body.cbTypes.add(type);
    }

    options.shapeType = (options.shapeType != null) ? options.shapeType : BodyShape.Rectangle;

    switch options.shapeType {
      case BodyShape.Rectangle: setRectangleShape();
      case BodyShape.Circle: setCircleShape();
    }

    body.shapes.add( core );

    body.space = Luxe.physics.nape.space;

  }

  function setRectangleShape(){

    core = new Polygon(options.polygon);

  }

  function setCircleShape(){

    if(options.radius == null){
      throw "radius should not be null";
    }

    core = new Circle(options.radius);

  }

}