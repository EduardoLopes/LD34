package components;

import luxe.Component;

import nape.callbacks.CbEvent;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.CbType;
import nape.dynamics.ArbiterList;

import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.dynamics.Arbiter;

@:enum abstract Touching(Int) from Int to Int{
  var NONE    = 0;
  var TOP     = 1;
  var RIGHT   = 2;
  var BOTTOM  = 4;
  var LEFT    = 8;
  var WALL    = 2 | 8;
  var ANY    = 1 | 2 | 4 | 8;
}

class TouchingChecker extends Component {

  var object : Dynamic;
  var objectType1 : CbType;
  var objectType2 : CbType;
  var lastWallEvent:String;
  var lastGroundEvent:String;
  var lastLeftWallEvent:String;
  var lastRightWallEvent:String;
  var lastColladingEvent:String;
  var wallEvent:String;
  var groundEvent:String;
  var leftWallEvent:String;
  var rightWallEvent:String;
  var colladingEvent:String;
  var touching:Touching;
  var wasTouching:Touching;
  var swapped:Bool = false;
  /*
      InteractionListener callback is not called in some frames,
      this function helpes figure out if i was called or not
  */
  var touchingFunctionUpdated:Bool = false;

  public function new(componentName:String, ObjectType1 : CbType, ObjectType2 : CbType){

    super({name: componentName});

    objectType1 = ObjectType1;
    objectType2 = ObjectType2;

  }

  override function init() {

    object = cast entity;

    Luxe.physics.nape.space.listeners.add(new PreListener(
      InteractionType.COLLISION,
      objectType1,
      objectType2,
      preOnGoing,
      /*precedence*/ 0,
      /*pure*/ true
    ));

    Luxe.physics.nape.space.listeners.add(new InteractionListener(
      CbEvent.ONGOING, InteractionType.COLLISION,
      objectType1,
      objectType2,
      onGoing
    ));

    Luxe.physics.nape.space.listeners.add(new InteractionListener(
      CbEvent.END, InteractionType.COLLISION,
      objectType1,
      objectType2,
      end
    ));

  }

  function preOnGoing(cb:PreCallback):PreFlag {

    swapped = cb.swapped;

    return cb.arbiter.collisionArbiter.state;

  }


  function checkAbriter(arbiter:Arbiter):Void{

    var colArb = arbiter.collisionArbiter;
    var body1 = colArb.body1;
    var body2 = colArb.body2;
    var arbiters;

    if(swapped){
      arbiters = body2.arbiters;
    } else {
      arbiters = body1.arbiters;
    }

    arbiters.foreach(function (obj):Void {

      if(obj.state == PreFlag.IGNORE || obj.state == PreFlag.IGNORE_ONCE) return null;

      if(!swapped){

        if(obj.collisionArbiter.normal.y == 1) touching |= Touching.BOTTOM;
        if(obj.collisionArbiter.normal.x == 1) touching |= Touching.LEFT;

        if(obj.collisionArbiter.normal.y == -1) touching |= Touching.TOP;
        if(obj.collisionArbiter.normal.x == -1) touching |= Touching.RIGHT;

      } else {

        if(obj.collisionArbiter.normal.y == 1) touching |= Touching.TOP;
        if(obj.collisionArbiter.normal.x == 1) touching |= Touching.RIGHT;

        if(obj.collisionArbiter.normal.y == -1) touching |= Touching.BOTTOM;
        if(obj.collisionArbiter.normal.x == -1) touching |= Touching.LEFT;

      }

    });

  }

  function checkContacts(arbiters:ArbiterList){

    arbiters.foreach(function (obj):Void {

      checkAbriter(obj);

    });

    touchingFunctionUpdated = true;

  }

  function onGoing(cb:InteractionCallback){

    checkContacts(cb.arbiters);

  }

  function end(cb:InteractionCallback){

    checkContacts(cb.arbiters);

  }

  function isTouching(direction:Touching){

    return (touching & direction) != Touching.NONE;

  }

  function justTouched(direction:Touching){

    return isTouching(touching) && (wasTouching & direction) == Touching.NONE;

  }

  override function update(dt:Float):Void{

    if(touchingFunctionUpdated == false || object == null) return null;

    rightWallEvent = name+'_offRight';
    leftWallEvent = name+'_offLeft';
    wallEvent = name+'_offSide';
    groundEvent = name+'_offBottom';
    colladingEvent = name+'_wasCollading';

    if( isTouching(Touching.RIGHT) ){
      rightWallEvent = name+'_onRight';
    }

    if( isTouching(Touching.LEFT)  ){
      leftWallEvent = name+'_onLeft';
    }

    if( isTouching(Touching.WALL)  ){
      wallEvent = name+'_onSide';
    }

    if( isTouching(Touching.BOTTOM)  ){
      groundEvent = name+'_onBottom';
    }

    if( isTouching(Touching.ANY)  ){
      colladingEvent = name+'_collading';
    }

    if( rightWallEvent != lastRightWallEvent ){

      object.events.fire(rightWallEvent);
      lastRightWallEvent = rightWallEvent;

    }

    if( leftWallEvent != lastLeftWallEvent ){

      object.events.fire(leftWallEvent);
      lastLeftWallEvent = leftWallEvent;

    }

    if( wallEvent != lastWallEvent ){

      object.events.fire(wallEvent);
      lastWallEvent = wallEvent;

    }

    if( groundEvent != lastGroundEvent ){

      object.events.fire(groundEvent);
      lastGroundEvent = groundEvent;

    }

    if( colladingEvent != lastColladingEvent ){

      object.events.fire(colladingEvent);
      lastColladingEvent = colladingEvent;

    }

    //clean up collision index
    wasTouching = touching;
    touching = Touching.NONE;

    touchingFunctionUpdated = false;

  }
}