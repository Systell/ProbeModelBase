package;

import openfl.display.*;
import openfl.Assets;
import openfl.text.*;
import openfl.Lib;
import openfl.events.*;
import openfl.geom.Rectangle;

class TextDisplay
{
	public var titleTextFont:Font;
	public var titleTextFormat:TextFormat;
	public var titleField:TextField;
	
	public var mainTextFont:Font;
	public var mainTextFormat:TextFormat;
	public var mainField:TextField;

	public var expandHelperFont:Font;
	public var expandHelperTextFormat:TextFormat;
	public var expandHelperField:TextField;
	
	public var s:Stage;
	
	public var expanded:Bool;
	
	public var pageNumber:Int = 0;
	public var pages:Array<Page> = [];
	public var pageAmount:Int;
	
	public var thinMode:Bool = false;
	public var thinCutoffRatio = .8;//the ratio of the text width and scroll bar to the width of the stage below which thinMode is activated
	public var largeLength = 700;//this times the calibration factor is the ideal width of the text (designer consensus says there should be about ~70 max characters per line)
	public var currentSimHeight:Float = 0;

	public var hasContracted:Array<Bool> = [];

	public var m:Main;
	public function new(inputStage:Stage, m:Main)//creates and sets up the TextDisplay class
	{
		s = inputStage;
		this.m = m;
		setupTitleText();
		setupMainText();
		Main.simHandle.newSimulation(pageNumber);
		expandHelperTextFormat = new TextFormat(Main.simulationFont.fontName, 12, null, null, null, null, null, null, TextFormatAlign.CENTER);
		expandHelperField = new TextField();
		expandHelperField.defaultTextFormat = expandHelperTextFormat;
		expandHelperField.autoSize = TextFieldAutoSize.NONE;
		expandHelperField.textColor = 0x000000;
		expandHelperField.text = "Double click above arrow to show simulation";
		expandHelperField.width = s.stageWidth;
		expandHelperField.y = s.stageHeight-expandHelperField.textHeight*1.1;
	}
	public function setupTitleText()
	{
		titleTextFont = Assets.getFont("fonts/Dense-Regular.otf");
		titleTextFormat = new TextFormat(titleTextFont.fontName, 36, null, null, null, null, null, null, TextFormatAlign.CENTER);
		titleField = new TextField();
		titleField.defaultTextFormat = titleTextFormat;
		titleField.autoSize = TextFieldAutoSize.NONE;
		titleField.wordWrap = true;
		titleField.width = s.stageWidth;
		titleField.height = OtherDisplay.getHeadBarHeight();
		titleField.y = .5*(Main.otherDisplay.headBar.height-titleField.textHeight);
		titleField.x = 0;
		titleField.textColor = 0xEEEEEE;
		s.addChild(titleField);
		var textField = new TextField();
		
		s.addChild(titleField);
	}
	public function setupMainText()
	{
		mainTextFont = Assets.getFont("fonts/OpenSans-Regular.ttf");
		mainField = new TextField();
		//mainField.htmlText = true;
		mainField.width = determineMainWidth();
		mainTextFormat = new TextFormat(mainTextFont.fontName,getMainTextSize());
		mainField.setTextFormat(mainTextFormat);
		mainField.wordWrap = true;
		mainField.height = s.stageHeight;//getContractHeight();
		mainField.y = OtherDisplay.getHeadBarHeight()*1.1;
		mainField.x = .5*(s.stageWidth-mainField.width);
		mainField.textColor = 0x535353;
		mainField.selectable = false;
		s.addChild(mainField);
		
	}
	public function getMainTextSize():Int
	{
		if(Main.calibrationFactor*mainField.width < largeLength-1)
		{
			Main.textSizeRatio = (18-6*(800-mainField.width)/600)/18;
			return Math.round(18-6*(800-mainField.width)/600);
		}
		Main.textSizeRatio = -1;
		return 18;
	}
	public function scrollText(e:MouseEvent)
	{
		mainField.scrollV -= e.delta;
	}
	public function determineMainWidth():Float
	{
		determineThinMode();
		if(thinMode)
		{
			return s.stageWidth*thinCutoffRatio-2*UIElements.getScrollAndSpaceWidth();
		}
		else
		{
			return largeLength*Main.calibrationFactor;
		}
	}
	public function determineThinMode()
	{
		if(largeLength*Main.calibrationFactor + 2*UIElements.getScrollTurnAndSpaceWidth() > s.stageWidth*thinCutoffRatio)
		thinMode = true;
		else
		thinMode = false;
	}
	public function updateTitleObject()
	{
		titleField.text = pages[pageNumber].titleText;
		titleField.y = .5*(Main.otherDisplay.headBar.height-titleField.textHeight);
	}
	public function updateMainTextObject()
	{
		mainField.text = pages[pageNumber].mainText;
	}
	public function resize()
	{
		if(pages[pageNumber].lastExpanded == 0)
		{
			if(mainField.textHeight > 0)
			{
				if(getContractHeight()/(mainField.textHeight) < .3)
				{
					expandText(false);
					m.ui.textExpanded();
				}
				else
				{
					contractText(false);
					m.ui.textContracted();
				}
			}
		}
		//else
		//{
//			
		//}
		if(!expanded)
		Main.simHandle.sims[pageNumber].resize();
		mainField.width = determineMainWidth();
		mainTextFormat.size = getMainTextSize();
		mainField.setTextFormat(mainTextFormat);
		mainField.x = .5*(s.stageWidth-(mainField.width+UIElements.getScrollAndSpaceWidth()));
		if(expanded)
		mainField.height = getExpandHeight();
		else
		mainField.height = getContractHeight();
		titleField.width = s.stageWidth;
		fixScroll();
		expandHelperField.width = s.stageWidth;
		expandHelperField.y = s.stageHeight-expandHelperField.textHeight*1.1;
	}
	public function fixScroll()
	{
		if(mainField.scrollV>mainField.maxScrollV)
		mainField.scrollV = mainField.maxScrollV;
	}
	public function goNextPage()
	{
		pages[pageNumber].scroll = mainField.scrollV;
		pageNumber = Math.round(Math.min(pageNumber+1,pageAmount-1));
		pageChange();
	}
	public function goPrevPage()
	{
		pages[pageNumber].scroll = mainField.scrollV;
		pageNumber = Math.round(Math.max(pageNumber-1,0));
		pageChange();
	}
	public function pageChange()
	{
		updateTitleObject();
		updateMainTextObject();
		mainField.scrollV = pages[pageNumber].scroll;
		Main.simHandle.newSimulation(pageNumber);
		if(pages[pageNumber].lastExpanded == 1)
		{
			expandText(false);
			m.ui.textExpanded();
		}
		if(pages[pageNumber].lastExpanded == 2)
		{
			contractText(false);
			m.ui.textContracted();
		}
		resize();
	}
	public function goUpOneLine():Float
	{
		mainField.scrollV--;
		return mainField.scrollV/mainField.maxScrollV;
	}
	public function goDownOneLine():Float
	{
		mainField.scrollV++;
		return mainField.scrollV/mainField.maxScrollV;
	}
	public function setScroll(percent:Float)
	{
		mainField.scrollV = Math.round(percent*mainField.maxScrollV)+1;
	}
	public function getScrollPercentage()
	{
		if(mainField.maxScrollV>1)
		return (mainField.scrollV-1)/(mainField.maxScrollV-1);
		else
		return 0;
	}
	public function contractText(?doResize:Bool = true)
	{
		expanded = false;
		mainField.height = getContractHeight();
		Main.simHandle.sims[pageNumber].activate();
		hasContracted[pageNumber] = true;
		s.removeChild(expandHelperField);
		if(doResize)
		resize();
	}
	public function expandText(?doResize:Bool = true)
	{
		expanded = true;
		mainField.height = getExpandHeight();
		Main.simHandle.sims[pageNumber].deactivate();
		s.addChild(expandHelperField);
		if(doResize)
		resize();
	}
	public function getContractHeight():Float
	{
		currentSimHeight = Main.simHandle.sims[pageNumber].getSpriteHeight();
		return (s.stageHeight-mainField.y-currentSimHeight*1.1-UIElements.textLengthBarHeight());
	}
	public function getExpandHeight():Float
	{
		return s.stageHeight-mainField.y-1.1*UIElements.getTextLengthUIHeight()-expandHelperField.textHeight*1.1;
	}
	public function getMainFieldRect():Rectangle
	{
		return new Rectangle(mainField.x, mainField.y, mainField.width, mainField.height);
	}
	public function addPage(titleText, mainText)
	{
		hasContracted.push(false);
		pages.push(new Page(titleText, mainText, pages.length));
		if(pages.length-1 == pageNumber)
		resize();
	}
}
