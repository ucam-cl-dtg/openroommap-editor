package ojw28
{
	import flash.xml.*;
	import flash.net.*;
	import flash.events.*;
	
	public class PlacedItem extends flash.events.EventDispatcher
	{	
		private static var LOCAL_ID:Number = 0;
		
		private var mItemDef:ItemDef;
		
		private var mIsNew:Boolean;
		private var mLocalId:Number;
		private var mUid:Number;
		
		private var mX:Number;
		private var mY:Number;
		private var mTheta:Number;
		private var mFloor:Floor;
		private var mLabel:String;
		
		private var mItemManager:FloorItemManager;
		
		private var mLoader:URLLoader;
		private var mAddInProgress:Boolean;
		private var mPendingUpdate:Boolean;
		private var mRemoved:Boolean;
		
		private var mFlipped:Boolean;
		
		private var mBounds:BoundingBox3D;
		
		public function PlacedItem(iItemManager:FloorItemManager, iItemDef:ItemDef, iIsNew:Boolean, iUid:Number, iFloor:Floor, iX:Number, iY:Number, iTheta:Number, iFlipped:Boolean, iLabel:String)
		{			
			mItemManager = iItemManager;
		
			mItemDef = iItemDef;
			mIsNew = iIsNew;
			mUid = iUid;
			mLabel = iLabel;
			mLocalId = LOCAL_ID++;
			mFlipped = iFlipped;
			
			mFloor = iFloor;
			
			mX = iX;
			mY = iY;
			mTheta = iTheta;
			
			updateBounds();
		}
				
		public function getBounds():BoundingBox3D
		{
			return mBounds;
		}
		
		public function getItemDef():ItemDef
		{
			return mItemDef;
		}
		
		public function isServerMapped():Boolean
		{
			return !mIsNew;
		}
		
		public function getUid():Number
		{
			return mUid;
		}
		
		public function getLabel():String
		{
			return mLabel;
		}
		
		public function getLocalId():Number
		{
			return mLocalId;
		}
		
		public function getX():Number
		{
			return mX;
		}
		
		public function getY():Number
		{
			return mY;
		}
		
		public function getTheta():Number
		{
			return mTheta;
		}
				
		public function isFlipped():Boolean
		{
			return mFlipped;
		}
		
		public function getFloor():Floor
		{
			return mFloor;
		}
		
		public function isRemoved():Boolean 
		{
			return mRemoved;
		}
			
		/**
		 * Sets the position of the placed item.
		 */
		public function setPosition(iX:Number, iY:Number, iTheta:Number, iFlipped:Boolean, iSendToServer:Boolean)
		{
			mX = iX;
			mY = iY;
			mTheta = iTheta;
			mFlipped = iFlipped;
			updateBounds();
			dispatchEvent(new MapEvent(MapEvent.ITEM_UPDATED, this, false, false));
			
			if(iSendToServer)
			{
				sendUpdate();
			}
		}
		
		public function setLabel(iLabel:String, iSendToServer:Boolean)
		{
			mLabel = iLabel;
			dispatchEvent(new MapEvent(MapEvent.ITEM_UPDATED, this, false, false));
			
			if(iSendToServer)
			{
				sendUpdate();
			}
		}
		
		/**
		 * Deletes the item and notifies the server.
		 */
		public function deleteItem()
		{
			mRemoved = true;
			mFloor.dispatchEvent(new MapEvent(MapEvent.ITEM_REMOVED, this, false, false));
			sendUpdate();
		}
		
		/**
		 * Sends an update to the server.
		 */
		private function sendUpdate()
		{
			if(!mAddInProgress)
			{
				mPendingUpdate = false;
				if(mIsNew)
				{
					mAddInProgress = true;
					
					mLoader = new URLLoader();
					mLoader.addEventListener(Event.COMPLETE, onAddCompleted);
					mLoader.addEventListener(IOErrorEvent.IO_ERROR, onAddError);
					
					var lRequest:URLRequest = new URLRequest(Config.SERVLET+"items/doadd");
					lRequest.data = "x="+mX/100+"&y="+mY/100+"&theta="+mTheta+"&flipped="+mFlipped+"&label="+mLabel+"&floor="+mFloor.getUid()+"&item_def_id="+mItemDef.getItemDefId()+"&time="+Number(new Date().getTime());
					
					mItemManager.notifyStartAddItemToServer();
					mLoader.load(lRequest);
				}
				else if(!mRemoved)
				{
					mLoader = new URLLoader();
					mLoader.addEventListener(IOErrorEvent.IO_ERROR, onUpdateError);
							
					var lUpdateRequest:URLRequest = new URLRequest(Config.SERVLET+"items/doupdate");
					lUpdateRequest.data = "uid="+mUid+"&x="+mX/100+"&y="+mY/100+"&theta="+mTheta+"&label="+mLabel+"&floor="+mFloor.getUid()+"&flipped="+mFlipped+"&time="+Number(new Date().getTime());
					
					mLoader.load(lUpdateRequest);
				}
				else
				{
					mLoader = new URLLoader();
					mLoader.addEventListener(IOErrorEvent.IO_ERROR, onRemoveError);
							
					var lRemoveRequest:URLRequest = new URLRequest(Config.SERVLET+"items/doremove");
					//Prevents caching
					lRemoveRequest.data = new URLVariables("uid="+mUid+"&time="+Number(new Date().getTime()));
					
					mLoader.load(lRemoveRequest);					
				}
			}
			else
			{
				mPendingUpdate = true;
			}
		}
			
		/**
		 * Callback function - invoked when the item has been added to the server's databse
		 */
		private function onAddCompleted(evt:Event)
		{
			var lAddedXml:XML = new XML(mLoader.data);
			
			var lUidStr:String = lAddedXml.attribute("uid");
			if(lUidStr != null && lUidStr.length > 0)
			{
				mUid = Number(lUidStr);
				mIsNew = false;
			}
			
			mItemManager.notifyEndAddItemToServer(this);
			mAddInProgress = false;
			
			if(mPendingUpdate)
			{
				sendUpdate();
			}
		}
		
		private function onAddError(evt:Event)
		{
			mItemManager.notifyEndAddItemToServer(this);
			mAddInProgress = false;
		}
		
		private function onUpdateError(evt:Event)
		{
		}
		
		private function onRemoveError(evt:Event)
		{
		}
		
		/**
		 * Updates the bounding box of the placed item after it has been moved
		 */
		private function updateBounds()
		{
			var lBounds:BoundingBox3D = new BoundingBox3D();
			for each(var lPoly in mItemDef.getPolys())
			{
				var lTrans:Polygon = null;
				if(mFlipped)
				{
					lTrans = lPoly.getTranslation(mX,mY,mTheta * Math.PI/180,1,-1);
					lBounds.expandAroundChild(lTrans.getBounds());
				}
				else
				{
					lTrans = lPoly.getTranslation(mX,mY,mTheta * Math.PI/180,1,1);
					lBounds.expandAroundChild(lTrans.getBounds());					
				}
			}
			mBounds = lBounds;
		}
		
	}
}