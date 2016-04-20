package;

import openfl.display.*;
import openfl.Assets;
import openfl.text.*;
import openfl.Lib;
import openfl.events.*;

class Main extends Sprite
{
	public static var textDisplay:TextDisplay;
	public var ui:UIElements;
	
	public var standardSize:Float = 130.203125;
	public static var calibrationFactor:Float;
	
	//variables dealing with a resize of the screen:
	public var previousWidth:Int;//the width of the stage last frame
	public var previousHeight:Int;//the height of the stage last frame
	public var resizedLastFrame:Bool;
	
	public static var otherDisplay:OtherDisplay;
	
	public static var simHandle:SimulationHandle;
	
	public var textFileContents:String;
	
	public static var simulationFont:Font;
	public static var textSizeRatio:Float = -1;
	
	public function new ()
	{
		super ();
		////logo:	
		//var spr:Sprite = new Sprite();
		//var space:Float = 1/18;
		//var rWidth:Float = 1/20;
		//spr.graphics.beginFill(0xD29E39);
		//spr.graphics.drawRect(0*space*stage.stageWidth,stage.stageHeight*.3,rWidth*stage.stageWidth,stage.stageHeight*.2);
		//spr.graphics.drawRect(1*space*stage.stageWidth,stage.stageHeight*.5,rWidth*stage.stageWidth,stage.stageHeight*.2);
		//spr.graphics.drawRect(2*space*stage.stageWidth,stage.stageHeight*.3,rWidth*stage.stageWidth,stage.stageHeight*.2);
		//spr.graphics.beginFill(0x2D4052);
		//spr.graphics.drawRect(3*space*stage.stageWidth,stage.stageHeight*.1,rWidth*stage.stageWidth,stage.stageHeight*.4);
		//spr.graphics.drawRect(4*space*stage.stageWidth,stage.stageHeight*.3,rWidth*stage.stageWidth,stage.stageHeight*.2);
		//spr.graphics.drawRect(5*space*stage.stageWidth,stage.stageHeight*.1,rWidth*stage.stageWidth,stage.stageHeight*.4);
		//spr.graphics.drawRect(6*space*stage.stageWidth,stage.stageHeight*.1,rWidth*stage.stageWidth,stage.stageHeight*.4);
		//spr.graphics.lineStyle(0x000000,3);
		//spr.graphics.moveTo(0,stage.stageHeight*.5);
		//spr.graphics.lineTo(stage.stageWidth,stage.stageHeight/2);
		//stage.addChild(spr);
		//Lib.current.stage.color = 0xEFEFEF;
		
		sizeCalibration();
		
		simulationFont = Assets.getFont("fonts/RobotoCondensed-Regular.ttf");
		
		otherDisplay = new OtherDisplay(stage);
		
		simHandle = new SimulationHandle(stage);
		
		textDisplay = new TextDisplay(stage, this);
		extractAndAddPages();
		textDisplay.updateTitleObject();
		textDisplay.updateMainTextObject();
		ui = new UIElements(stage);
		
		stage.addEventListener(Event.ENTER_FRAME, drawFrame);
	}
	public function sizeCalibration()
	{
		//a slightly hack-y way of calibrating for different screens: since text size generally calibrates itself to be readable on the device rendering it, use it as a way of determining how big a pixel should really be considered relative to the creator's setup.
		var calibrationFont = Assets.getFont("fonts/OpenSans-Regular.ttf");
		var calibrationField:TextField = new TextField();
		calibrationField.setTextFormat(new TextFormat(calibrationFont.fontName, 18));
		calibrationField.text = "aaaaaaaaaaaaa";
		calibrationFactor = calibrationField.textWidth/standardSize;
	}
	public function extractAndAddPages()
	{
		textFileContents = Assets.getText("text/text");
		var deletionAmount:Int = 0;
		var textPos = 0;
		var titleTextStore:Array<String> = [];
		var mainTextStore:Array<String> = [];
		var lastCurlyPos:Int = 0;
		var inTextSection:Bool = false;
		while(textPos<textFileContents.length)
		{
			if(textPos == textFileContents.length-1 && inTextSection)
			{
				if(inTextSection)
				{
					mainTextStore.push(textFileContents.substr(lastCurlyPos+2,textPos-2-lastCurlyPos));
				}
			}
			if(textFileContents.charAt(textPos) == "{")
			{
				if(textPos != 0)
				{
					if(textFileContents.charAt(textPos-1) == "\\")
					{
						textFileContents = textFileContents.substr(0,textPos-1)+textFileContents.substr(textPos,textFileContents.length);
						textPos--;
						continue;
					}
				}
				if(inTextSection)
				{
					mainTextStore.push(textFileContents.substr(lastCurlyPos+2,textPos-lastCurlyPos-3));
				}
				var pageTitleText:String;
				var textPosBegin:Int = textPos+1;
				while(textPos+1<textFileContents.length)
				{
					textPos++;
					if(textFileContents.charAt(textPos) == "}")
					{
						if(textFileContents.charAt(textPos-1) == "\\")
						{
							textFileContents = textFileContents.substr(0,textPos-1)+textFileContents.substr(textPos,textFileContents.length);
							textPos--;
							continue;
						}
						titleTextStore.push(textFileContents.substr(textPosBegin,textPos-textPosBegin));
						inTextSection = true;
						while(textPos+1<textFileContents.length)
						{
							textPos++;
							if(textFileContents.charAt(textPos) == "}")
							{
								lastCurlyPos = textPos;
								break;
							}
						}
						break;
					}
				}
			}
			textPos++;
		}
		for(i in 0...titleTextStore.length)
		{
			textDisplay.addPage(titleTextStore[i], mainTextStore[i]);
		}
		textDisplay.pageAmount = titleTextStore.length;
	}
	public function drawFrame(e:Event)
	{
		var frameStartTime:Int = Lib.getTimer();
		resizeCheck();
		ui.uiUpdate();
		simHandle.run(frameStartTime);
		//trace(ui.textContractButton.y);
	}
	public function resizeCheck()
	{
		if(resizedLastFrame)
		{
			if(previousWidth == stage.stageWidth || previousHeight == stage.stageHeight)
			{
				resizedLastFrame = false;
				resize();
			}
		}
		else if(previousWidth != stage.stageWidth || previousHeight != stage.stageHeight)
		{
			resizedLastFrame = true;
		}
		previousWidth = stage.stageWidth;
		previousHeight = stage.stageHeight;
	}
	public function resize()
	{
		sizeCalibration();
		textDisplay.resize();
		otherDisplay.resize();
		ui.resize();
	}
}
