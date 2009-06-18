package ojw28
{
	import flash.xml.*;
	import flash.net.*;
	import flash.events.*;
	
	/**
	 * Manages items corresponding to a single floor of the map.
	 */
	public class FloorItemManager extends EventDispatcher
	{					
		private var mFloor:Floor;
		//The most recent update received from the server
		private var mUpdateToken:Number;
		
		private var mUpdateLoader:URLLoader;
		private var mDoingUpdate:Boolean;
		
		private var mErrorRaised:Boolean;
		private var mErrorMessage:String;
		
		private var mItemsBeingAddedToServer:Number = 0;
		private var mServerMappedItems:Object;
		private var mPlacedItems:Array;
		
		public function FloorItemManager(iFloor:Floor)
		{
			mFloor = iFloor;
			mPlacedItems = new Array();
			mServerMappedItems = new Object();
			mUpdateToken = 0;
		}
	
		public function isUpdateInProgress():Boolean 
		{
			return mDoingUpdate;
		}
		
		public function isErrorFlagSet():Boolean
		{
			return mErrorRaised;
		}
		
		public function getErrorMessage():String
		{
			return mErrorMessage;
		}
								
		/**
		 * Called just before a new item is sent to the server. Whilst an item is being sent
		 * no updates from the server are processed. This ensures that an update corresponding
		 * to the new item is not processed, which would result in item duplication.
		 */
		public function notifyStartAddItemToServer()
		{
			mItemsBeingAddedToServer++;
		}
		
		/**
		 * Called after an item has been added to the server (or when the add attempt has failed)
		 */
		public function notifyEndAddItemToServer(iItem:PlacedItem)
		{
			mItemsBeingAddedToServer--;
			addPlacedItem(iItem);
		}
		
		/**
		 * Starts fetching updates from the server. The method has no effect if new items are currently
		 * being sent to the server by the local user, or if another update is already if progress.
		 */
		public function doUpdate()
		{				
			if(!mDoingUpdate && (mItemsBeingAddedToServer == 0))
			{
				mDoingUpdate = true;
				mErrorRaised = false;
				mErrorMessage = null;
			
				mUpdateLoader = new URLLoader();
				mUpdateLoader.addEventListener(Event.COMPLETE, onUpdateReceived);
				mUpdateLoader.addEventListener(IOErrorEvent.IO_ERROR, onUpdateError);

				var lRequest:URLRequest = new URLRequest(Config.SERVLET+"items/fetchupdatesfloor");
				lRequest.data = new URLVariables("lastupdate="+mUpdateToken+"&floor="+mFloor.getUid()+"&time="+Number(new Date().getTime()));
				mUpdateLoader.load(lRequest);
			}
		}
			
		private function onUpdateReceived(evt:Event)
		{
			if(mItemsBeingAddedToServer == 0)
			{
				try
				{
					var lUpdateXml:XML = new XML(mUpdateLoader.data);
					var lTokenStr:String = lUpdateXml.attribute("updatetoken");
					if(lTokenStr != null && lTokenStr.length > 0)
					{
						mUpdateToken = Number(lTokenStr);
						parseUpdateXml(lUpdateXml);
					}					
				}
				catch(error:Error)
				{
					mErrorMessage = "Error decoding placed items";
					mErrorRaised = true;
				}
			}
			mDoingUpdate = false;
		}
		
		private function onUpdateError(evt:Event)
		{
			mErrorRaised = true;
			mDoingUpdate = false;
		}
		
		private function parseUpdateXml(iUpdate:XML)
		{
			for each (var lItemUpdate in iUpdate.elements())
			{
				var lUid:Number = lItemUpdate.attribute("uid");
				var lItemDefId:Number = lItemUpdate.attribute("item_def_id");
				var lX:Number = lItemUpdate.attribute("x");
				var lY:Number = lItemUpdate.attribute("y");
				var lTheta:Number = lItemUpdate.attribute("theta");
				var lLabel:String = lItemUpdate.attribute("label");
				
				var lFlipped:Boolean = false;
				if(lItemUpdate.attribute("flipped") == "true")
				{
					lFlipped = true;
				}
				
				var lDeleted:Boolean = false;
				if(lItemUpdate.attribute("deleted") == "true")
				{
					lDeleted = true;
				}
				
				var lComponent:ItemDef = ComponentLibrary.getSingleton().getComponent(lItemDefId);
				
				if(!lDeleted)
				{
					if(mServerMappedItems[""+lUid] == null)
					{
						var lNew:PlacedItem = new PlacedItem(this,lComponent,false, lUid, mFloor, lX*100, lY*100, lTheta, lFlipped, lLabel);
						addPlacedItem(lNew);
					}
					else
					{
						var lUpdatedItem:PlacedItem = mServerMappedItems[""+lUid];
						lUpdatedItem.setPosition(lX*100,lY*100,lTheta,lFlipped,false);
						lUpdatedItem.setLabel(lLabel,false);
						notifyItemUpdate(lUpdatedItem);
					}
				}
				else
				{
					if(mServerMappedItems[""+lUid] != null)
					{
						var lRemovedItem:PlacedItem = mServerMappedItems[""+lUid];
						removePlacedItem(lRemovedItem);
					}
				}
			}
		}
		
		private function addPlacedItem(iItem:PlacedItem)
		{
			if(iItem.isServerMapped() && mServerMappedItems[""+iItem.getUid()] == null)
			{
				mServerMappedItems[""+iItem.getUid()] = iItem;
				mPlacedItems.push(iItem);
				dispatchEvent(new MapEvent(MapEvent.NEW_ITEM, iItem, false, false));
			}
		}
		
		private function removePlacedItem(iItem:PlacedItem)
		{
			var lIdx:Number = mPlacedItems.indexOf(iItem);
			if(lIdx != -1)
			{
				mPlacedItems.splice(lIdx,1);
				dispatchEvent(new MapEvent(MapEvent.ITEM_REMOVED, iItem, false, false));
			}
			mServerMappedItems[""+iItem.getUid()] = null;
		}
		
		private function notifyItemUpdate(iItem:PlacedItem)
		{
			dispatchEvent(new MapEvent(MapEvent.ITEM_UPDATED, iItem, false, false));			
		}
		
		public function getPlacedItems():Array
		{
			return mPlacedItems;
		}
		
		public function getFloor():Floor
		{
			return mFloor;
		}
		
		
	}
}