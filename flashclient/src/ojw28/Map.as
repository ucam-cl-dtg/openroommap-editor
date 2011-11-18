package ojw28
{
	import flash.xml.*;
	
	public class Map
	{
		private static var mSingleton:Map;
		
		private var mIndexedFloors:Object;
		private var mFloorNames:Array;
		private var mFloors:Array;
		private var mOccupancy:OccupancyMap;
		private var mBounds:BoundingBox3D;
		
		function Map(iXml:XML)
		{
			parseXml(iXml);
		}
		
		public static function getSingleton():Map
		{
			return mSingleton;
		}
		
		public static function initSingleton(iXml:XML)
		{
			mSingleton = new Map(iXml);
		}
		
		public function getOccupancyMap():OccupancyMap
		{
			return mOccupancy;
		}
		
		public function getUsersRooms(iUser:String):Array
		{
			if(mOccupancy == null)
			{
				return null;
			}
			return mOccupancy.getRooms(iUser)
		}
		
		private function parseXml(iXml:XML)
		{
			mIndexedFloors = new Object();
			mIndexedRooms = new Object();
			
			mFloorNames = new Array();
			mFloors = new Array();
			
			mBounds = new BoundingBox3D();
			
			var lMapXml:XMLList = (iXml.elements()[0]).elements();	
			for each (var lFloorXml in lMapXml)
			{
				var lFloor:Floor = new Floor(this, lFloorXml);
				mBounds.expandAroundChild(lFloor.getBounds());
				
				mIndexedFloors[""+lFloor.getUid()] = lFloor;
				mFloors.push(lFloor);
			}
			
			var lOccupancyXml:XML = iXml.elements()[1];
			mOccupancy = new OccupancyMap(this, lOccupancyXml);			
		}
		
		public function getFloorNames():Array
		{
			return mFloorNames;
		}
		
		public function getFloors():Array
		{
			return mFloors;
		}
		
		public function getFloor(iUid:Number):Floor
		{
			return mIndexedFloors[""+iUid];
		}
		
		public function getBounds():BoundingBox3D
		{
			return mBounds;
		}
		
	}
}