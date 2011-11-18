package ojw28
{
	public class Polygon
{	
	private var mPoints:Array;
	private var mBounds:BoundingBox3D;
	//private var mCentroid:Array;
	
	function Polygon(iVertices:Array) {
		mPoints = iVertices;
		mBounds = new BoundingBox3D();
		mBounds.expandAroundVertices(iVertices);
		
		//mCentroid = computeCentroid();
	}
	
	function getVertices():Array {
		return mPoints;
	}
	
	public function getTranslation(iX:Number, iY:Number, iTheta:Number, iScaleX:Number, iScaleY:Number):Polygon
	{
		var lPoints:Array = new Array();
		for(var li = 0; li < mPoints.length; li+=2)
		{
			lPoints.push(Math.cos(iTheta)*iScaleX*mPoints[li] - Math.sin(iTheta)*iScaleY*mPoints[li+1] + iX);
			lPoints.push(Math.cos(iTheta)*iScaleY*mPoints[li+1] + Math.sin(iTheta)*iScaleX*mPoints[li] + iY);
		}
		return new Polygon(lPoints);
	}
	
	public function isContainedBy(iPoly:Polygon):Boolean
	{		
		if(iPoly.getBounds().maxx < (mBounds.maxx) ||
			iPoly.getBounds().maxy < (mBounds.maxy) ||
			iPoly.getBounds().minx > (mBounds.minx) ||
			iPoly.getBounds().miny > (mBounds.miny))
		{
			return false;
		}
		
		//Check no edge intersects
		for(var li:Number = 0; li < mPoints.length; li+=2)
		{
			if(!(iPoly.isInside2D(mPoints[li],mPoints[li+1])))
			{
				return false;
			}
			
			for(var lj:Number = 0; lj < iPoly.getVertices().length; lj+=2)
			{
				if(doLinesIntersect(li,iPoly.getVertices(),lj))
				{
					return false;
				}
			}
		}
		return true;
	}
	
	function doLinesIntersect(iStartIdx:Number,iOtherVertices:Array,lj:Number):Boolean
	{
		//var mMinX = Math.min(iOtherVertices[lj], iOtherVertices[(lj+3) % iOtherVertices.length]);
		//var mMinY = Math.min(iOtherVertices[lj+1], iOtherVertices[(lj+4) % iOtherVertices.length]);
		//var mMaxX = Math.max(iOtherVertices[lj], iOtherVertices[(lj+3) % iOtherVertices.length]);
		//var mMaxY = Math.max(iOtherVertices[lj+1], iOtherVertices[(lj+4) % iOtherVertices.length]);
		/*if((mPoints[iStartIdx] < mMinX && mPoints[(iStartIdx+3) % mPoints.length] < mMinX) ||
			(mPoints[iStartIdx] > mMaxX && mPoints[(iStartIdx+3) % mPoints.length] > mMaxX) ||
			(mPoints[iStartIdx+1] < mMinY && mPoints[(iStartIdx+4) % mPoints.length] < mMinY) ||
			(mPoints[iStartIdx+1] > mMaxY && mPoints[(iStartIdx+4) % mPoints.length] > mMaxY))
		{
			//No intersection
			return false;
		}*/
		
		var mDiffX = iOtherVertices[(lj+3) % iOtherVertices.length] - iOtherVertices[lj];
		var mDiffY = iOtherVertices[(lj+4) % iOtherVertices.length] - iOtherVertices[lj+1];
		
		var lDiffX = mPoints[(iStartIdx+3) % mPoints.length]-mPoints[iStartIdx];
		var lDiffY = mPoints[(iStartIdx+4) % mPoints.length]-mPoints[iStartIdx+1];
		var lDenominator = lDiffY*mDiffX - lDiffX*mDiffY;
		
		if(lDenominator == 0)
		{
			//Lines are parallel
			return false;
		}
		
		var lDiffX2 = iOtherVertices[lj]-mPoints[iStartIdx];
		var lDiffY2 = iOtherVertices[lj+1]-mPoints[iStartIdx+1];
		var lNumeratorA = lDiffX*lDiffY2 - lDiffY*lDiffX2;
		var lNumeratorB = mDiffX*lDiffY2 - mDiffY*lDiffX2;
				
		if(lDenominator < 0)
		{
			if(lNumeratorA >= 0 || lNumeratorB >= 0 || lNumeratorA <= lDenominator || lNumeratorB <= lDenominator)
			{
				//Segments do not overlap
				return false;
			}
		}
		else if(lNumeratorA <= 0 || lNumeratorB <= 0 || lNumeratorA >= lDenominator || lNumeratorB >= lDenominator)
		{
			//Segments do not overlap
			return false;
		}

		return true;
	}
	
	function isInside2D(iX:Number, iY:Number):Boolean
	{
		var lCrossings:Number = 0;
		var lCrossings2:Number = 0;
		for(var li:Number = 0; li < mPoints.length - 2; li+=2)
		{
			lCrossings += pointCrossingsForLine(iX,iY,
					mPoints[li],mPoints[li + 1],
					mPoints[li + 2],mPoints[li + 3]);
			lCrossings2 += pointCrossingsForLine2(iX,iY,
					mPoints[li],mPoints[li + 1],
					mPoints[li + 2],mPoints[li + 3]);
		}
		lCrossings += pointCrossingsForLine(iX,iY,
				mPoints[mPoints.length - 2],mPoints[mPoints.length - 1],
				mPoints[0],mPoints[1]);
		lCrossings2 += pointCrossingsForLine2(iX,iY,
				mPoints[mPoints.length - 2],mPoints[mPoints.length - 1],
				mPoints[0],mPoints[1]);
		return ((lCrossings % 2) == 1) || ((lCrossings2 % 2) == 1);
	}
	
    /**
     * Calculates the number of times the line from (x0,y0) to (x1,y1)
     * crosses the ray extending to the right from (iPosition[0],iPosition[1]).
     * If the point lies on the line, then no crossings are recorded.
     * +1 is returned for a crossing where the Y coordinate is increasing
     * -1 is returned for a crossing where the Y coordinate is decreasing
     */
    function pointCrossingsForLine(iX:Number, iY:Number,
                                      x0:Number, y0:Number,
                                      x1:Number, y1:Number):Number
    {
        if (iY <  y0 && iY <  y1) return 0;
        if (iY >= y0 && iY >= y1) return 0;
        if (iX >= x0 && iX >= x1) return 0;
        if (iX <  x0 && iX <  x1) return 1;
        var xintercept:Number = x0 + (iY - y0) * (x1 - x0) / (y1 - y0);
        if (iX >= xintercept) return 0;
        return 1;
    }
	
    /**
     * Calculates the number of times the line from (x0,y0) to (x1,y1)
     * crosses the ray extending to the right from (iPosition[0],iPosition[1]).
     * If the point lies on the line, then no crossings are recorded.
     * +1 is returned for a crossing where the Y coordinate is increasing
     * -1 is returned for a crossing where the Y coordinate is decreasing
     */
    function pointCrossingsForLine2(iX:Number, iY:Number,
                                      x0:Number, y0:Number,
                                      x1:Number, y1:Number):Number
    {
        if (iY <=  y0 && iY <=  y1) return 0;
        if (iY > y0 && iY > y1) return 0;
        if (iX > x0 && iX > x1) return 0;
        if (iX <=  x0 && iX <=  x1) return 1;
        var xintercept:Number = x0 + (iY - y0) * (x1 - x0) / (y1 - y0);
        if (iX >= xintercept) return 0;
        return 1;
    }
	
	public function getBounds():BoundingBox3D
	{
		return mBounds;
	}
	
	/*public function getCentroid():Array
	{
		return mCentroid;
	}	*/
	
	/**
	 * Internal method used to compute the centroid of the polygon after it is constructed.
	 * @return The centroid of the polygon
	 */
	/*private function computeCentroid():Array
	{
		var lAcc:Number = 0;
		
		var lX:Number = 0;
		var lY:Number = 0;
		var lZ:Number = 0;
		
		for(var li = 0; li < mPoints.length-3; li+=3)
		{
			var lArea:Number = computeTriangleArea(li);
			if(lArea != 0)
			{
				lAcc += lArea;
				var lCentroid:Array = computeTriangleCentroid(li);
				lX += lArea*lCentroid[0];
				lY += lArea*lCentroid[1];
				lZ += lArea*lCentroid[2];
			}
		}
		lX /= lAcc;
		lY /= lAcc;
		lZ /= lAcc;
		
		var lCentroidAcc:Array = new Array();
		lCentroidAcc.push(lX);
		lCentroidAcc.push(lY);
		lCentroidAcc.push(lZ);
		
		return lCentroidAcc;
	}
	*/
	/**
	 * Computes the area of the triangle [v_0,v_iIndex,v_(iIndex+1)]
	 * @param iIndex The index of the second vertex
	 * @return The area of the triangle
	 */
	/*private function computeTriangleArea(iIndex:Number)
	{
		var lFirstX:Number = mPoints[iIndex] - mPoints[0];
		var lFirstY:Number = mPoints[iIndex+1] - mPoints[1];
		var lFirstZ:Number = mPoints[iIndex+2] - mPoints[2];
		var lSecondX:Number = mPoints[iIndex+3] - mPoints[0];
		var lSecondY:Number = mPoints[iIndex+4] - mPoints[1];
		var lSecondZ:Number = mPoints[iIndex+5] - mPoints[2];
		
		var lCrossProdX:Number = lFirstY*lSecondZ - lFirstZ*lSecondY;
		var lCrossProdY:Number = lFirstZ*lSecondX - lFirstX*lSecondZ;
		var lCrossProdZ:Number = lFirstX*lSecondY - lFirstY*lSecondX;
		
		var lLen = Math.sqrt(lCrossProdX*lCrossProdX + lCrossProdY*lCrossProdY + lCrossProdZ*lCrossProdZ);
		return lLen/2.0;
	}*/
	
	/**
	 * Computes the centroid of the triangle [v_0,v_iIndex,v_(iIndex+1)]
	 * @param iIndex The index of the second vertex
	 * @return The centroid of the triangle
	 */
	/*private function computeTriangleCentroid(iIndex:Number):Array
	{
		var lC:Array = new Array();
		var lX:Number = mPoints[0];
		var lY:Number = mPoints[1];
		var lZ:Number = mPoints[2];
		lX += mPoints[iIndex+0];
		lY += mPoints[iIndex+1];
		lZ += mPoints[iIndex+2];
		lX += mPoints[iIndex+3];
		lY += mPoints[iIndex+4];
		lZ += mPoints[iIndex+5];
		lX /= 3.0;
		lY /= 3.0;
		lZ /= 3.0;
		lC.push(lX);
		lC.push(lY);
		lC.push(lZ);
		return lC;
	}*/
	
}
}