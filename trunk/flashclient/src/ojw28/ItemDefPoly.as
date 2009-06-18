package ojw28
{
	import flash.xml.*;
	
	public class ItemDefPoly extends Polygon
	{	
		
		private var mFillColour:Number;
		private var mFillAlpha:Number;
		private var mEdgeColour:Number;
		private var mEdgeAlpha:Number;
		
		public function ItemDefPoly(iXml:XML)
		{
			super(parseXml(iXml));
		}
		
		private function parseXml(iXml:XML):Array
		{
			mFillColour = iXml.attribute("fill_colour");
			mFillAlpha = iXml.attribute("fill_alpha");
			mEdgeColour = iXml.attribute("edge_colour");
			mEdgeAlpha = iXml.attribute("edge_alpha");
						
			var lVerticesXml:XMLList = iXml.elements();
			var lVertices:Array = new Array();
			var lIdx = 0;
			while(lIdx < lVerticesXml.length())
			{
				lVertices.push(Number(lVerticesXml[lIdx].attribute("x"))*100);
				lVertices.push(Number(lVerticesXml[lIdx].attribute("y"))*100);
				lIdx++;
			}
			
			return lVertices;
		}
	
		public function getFillColour():Number
		{
			return mFillColour;
		}
		
		public function getFillAlpha():Number
		{
			return mFillAlpha;
		}
		
		public function getEdgeColour():Number
		{
			return mEdgeColour;
		}
		
		public function getEdgeAlpha():Number
		{
			return mEdgeAlpha;
		}
	}
}