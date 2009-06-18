package ojw28
{
	public class BoundingBox3D
{
	public var minx:Number = Number.MAX_VALUE;
	public var maxx:Number = -Number.MAX_VALUE;
	public var miny:Number = Number.MAX_VALUE;
	public var maxy:Number = -Number.MAX_VALUE;
	
	function expandAroundVertices(iVertices:Array)
	{
		var lIdx:Number = 0;
		while(lIdx < iVertices.length)
		{
			minx = Math.min(minx,iVertices[lIdx]);
			maxx = Math.max(maxx,iVertices[lIdx]);
			miny = Math.min(miny,iVertices[lIdx+1]);
			maxy = Math.max(maxy,iVertices[lIdx+1]);
			lIdx+=2;
		}
	}
	
	function expandAroundChild(iChildBounds:BoundingBox3D)
	{
		minx = Math.min(minx,iChildBounds.minx);
		maxx = Math.max(maxx,iChildBounds.maxx);
		miny = Math.min(miny,iChildBounds.miny);
		maxy = Math.max(maxy,iChildBounds.maxy);	
	}
	
}
}