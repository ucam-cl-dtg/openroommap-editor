package ojw28
{
	import flash.xml.*;
	import flash.events.*;
	import flash.net.*;
	
	public class Floor extends EventDispatcher
	{	
		private var mParent:Map;
	
		private var mLevel:Number;
		private var mName:String;
		private var mRooms:Array;
		private var mBounds:BoundingBox3D;
		
		private var mPlacedItems:Array;
		
		public function Floor(iParent:Map, iXml:XML)
		{
			mParent = iParent;
			mFurniture = new Array();
			mPlacedItems = new Array();
			parseXml(iXml);
		}
		
		private function parseXml(iXmlNode:XML)
		{
			mName = iXmlNode.attribute("name");
			mLevel = iXmlNode.attribute("level");
			mRooms = new Array();
			mBounds = new BoundingBox3D();
			
			for each (var lItem in iXmlNode.elements())
			{
				var lRoom:Room = new Room(this, lItem);
				mBounds.expandAroundChild(lRoom.getBounds());
				mRooms.push(lRoom);
			}
		}
				
		public function getUid():Number
		{
			return mLevel;
		}
		
		public function getRooms():Array
		{
			return mRooms;
		}
		
		public function getName():String
		{
			return mName;
		}
		
		public function getParent():Map
		{
			return mParent;
		}
		
		public function getBounds():BoundingBox3D
		{
			return mBounds;
		}
		
		public function addPlacedItem(iItem:PlacedItem)
		{
			mPlacedItems.push(iItem);
			dispatchEvent(new MapEvent(MapEvent.NEW_ITEM, iItem, false, false));
		}
		
		public function removePlacedItem(iItem:PlacedItem)
		{
			var lIdx:Number = mPlacedItems.indexOf(iItem);
			if(lIdx != -1)
			{
				mPlacedItems.splice(lIdx,1);
				dispatchEvent(new MapEvent(MapEvent.ITEM_REMOVED, iItem, false, false));
			}
		}
		
		public function notifyItemUpdate(iItem:PlacedItem)
		{
			dispatchEvent(new MapEvent(MapEvent.ITEM_UPDATED, iItem, false, false));			
		}
		
		public function getPlacedItems():Array
		{
			return mPlacedItems;
		}
		
				
	}
}