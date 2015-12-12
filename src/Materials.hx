import nape.phys.Material;

class Materials{

  public static var Air : Material; // used when the body is on the air
  public static var Ground : Material; // used when the body is on the ground

  public function new(){

    Air = new Material(0, 0, 1, 2);
    Ground = new Material(0, 3, 1, 2);

  }

}
