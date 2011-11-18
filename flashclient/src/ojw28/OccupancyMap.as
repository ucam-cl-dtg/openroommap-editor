package ojw28
{
	import flash.xml.*;
		
	/**
	 * A class which maps rooms and users. Users may be assigned to multiple rooms, and rooms may
	 * contain mulitple users
	 */
	public class OccupancyMap
	{		
		private var mRoomToUserMap:Object;
		private var mUserToRoomMap:Object;
		
		public function OccupancyMap(iMap:Map, iXml:XML)
		{
			parseXml(iMap, iXml);
		}
				
		private function parseXml(iMap:Map, iXmlNode:XML)
		{
			mRoomToUserMap = new Object();
			mUserToRoomMap = new Object();
			
			//Create a mapping room_id -> room
			var lRoomMap:Object = new Object();
			for each (var lFloor:Floor in iMap.getFloors())
			{
				for each (var lRoom:Room in lFloor.getRooms())
				{
					lRoomMap[""+lRoom.getUid()] = lRoom;
					mRoomToUserMap[""+lRoom.getUid()] = new Array();
				}
			}
			
			for each (var lMapping in iXmlNode.elements())
			{
				var lCrsid:String = lMapping.attribute("crsid");
				var lRoomId:Number = Number(lMapping.attribute("roomid"));
				var lOccupiedRoom:Room = lRoomMap[""+lRoomId];
				if(lOccupiedRoom != null)
				{
					mRoomToUserMap[""+lOccupiedRoom.getUid()].push(lCrsid);
					
					if(mUserToRoomMap[lCrsid] == null)
					{
						mUserToRoomMap[lCrsid] = new Array();
					}
					mUserToRoomMap[lCrsid].push(lOccupiedRoom);
				}
			}
		}
		
		public function getOccupants(iRoom:Room):Array
		{
			return mRoomToUserMap[""+iRoom.getUid()];
		}
		
		public function getRooms(iUser:String):Array
		{
			return mUserToRoomMap[iUser];
		}
		
	}
}