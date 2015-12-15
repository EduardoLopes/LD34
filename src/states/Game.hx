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
import components.CameraFollower;

import luxe.Text;
import objects.Player;

import objects.SpikeBlock;

import phoenix.Texture.ClampType;

class Game extends State {

  public static var drawer : DebugDraw;
  public static var levels : Map<Int, Level>;
  var IDLastLevelCreated : Int = 0;
  var background_1 : luxe.Sprite;
  var background_2 : luxe.Sprite;
  var text : Text;
  public static var player : Player;
  var create_level_event_id:String;

  public function new() {

    super({ name:'game' });

    drawer = new DebugDraw({
      depth: 100
    });
    Luxe.physics.nape.debugdraw = drawer;
    Luxe.physics.nape.draw = true;

  }

  override function onenter<T>(_:T) {

    Level.spike_blockID = 0;
    IDLastLevelCreated = 0;

    levels = new Map();

    var res = Luxe.resources.text('assets/maps/initial_map.tmx');

    for(y in 0...6){

      create_level();

    }

    create_level_event_id = Luxe.events.listen('create_level', function(_){

      create_level();

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

    background_1 = new luxe.Sprite({
      name: 'background_1',
      batcher: Main.backgroundBatcher,
      depth: 2,
      pos: new Vector(0, 0),
      size: new Vector(Main.gameResolution.x, Main.gameResolution.y),
      texture: Luxe.resources.texture('assets/images/background_1.png')
    });

    background_2 = new luxe.Sprite({
      name: 'background_2',
      batcher: Main.backgroundBatcher,
      depth: 1,
      pos: new Vector(0, 0),
      size: new Vector(Main.gameResolution.x, Main.gameResolution.y),
      texture: Luxe.resources.texture('assets/images/background_2.png')
    });

    text = new Text({
      text: '0',
      pos : new Vector(0, 128),
      point_size : 32,
      color: new luxe.Color().rgb(0xdad45e),
      font: Luxe.resources.font('assets/fonts/font.fnt'),
      batcher: Main.foregroundBatcher,
      bounds : new luxe.Rectangle(0, 0, 24, 24),
      align: left
    });

    background_1.texture.clamp_t = ClampType.repeat;
    background_1.texture.clamp_s = ClampType.repeat;
    background_2.texture.clamp_t = ClampType.repeat;
    background_2.texture.clamp_s = ClampType.repeat;

    Main.backgroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.backgroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);
    Main.foregroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.foregroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);

  }

  function create_level(){

    var map_ID = Luxe.utils.random.int(-2, 29);

    map_ID = Math.floor(Math.max(1, Math.min(map_ID, 27)));

    if(IDLastLevelCreated == 0){
      map_ID = 0;
    }

    var res = Luxe.resources.text('assets/maps/map_'+map_ID+'.tmx');

    var level = new Level({
      tiled_file_data: res.asset.text,
      pos : new Vector(0, -(IDLastLevelCreated * 80)) ,
      asset_path: 'assets/images'
    });

    level.setID(IDLastLevelCreated);
    level.display({ visible: true, scale:1 });

    levels.set(IDLastLevelCreated, level);

    IDLastLevelCreated++;

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

    background_1.uv.x = (Luxe.camera.pos.x) * 0.8;
    background_1.uv.y = (Luxe.camera.pos.y) * 0.8;
    background_2.uv.x = (Luxe.camera.pos.x) * 0.4;
    background_2.uv.y = (Luxe.camera.pos.y) * 0.4;

    text.text = Std.string(Math.abs(CameraFollower.currentPositionNormal.y));

    for(level in levels){

      if(level.destroyed == false){
        level.update(dt);
      }

    }

  }

  override function onleave<T>(_:T) {

    IDLastLevelCreated = 0;

    background_1.destroy();
    background_1 = null;
    background_2.destroy();
    background_2 = null;

    Luxe.events.unlisten(create_level_event_id);

    player.destroy();
    player = null;

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