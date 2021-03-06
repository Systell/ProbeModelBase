package;

import openfl.display.*;
import openfl.Lib;
import openfl.events.*;

class Simulation
{
	public var s:Stage;
	public var maxPriority:Int;//the number of the highest priority that is used
	public var calibrationFactor:Float;
	public function new (s:Stage, calibrationFactor:Float)
	{
		this.s = s;
		this.calibrationFactor = calibrationFactor;
	}
	public function precompute(priority:Int, timeToCompute:Int):Bool
	{
		return false;
	}
	public function resize()
	{
		
	}
	public function activate()
	{
		
	}
	public function deactive()
	{
		
	}
	public function enterFrame(e:Event)
	{
		
	}
	public function getSprite():Sprite
	{
		return new Sprite();
	}
}
