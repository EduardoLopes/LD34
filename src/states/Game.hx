package states;

import luxe.States;
import luxe.Input;
import luxe.Vector;
import objects.Background;

import nape.callbacks.CbEvent;
import nape.callbacks.InteractionType;

import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;

import luxe.physics.nape.DebugDraw;


class Game extends State {

  var level : Level;
  public static var drawer : DebugDraw;
  public static var levels : Map<Int, Level>;
  var IDLastLevelCreated : Int = 0;

  public function new() {

    super({ name:'game' });

    drawer = new DebugDraw({
      depth: 100
    });
    Luxe.physics.nape.debugdraw = drawer;
    Luxe.physics.nape.draw = true;

  }

  override function onenter<T>(_:T) {

    levels = new Map();

    var res = Luxe.resources.text('assets/maps/initial_map.tmx');

    level = new Level({
      tiled_file_data:res.asset.text,
      pos : new Vector(0,Luxe.screen.h / 2),
      asset_path: 'assets/images'
    });

    level.display({ visible: true, scale:1 });

    for(y in 0...Math.floor(Luxe.screen.h / 80) + 1 ){

      create_level(y);

    }

    Luxe.events.listen('create_one_level', function(_){

      create_level(IDLastLevelCreated + 1);

    });

    connect_input();

    Luxe.physics.nape.space.listeners.add(new PreListener(
      InteractionType.COLLISION,
      Main.types.OneWay,
      Main.types.Player,
      oneWayCollision,
      /*precedence*/ 0,
      /*pure*/ true
    ));

    enable();

    Luxe.camera.get('follower').resetCamera();

  }

  function create_level(y:Int){

    var map_ID = Luxe.utils.random.int(-2, 14);

    map_ID = Math.floor(Math.max(1, Math.min(map_ID, 8)));

    var res = Luxe.resources.text('assets/maps/map_'+map_ID+'.tmx');

    var level = new Level({
      tiled_file_data: res.asset.text,
      pos : new Vector(0, (level.height * 16) - y * 80),
      asset_path: 'assets/images'
    });

    levels.set(y, level);

    level.display({ visible: true, scale:1 });

    IDLastLevelCreated = y;

  }

  function oneWayCollision(cb:PreCallback):PreFlag {

    var colArb = cb.arbiter.collisionArbiter;

    if ((colArb.normal.y > 0) != cb.swapped) {
        return PreFlag.IGNORE;
    } else {
        return PreFlag.ACCEPT;
    }

  }

  function connect_input() {

    Luxe.input.bind_key('jump', Key.key_k);
    Luxe.input.bind_key('shoot', Key.key_l);

    Luxe.input.bind_key('jump', Key.key_z);
    Luxe.input.bind_key('shoot', Key.key_x);

    Luxe.input.bind_key('jump', Key.key_a);
    Luxe.input.bind_key('shoot', Key.key_s);

    Luxe.input.bind_gamepad('shoot', 3);
    Luxe.input.bind_gamepad('jump', 2);

  }

  override function update(dt:Float){

    for(level in levels){

      if(level.pos != null){
        level.update(dt);
      }

    }

  }

  override function onleave<T>(_:T) {

    level.clear();
    level = null;
    IDLastLevelCreated = 0;

    for(level in levels){
      if(level != null){
        level.clear();
        level = null;
      }
    }

    Luxe.scene.empty();
    Luxe.renderer.batcher.empty();
    //Luxe.scene.add(Luxe.camera);


    levels = null;

    Luxe.physics.nape.space.clear();

  }

}