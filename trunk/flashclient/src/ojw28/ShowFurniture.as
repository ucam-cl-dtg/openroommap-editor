package ojw28
{
	import flash.geom.Rectangle;
	import mx.controls.*;
	import flash.display.*;

public class ShowFurniture
{
	// The timeline which to create content
	private var mBase:MovieClip;
	
	private var mWidth = 164;
	private var mHeight = 65;
		
	// Constructor function
	public function ShowFurniture(iBase:MovieClip)
	{
		mBase = iBase;
	}
	
	public function drawItem(iItem:ItemDef)
	{		
		var mScaleX:Number = (1.0 * mWidth)/(iItem.getBounds().maxx - iItem.getBounds().minx);
		var mScaleY:Number = (1.0 * mHeight)/(iItem.getBounds().maxy - iItem.getBounds().miny);
		var mScale:Number = Math.min(mScaleX,mScaleY);
		var mMinX:Number = iItem.getBounds().minx;
		var mMinY:Number = -iItem.getBounds().maxy;
		
		var mXOffset = (mWidth - (iItem.getBounds().maxx - iItem.getBounds().minx)*mScale) / 2.0;
		var mYOffset = (mHeight + (iItem.getBounds().miny - iItem.getBounds().maxy)*mScale) / 2.0;
		
		mBase.graphics.clear();
			
		var lPolys:Array = iItem.getPolys();
		for(var lPolyIdx in lPolys)
		{
			var mPoints:Array = lPolys[lPolyIdx].getVertices();
			var idx:Number = 2;
		
			mBase.graphics.lineStyle(0, lPolys[lPolyIdx].getEdgeColour(), lPolys[lPolyIdx].getEdgeAlpha());
			mBase.graphics.beginFill(lPolys[lPolyIdx].getFillColour(),lPolys[lPolyIdx].getFillAlpha());
			mBase.graphics.moveTo((mPoints[0]-mMinX)*mScale + mXOffset, (-mPoints[1]-mMinY)*mScale + mYOffset);
			while(idx < mPoints.length)
			{
				mBase.graphics.lineTo((mPoints[idx]-mMinX)*mScale + mXOffset,(-mPoints[idx+1]-mMinY)*mScale + mYOffset);
				idx+=2;
			}
			mBase.graphics.lineTo((mPoints[0]-mMinX)*mScale + mXOffset,(-mPoints[1]-mMinY)*mScale + mYOffset);
			mBase.graphics.endFill();
		}
		
	}
}

}