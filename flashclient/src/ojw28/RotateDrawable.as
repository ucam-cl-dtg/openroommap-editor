package ojw28
{
	import flash.display.*;
	import flash.events.*;
	
	public class RotateDrawable extends Sprite
	{	
		private var lLen:Number = 50;
		private var lRadius:Number = 8;
			
		private var mInner:Sprite;
		private var mDragger:Sprite;
		private var mFlipper:Sprite;
		
		private var mShowFlipper:Boolean;
	
		public function RotateDrawable(iFlipable:Boolean) {		
			mInner = new CircleDrawable(2,8,0,0x000000,1,0x000000,1);
			mInner.mouseEnabled = false;
			addChild(mInner);
			
			mDragger = new CircleDrawable(lRadius,20,0,0x000000,1,0xFF6600,0.6);
			addChild(mDragger);
			
			mShowFlipper = iFlipable;
			if(mShowFlipper)
			{
				mFlipper = new Sprite();
				addChild(mFlipper);
				mFlipper.addEventListener(MouseEvent.MOUSE_DOWN, doFlip);
				mFlipper.addEventListener(MouseEvent.ROLL_OVER, flipperOver);
				mFlipper.addEventListener(MouseEvent.ROLL_OUT, flipperOut);
			}
			
			mDragger.addEventListener(MouseEvent.MOUSE_DOWN, startRotate);
			mDragger.addEventListener(MouseEvent.ROLL_OVER, draggerOver);
			mDragger.addEventListener(MouseEvent.ROLL_OUT, draggerOut);
			
			draw();
		}	
		
		private function draw() {
			
			mouseEnabled = false;
			
			var lRotateCentreY = lLen;
			mDragger.y = lRotateCentreY;
			
			graphics.lineStyle(0, 0x000000, 1);
			graphics.moveTo(0,0);
			graphics.lineTo(0,lRotateCentreY - lRadius);

			graphics.moveTo(lLen, 0);
			for(var i=1; i<=50; i++)
			{
				var pointRatio = i/50;
				var xSteps = Math.cos(pointRatio*2*Math.PI);
				var ySteps = Math.sin(pointRatio*2*Math.PI);
				var pointX = xSteps * lLen;
				var pointY = ySteps * lLen;
				if(i % 2 == 0)
				{
					graphics.lineTo(pointX, pointY);
				}
				else
				{
					graphics.moveTo(pointX, pointY);
				}
			}
			graphics.endFill();
						
			if(mShowFlipper)
			{
				drawFlipper("0x0066FF",0.6);
			}
			
			mInner.draw();
			mDragger.draw();
		}
		
		private function drawFlipper(iColour:Number, iAlpha:Number)
		{
			mFlipper.graphics.clear();
			mFlipper.graphics.lineStyle(0, 0x000000, 1);
			mFlipper.graphics.beginFill(iColour,iAlpha);
			mFlipper.graphics.moveTo(lLen-8,-8);
			mFlipper.graphics.lineTo(lLen+8,-8);
			mFlipper.graphics.lineTo(lLen+8,8);
			mFlipper.graphics.lineTo(lLen-8,8);
			mFlipper.graphics.lineTo(lLen-8,-8);
			mFlipper.graphics.endFill();			
		}
		
		private function startRotate(evt:MouseEvent)
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stopRotate);
			dispatchEvent(new MapEvent(MapEvent.ROTATE_START, null, false, false));
		}
		
		private function stopRotate(evt:MouseEvent)
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopRotate);
			dispatchEvent(new MapEvent(MapEvent.ROTATE_STOP, null, false, false));
		}
		
		private function draggerOver(evt:MouseEvent)
		{
			mDragger.setFillColour(0xFF6600,1);
		}
		
		private function draggerOut(evt:MouseEvent)
		{
			mDragger.setFillColour(0xFF6600,0.6);
		}
		
		private function doFlip(evt:MouseEvent)
		{
			dispatchEvent(new MapEvent(MapEvent.FLIP, null, false, false));
		}
		
		private function flipperOver(evt:MouseEvent)
		{
			drawFlipper("0x0066FF",1);
		}
		
		private function flipperOut(evt:MouseEvent)
		{
			drawFlipper("0x0066FF",0.6);
		}
		
	}
}