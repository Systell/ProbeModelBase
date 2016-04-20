package;

import openfl.display.*;
import openfl.Assets;
import openfl.Lib;
import openfl.events.*;
import openfl.geom.Rectangle;
import openfl.text.*;

class UIElements
{
	public var s:Stage;
	
	public var halfTriangleWidth:Float;
	public var triangleWidth:Float;
	public static var pageTurnIconRadius:Float = 30;//this times the calibration factor is the radius of the circle of the big page turn icon
	
	public var currentThinMode:Bool;
	
	public var nextPartSprites:Array<Sprite> = [];
	public var prevPartSprites:Array<Sprite> = [];
	public var nextPartButton:SimpleButton;
	public var prevPartButton:SimpleButton;
	public var thinNextPartSprites:Array<Sprite> = [];
	public var thinPrevPartSprites:Array<Sprite> = [];
	public var thinNextPartButton:SimpleButton;
	public var thinPrevPartButton:SimpleButton;
	public var firstPage:Bool = false;
	public var lastPage:Bool = false;
	
	public var textLengthSprite:Sprite;
	public var textExpandSprites:Array<Sprite> = [];
	public var textContractSprites:Array<Sprite> = [];
	public var textExpandButton:SimpleButton;
	public var textContractButton:SimpleButton;
	
	public var scrollSprite:Sprite;
	public var scrollHitSprite:Sprite;
	public var scrollRectSprite:Sprite;
	public var scrollUpSprites:Array<Sprite> = [];
	public var scrollDownSprites:Array<Sprite> = [];
	public var scrollUpButton:SimpleButton;
	public var scrollDownButton:SimpleButton;
	public var scrollRectGrabbed:Bool = false;
	public var scrollRectGrabY:Float = 0;
	public var scrollRectGrabMouseY:Float = 0;
	public var scrollRectMaxHeight:Float;
	
	public var excessScrollNext:Float = 0;
	public var excessScrollNextLastFrame:Float = 0;
	public var excessScrollPrev:Float = 0;
	public var excessScrollPrevLastFrame:Float = 0;
	public var maxExcess:Float = 15;
	public var excessSprite:Sprite;
	public var excessNextBitmap:Bitmap;
	public var excessPrevBitmap:Bitmap;
	public var excessLastUpdate:Int = 0;
	public var excessWaitTime:Int = 1000;
	public var excessDecaySpeed:Float = .005;
	public var preventPageTurnWait:Int = 100;
	public var preventPageTurnActivated:Int = 0;
	public function new (inputStage:Stage)
	{
		s = inputStage;
		currentThinMode = Main.textDisplay.thinMode;
		createUIGraphics();
		s.addEventListener(MouseEvent.MOUSE_WHEEL, scrollText);
		s.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
	}
	public function createUIGraphics()
	{
		triangleWidth = getTriangleWidth();
		halfTriangleWidth = .5*triangleWidth;
		createNavigationGraphics();
		createScrollGraphics();
		createTextLengthUI();
		createChangePageUI();
	}
	public static function getTriangleWidth():Float
	{
		return 16*Main.calibrationFactor;
	}
	public static function textLengthBarHeight():Float
	{
		return 2*getTriangleWidth();
	}
	//Change Part:
	public function createChangePageUI()
	{
		nextPartSprites = pageIcons(true);
		prevPartSprites = pageIcons(false);
		nextPartButton = new SimpleButton(nextPartSprites[0], nextPartSprites[1], nextPartSprites[2], nextPartSprites[1]);
		prevPartButton = new SimpleButton(prevPartSprites[0], prevPartSprites[1], prevPartSprites[2], prevPartSprites[1]); 
		if(!Main.textDisplay.thinMode)
		{
			nextPartButton.addEventListener(MouseEvent.CLICK, goNextPage);
			prevPartButton.addEventListener(MouseEvent.CLICK, goPrevPage);
		}
		
		thinNextPartSprites = thinPageIcons(true);
		thinPrevPartSprites = thinPageIcons(false);
		thinNextPartButton = new SimpleButton(thinNextPartSprites[0], thinNextPartSprites[1], thinNextPartSprites[2], thinNextPartSprites[1]);
		thinPrevPartButton = new SimpleButton(thinPrevPartSprites[0], thinPrevPartSprites[1], thinPrevPartSprites[2], thinPrevPartSprites[1]); 
		if(Main.textDisplay.thinMode)
		{
			thinNextPartButton.addEventListener(MouseEvent.CLICK, goNextPage);
			thinPrevPartButton.addEventListener(MouseEvent.CLICK, goPrevPage);
		}
		
		positionPageButtons();
		
		if(Main.textDisplay.thinMode)
		{
			s.addChild(thinNextPartButton);
			s.addChild(thinPrevPartButton);
		}
		else
		{
			s.addChild(nextPartButton);
			s.addChild(prevPartButton);
		}
		
		excessNextBitmap = new Bitmap(null);
		excessNextBitmap.x = nextPartButton.x;
		excessNextBitmap.y = nextPartButton.y;
		excessPrevBitmap = new Bitmap(null);
		excessPrevBitmap.x = prevPartButton.x;
		excessPrevBitmap.y = prevPartButton.y;
		s.addChild(excessNextBitmap);
		s.addChild(excessPrevBitmap);
	}
	public function positionPageButtons()
	{
		if(Main.textDisplay.thinMode)
		{
			var fieldRect:Rectangle;
			if(Main.textDisplay.expanded)
			fieldRect = new Rectangle(textExpandButton.x, textExpandButton.y, textExpandButton.width, textExpandButton.height);
			else
			fieldRect = new Rectangle(textContractButton.x, textContractButton.y, textContractButton.width, textContractButton.height);
			thinNextPartButton.x = fieldRect.x + 2*fieldRect.width;
			thinPrevPartButton.x = fieldRect.x - 1*fieldRect.width - thinPrevPartButton.width;
			thinNextPartButton.y = fieldRect.y;
			thinPrevPartButton.y = fieldRect.y;
		}
		else
		{
			var fieldRect:Rectangle = Main.textDisplay.getMainFieldRect();
			nextPartButton.y = fieldRect.y+.5*(fieldRect.height);
			prevPartButton.y = nextPartButton.y;
			nextPartButton.x = scrollUpButton.x+scrollUpButton.width+.5*prevPartButton.width;
			prevPartButton.x = fieldRect.x-1.5*prevPartButton.width;
		}
	}
	public function goNextPage(?e:Event)
	{
		excessScrollNext = 0;
		excessScrollPrev = 0;
		Main.textDisplay.goNextPage();
		resize();
	}
	public function goPrevPage(?e:Event)
	{
		excessScrollNext = 0;
		excessScrollPrev = 0;
		Main.textDisplay.goPrevPage();
		resize();
	}
	public function pageIcons(next:Bool):Array<Sprite>
	{
		var radius = pageTurnIconRadius*Main.calibrationFactor;
		var diameter = radius*2;
		var centerX = radius;
		var centerY = radius;
		excessSprite = new Sprite();
		excessSprite.graphics.beginFill(0x000000);
		excessSprite.graphics.drawCircle(centerX,centerY,radius);
		var pageSprites:Array<Sprite> = [];
		var colours:Array<Int> = [0x000000, 0x587DA0, 0x2D4052];
		for(i in 0...3)
		{
			pageSprites.push(new Sprite());
			pageSprites[i].graphics.beginFill(0x000000, 0);
			pageSprites[i].graphics.lineStyle(1, colours[i], 1, true);
			pageSprites[i].graphics.drawCircle(centerX,centerY,radius);
			//5apps fails unless I include this pointless textfield;
			var tmpSpr = pageSprites[i];
			var tf:TextField = new TextField();
			tf.selectable = false;
			tf.width = tmpSpr.width;
			tf.height = tmpSpr.height;
			if(next)
			{
				pageSprites[i].graphics.moveTo(diameter*.75, .5*diameter);
				pageSprites[i].graphics.lineTo(diameter*.33, .25*diameter);
				pageSprites[i].graphics.moveTo(diameter*.75, .5*diameter);
				pageSprites[i].graphics.lineTo(diameter*.33, .75*diameter);
			}
			else
			{
				pageSprites[i].graphics.moveTo(diameter*.25, .5*diameter);
				pageSprites[i].graphics.lineTo(diameter*.66, .25*diameter);
				pageSprites[i].graphics.moveTo(diameter*.25, .5*diameter);
				pageSprites[i].graphics.lineTo(diameter*.66, .75*diameter);
			}
		}
		return pageSprites;
	}
	public function thinPageIcons(next:Bool):Array<Sprite>
	{
		//excessSprite = new Sprite();
		//excessSprite.graphics.beginFill(0x000000);
		//excessSprite.graphics.drawCircle(centerX,centerY,radius);
		var pageSprites:Array<Sprite> = [];
		var colours:Array<Int> = [0x000000, 0x587DA0, 0x2D4052];
		for(i in 0...3)
		{
			pageSprites.push(new Sprite());
			pageSprites[i].graphics.beginFill(0x000000, 0);
			pageSprites[i].graphics.lineStyle(1, colours[i], 1, true);
			if(next)
			{
				pageSprites[i].graphics.moveTo(0, 0);
				pageSprites[i].graphics.lineTo(triangleWidth, .5*halfTriangleWidth);
				pageSprites[i].graphics.lineTo(0, halfTriangleWidth);
				pageSprites[i].graphics.beginFill(0x000000, 0);
				pageSprites[i].graphics.lineStyle(0, 0x000000, 0, true);
				pageSprites[i].graphics.drawRect(0,0,pageSprites[i].width,pageSprites[i].height);
			}
			else
			{
				pageSprites[i].graphics.moveTo(triangleWidth, 0);
				pageSprites[i].graphics.lineTo(0, .5*halfTriangleWidth);
				pageSprites[i].graphics.lineTo(triangleWidth, halfTriangleWidth);
				pageSprites[i].graphics.beginFill(0x000000, 0);
				pageSprites[i].graphics.lineStyle(0, 0x000000, 0, true);
				pageSprites[i].graphics.drawRect(0,0,pageSprites[i].width,pageSprites[i].height);
			}
		}
		return pageSprites;
	}
	public function resizePageButtons()
	{
		if(Main.textDisplay.thinMode != currentThinMode)
		{
			if(Main.textDisplay.thinMode)
			{
				nextPartButton.removeEventListener(MouseEvent.CLICK, goNextPage);
				prevPartButton.removeEventListener(MouseEvent.CLICK, goPrevPage);
				thinNextPartButton.addEventListener(MouseEvent.CLICK, goNextPage);
				thinPrevPartButton.addEventListener(MouseEvent.CLICK, goPrevPage);
				if(!lastPage)
				{
					s.removeChild(nextPartButton);
					s.addChild(thinNextPartButton);
				}
				if(!firstPage)
				{
					s.addChild(thinPrevPartButton);
					s.removeChild(prevPartButton);
				}
			}
			else
			{
				nextPartButton.addEventListener(MouseEvent.CLICK, goNextPage);
				prevPartButton.addEventListener(MouseEvent.CLICK, goPrevPage);
				thinNextPartButton.removeEventListener(MouseEvent.CLICK, goNextPage);
				thinPrevPartButton.removeEventListener(MouseEvent.CLICK, goPrevPage);
				if(!lastPage)
				{
					s.removeChild(thinNextPartButton);
					s.addChild(nextPartButton);
				}
				if(!firstPage)
				{
					s.removeChild(thinPrevPartButton);
					s.addChild(prevPartButton);
				}
			}
			currentThinMode = Main.textDisplay.thinMode;
		}
		positionPageButtons();
	}
	public function checkFirstLastPage()
	{
		if(Main.textDisplay.pageNumber == 0)
		{
			if(!firstPage)
			{
				firstPage = true;
				if(Main.textDisplay.thinMode)
				s.removeChild(thinPrevPartButton);
				else
				s.removeChild(prevPartButton);
			}
		}
		else
		{
			if(firstPage)
			{
				firstPage = false;
				if(Main.textDisplay.thinMode)
				s.addChild(thinPrevPartButton);
				else
				s.addChild(prevPartButton);
			}
		}
		if(Main.textDisplay.pageNumber == Main.simHandle.sims.length-1)
		{
			if(!lastPage)
			{
				lastPage = true;
				if(Main.textDisplay.thinMode)
				s.removeChild(thinNextPartButton);
				else
				s.removeChild(nextPartButton);
			}
		}
		else
		{
			if(lastPage)
			{
				lastPage = false;
				if(Main.textDisplay.thinMode)
				s.addChild(thinNextPartButton);
				else
				s.addChild(nextPartButton);
			}
		}
	}
	//Navigation:
	public function createNavigationGraphics()
	{
		
	}
	//Scroll:
	public function createScrollGraphics()
	{
		var colours:Array<Int> = [0x000000, 0x587DA0, 0x2D4052];
		var halfTriangleWidth:Float = 8*Main.calibrationFactor;
		var triangleWidth:Float = 2*halfTriangleWidth;
		for(i in 0...3)
		{
			scrollUpSprites.push(new Sprite());
			scrollUpSprites[i].graphics.lineStyle(1, colours[i], 1, true);
			scrollUpSprites[i].graphics.moveTo(0,halfTriangleWidth);
			scrollUpSprites[i].graphics.lineTo(halfTriangleWidth,0);
			scrollUpSprites[i].graphics.lineTo(triangleWidth,halfTriangleWidth);
			scrollUpSprites[i].graphics.beginFill(0x000000, 0);
			scrollUpSprites[i].graphics.lineStyle(0, 0x000000, 0, true);
			scrollUpSprites[i].graphics.drawRect(0,0,scrollUpSprites[i].width,scrollUpSprites[i].height);
			
			scrollDownSprites.push(new Sprite());
			scrollDownSprites[i].graphics.lineStyle(1, colours[i], 1, true);
			scrollDownSprites[i].graphics.moveTo(0,0);
			scrollDownSprites[i].graphics.lineTo(halfTriangleWidth,halfTriangleWidth);
			scrollDownSprites[i].graphics.lineTo(triangleWidth,0);
			scrollDownSprites[i].graphics.beginFill(0x000000, 0);
			scrollDownSprites[i].graphics.lineStyle(0, 0x000000, 0, true);
			scrollDownSprites[i].graphics.drawRect(0,0,scrollDownSprites[i].width,scrollDownSprites[i].height);
		}
		scrollUpButton = new SimpleButton(scrollUpSprites[0], scrollUpSprites[1], scrollUpSprites[2], scrollUpSprites[1]);
		scrollDownButton = new SimpleButton(scrollDownSprites[0], scrollDownSprites[1], scrollDownSprites[2], scrollDownSprites[1]);
		scrollUpButton.addEventListener(MouseEvent.CLICK, scrollUpOneLine);
		scrollDownButton.addEventListener(MouseEvent.CLICK, scrollDownOneLine);
		positionScrollBar();
		s.addChild(scrollUpButton);
		s.addChild(scrollDownButton);
		
		createScrollSprite();
		
		scrollRectSprite = new Sprite();
		scrollRectSprite.x = scrollUpButton.x+halfTriangleWidth-.5*halfTriangleWidth;
		scrollRectSprite.y = scrollUpButton.y+triangleWidth;
		scrollRectSprite.graphics.beginFill(0x000000, 1);
		scrollRectSprite.graphics.drawRect(0,0,halfTriangleWidth,2*triangleWidth);
		scrollRectMaxHeight = 2*triangleWidth;
		
		createScrollHitArea();
		s.addEventListener(MouseEvent.MOUSE_MOVE, scrollDrag);
		s.addEventListener(MouseEvent.MOUSE_UP, function releaseRect(e:Event){scrollRectGrabbed = false;});
		s.addChild(scrollRectSprite);
	}
	public function createScrollSprite()
	{
		scrollSprite = new Sprite();
		scrollSprite.x = scrollUpButton.x+halfTriangleWidth;
		scrollSprite.y = scrollUpButton.y+triangleWidth;
		scrollSprite.graphics.lineStyle(1, 0x000000, 1, true);
		scrollSprite.graphics.moveTo(0, 0);
		scrollSprite.graphics.lineTo(0, scrollDownButton.y-scrollUpButton.y-1.5*triangleWidth);
		s.addChild(scrollSprite);
	}
	public function createScrollHitArea()
	{
		scrollHitSprite = new Sprite();
		scrollHitSprite.graphics.beginFill(0x000000, 0);
		//scrollHitSprite.graphics.beginFill(0x000000, .2);
		scrollHitSprite.graphics.lineStyle(0, 0x000000, 0, true);
		scrollHitSprite.graphics.drawRect(0, 0, 2*scrollRectSprite.width, scrollSprite.height);
		scrollHitSprite.x = scrollSprite.x-scrollHitSprite.width*.5;
		scrollHitSprite.y = scrollSprite.y;
		//5apps fails unless I include this pointless textfield;
		var tmpSpr = scrollHitSprite;
		var tf:TextField = new TextField();
		tf.selectable = false;
		tf.width = tmpSpr.width;
		tf.height = tmpSpr.height;
		tmpSpr.addChild(tf);
		scrollHitSprite.addEventListener(MouseEvent.MOUSE_DOWN, grabRect);
		s.addChild(scrollHitSprite);
	}
	public function positionScrollBar()
	{
		var fieldRect:Rectangle = Main.textDisplay.getMainFieldRect();
		scrollUpButton.x = fieldRect.x+fieldRect.width+2*scrollUpButton.width;
		scrollUpButton.y = fieldRect.y;
		scrollDownButton.x = scrollUpButton.x;
		scrollDownButton.y = fieldRect.y+fieldRect.height-scrollDownButton.height;
	}
	public function scrollUpOneLine(e:Event)
	{
		setScrollRect(Main.textDisplay.goUpOneLine());
	}
	public function scrollDownOneLine(e:Event)
	{
		setScrollRect(Main.textDisplay.goDownOneLine());
	}
	public function grabRect(e:Event)
	{
		scrollRectGrabbed = true;
		if(s.mouseY>scrollRectSprite.y+scrollRectSprite.height)
		{
			scrollRectSprite.y = s.mouseY-scrollRectSprite.height; 
			Main.textDisplay.setScroll((scrollRectSprite.y-scrollSprite.y)/(scrollSprite.height-scrollRectSprite.height));
		}
		else if(s.mouseY<scrollRectSprite.y)
		{
			scrollRectSprite.y = s.mouseY;
			Main.textDisplay.setScroll((scrollRectSprite.y-scrollSprite.y)/(scrollSprite.height-scrollRectSprite.height));
		}
		scrollRectGrabY = scrollRectSprite.y;
		scrollRectGrabMouseY = s.mouseY;
	}
	public function scrollDrag(e:Event)
	{
		if(scrollRectGrabbed)
		{
			scrollRectSprite.y = scrollRectGrabY+(s.mouseY-scrollRectGrabMouseY);
			scrollRectSprite.y = Math.max(scrollSprite.y, scrollRectSprite.y);
			scrollRectSprite.y = Math.min(scrollSprite.y+scrollSprite.height-scrollRectSprite.height, scrollRectSprite.y);
			Main.textDisplay.setScroll((scrollRectSprite.y-scrollSprite.y)/(scrollSprite.height-scrollRectSprite.height));
		}
	}
	public function setScrollRect(percent:Float)
	{
		scrollRectSprite.y = scrollUpButton.y+triangleWidth+(percent*(scrollSprite.height-scrollRectSprite.height));
	}
	public static function getScrollTurnAndSpaceWidth():Float
	{
		return 2*getTriangleWidth()+3*pageTurnIconRadius*Main.calibrationFactor;
	}
	public static function getScrollAndSpaceWidth():Float
	{
		return 2*getTriangleWidth();
	}
	public function correctScrollRectPosition()
	{
		setScrollRect(Main.textDisplay.getScrollPercentage());
		scrollRectSprite.x = scrollUpButton.x+halfTriangleWidth-.5*halfTriangleWidth;
		scrollRectSprite.height = Math.min(scrollRectMaxHeight,.25*scrollSprite.height);
	}
	public function scrollText(e:MouseEvent)
	{
		excessLastUpdate = Lib.getTimer();
		if(Lib.getTimer()-preventPageTurnActivated>preventPageTurnWait)
		{
			if(Main.textDisplay.mainField.scrollV==Main.textDisplay.mainField.maxScrollV)
			{
				if(e.delta<0 && Main.textDisplay.pageNumber != Main.textDisplay.pageAmount-1)
				excessScrollNext-= e.delta;
				else
				excessScrollNext = 0;
			}
			if(Main.textDisplay.mainField.scrollV==1)
			{
				if(e.delta>0 && Main.textDisplay.pageNumber != 0)
				excessScrollPrev+= e.delta;
				else
				excessScrollPrev = 0;
			}
		}
		else
		{
			preventPageTurnActivated = Lib.getTimer();
		}
		Main.textDisplay.scrollText(e);
		if(excessScrollNext > maxExcess)
		{
			Main.textDisplay.goNextPage();
			excessScrollNext = 0;
			preventPageTurnActivated = Lib.getTimer();
		}
		if(excessScrollPrev > maxExcess)
		{
			Main.textDisplay.goPrevPage();
			excessScrollPrev = 0;
			preventPageTurnActivated = Lib.getTimer();
		}
	}
	public function resizeScrollBar()
	{
		positionScrollBar();
		s.removeChild(scrollSprite);
		s.removeChild(scrollHitSprite);
		createScrollSprite();
		createScrollHitArea();
		correctScrollRectPosition();
	}
	//Text Expand/Contract:
	public function createTextLengthUI()
	{
		var fieldRect:Rectangle = Main.textDisplay.getMainFieldRect();
		var lineY = createTextLengthBar(fieldRect);
		
		var halfTriangleWidth:Float = 8*Main.calibrationFactor;
		var triangleWidth:Float = 2*halfTriangleWidth;
		var colours:Array<Int> = [0x000000, 0x587DA0, 0x2D4052];
		for(i in 0...3)
		{
			textContractSprites.push(new Sprite());
			textContractSprites[i].graphics.lineStyle(1, colours[i], 1, true);
			textContractSprites[i].graphics.moveTo(0,halfTriangleWidth);
			textContractSprites[i].graphics.lineTo(halfTriangleWidth,0);
			textContractSprites[i].graphics.lineTo(triangleWidth,halfTriangleWidth);
			textContractSprites[i].graphics.beginFill(0x000000, 0);
			textContractSprites[i].graphics.lineStyle(0, 0x000000, 0, true);
			textContractSprites[i].graphics.drawRect(0,0,textContractSprites[i].width,textContractSprites[i].height);
			
			textExpandSprites.push(new Sprite());
			textExpandSprites[i].graphics.lineStyle(1, colours[i], 1, true);
			textExpandSprites[i].graphics.moveTo(0,0);
			textExpandSprites[i].graphics.lineTo(halfTriangleWidth,halfTriangleWidth);
			textExpandSprites[i].graphics.lineTo(triangleWidth,0);
			textExpandSprites[i].graphics.beginFill(0x000000, 0);
			textExpandSprites[i].graphics.lineStyle(0, 0x000000, 0, true);
			textExpandSprites[i].graphics.drawRect(0,0,textExpandSprites[i].width,textExpandSprites[i].height);
		}
		textContractButton = new SimpleButton(textContractSprites[0], textContractSprites[1], textContractSprites[2], textContractSprites[1]);
		textExpandButton = new SimpleButton(textExpandSprites[0], textExpandSprites[1], textExpandSprites[2], textExpandSprites[1]);
		textContractButton.x = fieldRect.x+.5*fieldRect.width-halfTriangleWidth;
		textExpandButton.x = textContractButton.x;
		textContractButton.y = lineY+halfTriangleWidth;
		textExpandButton.y = textContractButton.y;
		textContractButton.addEventListener(MouseEvent.CLICK, contractText);
		textExpandButton.addEventListener(MouseEvent.CLICK, expandText);
		//s.addChild(textContractButton);
		s.addChild(textExpandButton);
	}
	public function createTextLengthBar(fieldRect:Rectangle):Float
	{
		textLengthSprite = new Sprite();
		textLengthSprite.graphics.lineStyle(1, 0x000000);
		var fieldRect:Rectangle = Main.textDisplay.getMainFieldRect();
		var lineY:Float = fieldRect.y+fieldRect.height;
		textLengthSprite.graphics.moveTo(fieldRect.x+.25*fieldRect.width,lineY);
		textLengthSprite.graphics.lineTo(fieldRect.x+.75*fieldRect.width,lineY);
		s.addChild(textLengthSprite);
		return lineY;
	}
	public function expandText(?e:Event)
	{
		s.removeChild(textExpandButton);
		s.addChild(textContractButton);
		Main.textDisplay.expandText();
		Main.textDisplay.pages[Main.textDisplay.pageNumber].lastExpanded = 1;
		resizeTextLength();
		resizeScrollBar();
		positionPageButtons();
	}
	public function textExpanded()
	{
		s.removeChild(textExpandButton);
		s.addChild(textContractButton);
		resizeTextLength();
		resizeScrollBar();
		positionPageButtons();
	}
	public function contractText(?e:Event)
	{
		s.removeChild(textContractButton);
		s.addChild(textExpandButton);
		Main.textDisplay.contractText();
		Main.textDisplay.pages[Main.textDisplay.pageNumber].lastExpanded = 2;
		resizeTextLength();
		resizeScrollBar();
		positionPageButtons();
	}
	public function textContracted()
	{
		s.removeChild(textContractButton);
		s.addChild(textExpandButton);
		resizeTextLength();
		resizeScrollBar();
		positionPageButtons();
	}
	public static function getTextLengthUIHeight():Float
	{
		return getTriangleWidth();
	}
	public function resizeTextLength()
	{
		s.removeChild(textLengthSprite);
		var fieldRect:Rectangle = Main.textDisplay.getMainFieldRect();
		var lineY = createTextLengthBar(fieldRect);
		textContractButton.x = fieldRect.x+.5*fieldRect.width-halfTriangleWidth;
		textExpandButton.x = textContractButton.x;
		textContractButton.y = lineY+halfTriangleWidth;
		textExpandButton.y = textContractButton.y;
	}
	//Other:
	public function resize()
	{
		resizeTextLength();
		resizeScrollBar();
		//excessScrollPrevBitmap();
		//excessScrollNextBitmap();
		excessScrollAnimation();
		resizePageButtons();
	}
	public function excessScrollAnimation()
	{
		var inDecay:Bool = false;
		if(excessScrollPrev>0)
		{
			if(Lib.getTimer()-excessLastUpdate > excessWaitTime)
			{
				inDecay = true;
				var percent = (excessScrollPrev-((Lib.getTimer()-excessLastUpdate-excessWaitTime)*excessDecaySpeed))/(maxExcess);
				if(percent <= 0)
				{
					excessScrollPrev = 0;
					percent = 0;
				}
				excessScrollPrevBitmap(percent);
			}
		}
		if(excessScrollPrev!=excessScrollPrevLastFrame && !inDecay)
		{
			excessScrollPrevBitmap();
			excessScrollPrevLastFrame = excessScrollPrev;
		}
		inDecay = false;
		if(excessScrollNext>0)
		{
			if(Lib.getTimer()-excessLastUpdate > excessWaitTime)
			{
				inDecay = true;
				var percent = (excessScrollNext-((Lib.getTimer()-excessLastUpdate-excessWaitTime)*excessDecaySpeed))/(maxExcess);
				if(percent <= 0)
				{
					excessScrollNext = 0;
					percent = 0;
				}
				excessScrollNextBitmap(percent);
			}
		}
		if(excessScrollNext!=excessScrollNextLastFrame && !inDecay)
		{
			excessScrollNextBitmap();
			excessScrollNextLastFrame = excessScrollNext;
		}
	}
	public function excessScrollPrevBitmap(?percent:Float)
	{
		s.removeChild(excessPrevBitmap);
		if(percent == null)
		percent = excessScrollPrev/maxExcess;
		if(Main.textDisplay.thinMode)
		{
			var bmd:BitmapData = new BitmapData(Math.round(thinPrevPartButton.width*percent),Math.round(thinPrevPartButton.height), true, 0x80000000);
			excessPrevBitmap = new Bitmap(bmd);
			excessPrevBitmap.x = thinPrevPartButton.x+(thinPrevPartButton.width-excessPrevBitmap.width);
			excessPrevBitmap.y = thinPrevPartButton.y;
		}
		else
		{
			var bmd:BitmapData = new BitmapData(Math.round(prevPartButton.width),Math.round(prevPartButton.height),0x00000000);
			var clipRect:Rectangle = new Rectangle(excessSprite.width*(1-percent), 0, excessSprite.width, excessSprite.height);
			bmd.draw(excessSprite, null, null, null, clipRect);
			excessPrevBitmap = new Bitmap(bmd);	
			excessPrevBitmap.x = prevPartButton.x+(prevPartButton.width-excessPrevBitmap.width);//prevPartButton.x;
			excessPrevBitmap.y = prevPartButton.y;
		}
		s.addChild(excessPrevBitmap);
	}
	public function excessScrollNextBitmap(?percent:Float)
	{
		s.removeChild(excessNextBitmap);
		if(percent == null)
		percent = excessScrollNext/maxExcess;
		if(Main.textDisplay.thinMode)
		{
			var bmd:BitmapData = new BitmapData(Math.round(thinNextPartButton.width*percent),Math.round(thinNextPartButton.height),true, 0x80000000);
			excessNextBitmap = new Bitmap(bmd);
			excessNextBitmap.x = thinNextPartButton.x;
			excessNextBitmap.y = thinNextPartButton.y;
		}
		else
		{
			var bmd:BitmapData = new BitmapData(Math.round(nextPartButton.width*percent),Math.round(nextPartButton.height),0x00000000);
			bmd.draw(excessSprite);
			excessNextBitmap = new Bitmap(bmd);
			excessNextBitmap.x = nextPartButton.x;
			excessNextBitmap.y = nextPartButton.y;
		}
		s.addChild(excessNextBitmap);
	}
	public function keyDown(e:KeyboardEvent)
	{
		if(e.keyCode == 38)
		{
			contractText();
		}
		if(e.keyCode == 40)
		{
			expandText();
		}
		if(e.keyCode == 39)
		{
			goNextPage();
		}
		if(e.keyCode == 37)
		{
			goPrevPage();
		}
	}
	public function uiUpdate()
	{
		if(!scrollRectGrabbed)
		correctScrollRectPosition();
		excessScrollAnimation();
		checkFirstLastPage();
	}
}
