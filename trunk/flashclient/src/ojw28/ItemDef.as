package ojw28
{
	import flash.xml.*;
	
	public class ItemDef
	{	
		private var	mDefId:Number;
		private var mName:String;
		private var mCategory:String;
		private var mImageFile:String;
		private var mDescription:String;
		private var mHeight:Number;
		private var mFlipable:Boolean;
		private var mFieldLabel:String;
		
		private var mPolys:Array;
		
		private var mBounds:BoundingBox3D;
		
		function ItemDef(iXml:XML) {
			parseXml(iXml);
		}
			
		private function parseXml(iXml:XML)
		{
			mBounds = new BoundingBox3D();
			
			mDefId = iXml.attribute("item_def_id");
			mName = iXml.attribute("name");
			mDescription = iXml.attribute("description");
			mCategory = iXml.attribute("category");
			mHeight = iXml.attribute("height");
			mImageFile = iXml.attribute("image_file");
			mFieldLabel = iXml.attribute("field_label");
						
			mFlipable = false;
			if(iXml.attribute("flipable") == "true")
			{
				mFlipable = true;
			}
			
			var lPolygonsXml:XMLList = iXml.elements();
			mPolys = new Array();
			for each (var lPolyXml in lPolygonsXml)
			{
				var lPoly:ItemDefPoly = new ItemDefPoly(lPolyXml);
				mPolys.push(lPoly);
				mBounds.expandAroundChild(lPoly.getBounds());
			}
		}
		
		public function getItemDefId():Number 
		{
			return mDefId;
		}
		
		public function getPolys():Array
		{
			return mPolys;
		}
		
		public function getBounds():BoundingBox3D
		{
			return mBounds;
		}
		
		public function getHeight():Number
		{
			return mHeight;
		}
			
		public function getFieldLabel():String
		{
			return mFieldLabel;
		}
			
		public function getName():String
		{
			return mName;
		}
		
		public function getCategory():String
		{
			return mCategory;
		}
		
		public function isFlipable():Boolean
		{
			return mFlipable;
		}
		
		public function getDescription():String
		{
			return mDescription;
		}
		
		public function getImageFile():String
		{
			return mImageFile;
		}
		
	}
}