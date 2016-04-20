package;

import openfl.display.*;
import openfl.Lib;

class OtherDisplay
{
	public var s:Stage;
	public var headBar:Sprite;
	public function new (inputStage:Stage)
	{
		s = inputStage;
		
		Lib.current.stage.color = 0xEFEFEF;//2D4052;
		
		headBar = new Sprite(); 
		
		createHeadBar();
		
		s.addChild(headBar);

	}
	public function createHeadBar()
	{
		headBar.graphics.beginFill(0x2D4052);
		headBar.graphics.drawRect(0,0,s.stageWidth,OtherDisplay.getHeadBarHeight());
	}
	public static function getHeadBarHeight():Float	
	{
		return 70*Main.calibrationFactor;
	}
	public function resize()
	{
		createHeadBar();
	}
}
