import nape.callbacks.CbType;

class Types{

  public var Floor : CbType;
  public var Tilemap : CbType;
  public var Movable : CbType;
  public var OneWay : CbType;

  public function new(){

    Floor = new CbType();
    Tilemap = new CbType();
    Movable = new CbType();
    OneWay = new CbType();

  }

}