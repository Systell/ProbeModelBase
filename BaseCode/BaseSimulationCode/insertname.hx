package;

import openfl.display.*;
import openfl.Lib;
import openfl.events.*;

class INSERTNAME extends Simulation
{
	//variables from Simulation: s:Stage; maxPriority:Int; calibrationFactor:Float;
	public function new (s:Stage, calibrationFactor:Float)
	{
		super(s, calibrationFactor:Float);
	}
	public override function precompute(priority:Int, timeToCompute:Int):Bool
	{
		return false;
	}
	public override function resize()
	{
		
	}
	public override function activate()
	{
		
	}
	public override function deactivate()
	{
		
	}
	public override function enterFrame(e:Event)
	{
		
	}
	public override function getSpriteHeight():Float
	{
		return 0;
	}
}
