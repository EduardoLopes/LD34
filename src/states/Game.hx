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


class Game extends State {

  var level : Level;

  public function new() {

    super({ name:'game' });

  }

  override function onenter<T>(_:T) {

    var res = Luxe.resources.text('assets/maps/test.tmx');

    level = new Level({
      tiled_file_data:res.asset.text,
      pos : new Vector(0,Luxe.screen.h / 2),
      asset_path: 'assets/images'
    });

    level.display({ visible: true, scale:1 });

    connect_input();

    Luxe.physics.nape.space.listeners.add(new PreListener(
      InteractionType.COLLISION,
      Main.types.OneWay,
      Main.types.Player,
      oneWayCollision,
      /*precedence*/ 0,
      /*pure*/ true
    ));


  }

  function oneWayCollision(cb:PreCallback):PreFlag {

    if(cb.arbiter.collisionArbiter.normal.y == 1){
      return PreFlag.IGNORE;
    }

    return PreFlag.ACCEPT_ONCE;

  }

  function connect_input() {

    Luxe.input.bind_key('jump', Key.key_z);
    Luxe.input.bind_key('shoot', Key.key_k);

    Luxe.input.bind_gamepad('shoot', 3);
    Luxe.input.bind_gamepad('jump', 2);

  }

  override function onleave<T>(_:T) {

  }

}