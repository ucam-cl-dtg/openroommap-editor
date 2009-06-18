package ojw28
{
	import flash.display.*;
	
	public class CircleDrawable extends MovieClip
	{
		private var mRadius:Number;
		private var mSegments:Number;
		private var mFillColour:Number;
		private var mFillAlpha:Number;
		private var mEdgeColour:Number;
		private var mEdgeAlpha:Number;
		private var mEdgeWidth:Number;
	
		public function CircleDrawable(iRadius:Number, iSegments:Number, iEdgeWidth:Number, iEdgeColour:Number, iEdgeAlpha:Number, iFillColour:Number, iFillAlpha:Number) {		
			mRadius = iRadius;
			mSegments = iSegments;
			mFillColour = iFillColour;
			mFillAlpha = iFillAlpha;
			mEdgeColour = iEdgeColour;
			mEdgeAlpha = iEdgeAlpha;
			mEdgeWidth = iEdgeWidth;
		}
		
		public function setFillColour(iFillColour:Number, iFillAlpha:Number)
		{
			mFillColour = iFillColour;
			mFillAlpha = iFillAlpha;
			draw();
		}
	
		public function draw(){
			graphics.clear();
			graphics.lineStyle(mEdgeWidth, mEdgeColour, mEdgeAlpha);
			graphics.beginFill(mFillColour,mFillAlpha);
		
			graphics.moveTo(mRadius,0);
			for(var li=0; li<=mSegments; li++)
			{
				var lPointRatio = li/mSegments;
				var xSteps = Math.cos(lPointRatio*2*Math.PI);
				var ySteps = Math.sin(lPointRatio*2*Math.PI);
				var pointX = xSteps * mRadius;
				var pointY = ySteps * mRadius;
				graphics.lineTo(pointX, pointY);
			}
			graphics.endFill();
		}
	}
}