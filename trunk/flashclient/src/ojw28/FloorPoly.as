package ojw28
{
	import flash.xml.*;
	
	public class FloorPoly extends Polygon
{	
	private var mUid:Number;
	private var mConnections:Array;
	private var mParent:Room;
	
	function FloorPoly(iParent:Room, iXml:XML) {
		super(parseXml(iXml));
		mParent = iParent;
	}
	
	public function getContainingRoom():Room
	{
		return mParent;
	}
	
	private function parseXml(iXml:XML):Array
	{
		mUid = Number(iXml.attribute("uid"));
		
		mPoints = new Array();
		mConnections = new Array();
		
		var lVerticesXml:XMLList = iXml.elements();
		var lVertices:Array = new Array();
		var lIdx = 0;
		while(lIdx < lVerticesXml.length())
		{
			lVertices.push(Number(lVerticesXml[lIdx].attribute("x"))*100);
			lVertices.push(Number(lVerticesXml[lIdx].attribute("y"))*100);
			if(lVerticesXml[lIdx].attribute("edgetype") == "connector")
			{
				mConnections.push(true);
			}
			else
			{
				mConnections.push(false);
			}
			lIdx++;
		}
		return lVertices;
	}
		
	function isConnection(iEdgeIndex:Number):Boolean
	{
		return mConnections[iEdgeIndex];
	}
	
	function getUid():Number
	{
		return mUid;
	}
	
}
}