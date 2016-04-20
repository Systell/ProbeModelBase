import openfl.display.Stage;
import openfl.display.*;
class DELETE2 extends Simulation
{
	public var exampleSprite:Sprite;
	public function new(s:Stage, calibrationFactor:Float)
	{
		super(s, calibrationFactor);
		maxPriority = 4;
		exampleSprite = new Sprite();
		exampleSprite.graphics.beginFill(0x88AA88);
		exampleSprite.graphics.drawRect(0,0,200,200);
		exampleSprite.x = .5*(s.stageWidth-exampleSprite.width);
		exampleSprite.y = s.stageHeight-exampleSprite.height;
	}
	public override function precompute(priority:Int, timeToCompute:Int):Bool
	{
		if(Math.random()>.5)
		return true;
		else
		return false;
	}
	public override function getSpriteHeight():Float
	{
		return exampleSprite.height;
	}
	public override function activate()
	{
		s.addChild(exampleSprite);
	}
	public override function deactive()
	{
		s.removeChild(exampleSprite);
	}
	public override function resize()
	{
		exampleSprite.x = .5*(s.stageWidth-exampleSprite.width);
		exampleSprite.y = s.stageHeight-exampleSprite.height;
	}
}
