package ojw28
{
	import flash.geom.*;
	import flash.display.*;
	import flash.events.*;
	import fl.controls.Label;
	import flash.text.*;
	
	public class FloorDrawable extends Sprite
	{		
		private var mFloor:Floor;
		
		private var mIsMouseOver:Boolean = false;
		
		private var mZoomLayer:Sprite;
		//An internal layer used to pan the map
		private var mPanLayer:Sprite;
		//The actual rooms are drawn in this layer
		private var mMapLayer:Sprite;
		//Furniture is drawn in this layer
		private var mFurnitureLayer:FurnitureLayerDrawable;
		
		private var mDisplayWidth:Number;
		private var mDisplayHeight:Number;
		
		private var mBackgroundMargin:Number = 150;
		private var mBackgroundFill:Number = 0xF5F5F5;
		private var mBackgroundEdge:Number = 0xBBBBBB;
		private var mRoomFill:Number = 0xEEEEFF;
		private var mRoomEdge:Number = 0x7777DD;
		
		// Constructor function
		public function FloorDrawable(iFloor:Floor,
									   iManager:FloorItemManager,
									  iCentreX:Number, iCentreY:Number,
									  iDisplayWidth:Number, iDisplayHeight:Number)
		{							
			mFloor = iFloor;
			mDisplayWidth = iDisplayWidth;
			mDisplayHeight = iDisplayHeight;
			
			//The zoom layer is centred on the specified centre point, so zooms happen about this position
			mZoomLayer = new Sprite();
			mZoomLayer.x = iCentreX;
			mZoomLayer.y = iCentreY;
			addChild(mZoomLayer);
						
			mPanLayer = new Sprite();
			mZoomLayer.addChild(mPanLayer);
			
			createMapLayer();
						
			mFurnitureLayer  = new FurnitureLayerDrawable(iManager, mBackgroundMargin);
			mFurnitureLayer.addEventListener(MapEvent.ITEM_OVER, propagateEvent, false, 0, true);
			mFurnitureLayer.addEventListener(MapEvent.ITEM_OUT, propagateEvent, false, 0, true);
			mFurnitureLayer.addEventListener(MapEvent.ITEM_SELECTED, propagateEvent, false, 0, true);
			
			mPanLayer.addChild(mFurnitureLayer);
			
			zoomToMap();
			mZoomScaleFactor = getZoom()/100;
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoves, false, 0, true);
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseZoom, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, mouseEnters, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, mouseExits, false, 0, true);
		}
						
								
		/**
		 * Does some work towards inserting furniture items into the furniture layer.
		 */
		public function doItemInsertWork():Number
		{
			return mFurnitureLayer.doItemInsertWork();
		}
		
		/**
		 * Updates a bitmap in the furniture layer.
		 */
		public function updateNextFurnitureBitmap()
		{
			mFurnitureLayer.updateNextBitmap();
		}
		
		private function onMouseMoves(evt:Event)
		{
			mFurnitureLayer.updateMousePosition(mPanLayer.mouseX,mPanLayer.mouseY);
		}
				
		private function mouseEnters(evt:Event)
		{
			//stage.focus = null; 
			mIsMouseOver = true;
		}
		
		private function mouseExits(evt:Event)
		{
			mIsMouseOver = false;
		}
		
		/**
		 * Called when the user rotates the mouse wheel
		 */
		private function onMouseZoom(evt:MouseEvent)
		{
			if(evt.delta > 0)
			{
				setZoom(getZoom() * 1/0.9);
			}
			else
			{
				setZoom(getZoom() * 0.9);
			}
		}
		
		/**
		 * Zooms to fit the whole map in the viewable region
		 */
		public function zoomToMap()
		{
			mPanLayer.x = -(mFloor.getParent().getBounds().maxx + mFloor.getParent().getBounds().minx) / 2;
			mPanLayer.y = -(mFloor.getParent().getBounds().maxy + mFloor.getParent().getBounds().miny) / 2;

			var lScaleX:Number = (mDisplayWidth)/(mFloor.getParent().getBounds().maxx - mFloor.getParent().getBounds().minx + 400);
			var lScaleY:Number = (mDisplayHeight)/(mFloor.getParent().getBounds().maxy - mFloor.getParent().getBounds().miny + 400);
			var mScale:Number = Math.min(lScaleX,lScaleY);
			
			setZoom(mScale);
		}
		
		/**
		 * Zooms to fit the specified room in the viewable region
		 */
		public function zoomToRoom(iRoom:Room)
		{			
			mPanLayer.x = -(iRoom.getBounds().maxx + iRoom.getBounds().minx) / 2;
			mPanLayer.y = -(iRoom.getBounds().maxy + iRoom.getBounds().miny) / 2;
			
			var lScaleX:Number = (mDisplayWidth)/(iRoom.getBounds().maxx - iRoom.getBounds().minx + 400);
			var lScaleY:Number = (mDisplayHeight)/(iRoom.getBounds().maxy - iRoom.getBounds().miny + 400);
			var mScale:Number = Math.min(lScaleX,lScaleY);
	
			setZoom(mScale);
		}
		
		/**
		 * The current zoom factor.
		 */
		public function getZoom():Number
		{
			return mZoomLayer.scaleX;
		}
		
		/**
		 * Set the zoom factor.
		 */
		public function setZoom(iZoom:Number)
		{			
			mZoomLayer.scaleX = iZoom;
			mZoomLayer.scaleY = -iZoom;
			mFurnitureLayer.setZoom(iZoom);
			mFurnitureLayer.updateMousePosition(mPanLayer.mouseX,mPanLayer.mouseY);
		}
		
		/**
		 * The floor corresponding to this drawable.
		 */
		public function getFloor():Floor 
		{
			return mFloor;
		}
		
		/**
		 * Deletes the selected furniture item, or does nothing if no item
		 * is selected.
		 */
		public function deleteSelectedItem()
		{
			mFurnitureLayer.deleteSelectedItem();
		}
				
		/**
		 * The currently selected furniture item, or null.
		 */
		public function getSelectedItem():PlacedItem
		{
			return mFurnitureLayer.getSelectedItem();
		}
		
		/**
		 * Unselects the currently selected furniture item (if there is one selected)
		 */
		public function deSelectItem()
		{
			mFurnitureLayer.deSelectItem();			
		}
		/**
		 * Creates a new PlacedItem of the specified type, creates a corresponding
		 * drawable, and starts a user drag operation to allow the user to drop the
		 * new item onto the editor. The new PlacedItem belongs to the currently
		 * selected room. If no room is selected the function has no effect.
		 */
		public function createItemAndDrag(iComponentId:Number)
		{					
			mFurnitureLayer.createNewItem(iComponentId);
		}
		
		/**
		 * Propagates events.
		 */
		private function propagateEvent(iEvent:MapEvent)
		{
			dispatchEvent(iEvent);
		}
		
		/**
		 * Creates the map layer.
		 */
		private function createMapLayer()
		{		
			mMapLayer = new Sprite();
			mMapLayer.buttonMode = true;
			mMapLayer.addEventListener(MouseEvent.MOUSE_DOWN, onMapPress);
						
			//Draw a filled background region (the size of the whole map, not just this floor)
			var lBounds = mFloor.getParent().getBounds();
			mMapLayer.graphics.lineStyle(0, mBackgroundEdge, 1);
			mMapLayer.graphics.beginFill(mBackgroundFill,1);
			mMapLayer.graphics.moveTo(lBounds.minx - mBackgroundMargin,lBounds.miny - mBackgroundMargin);
			mMapLayer.graphics.lineTo(lBounds.minx - mBackgroundMargin,lBounds.maxy + mBackgroundMargin);
			mMapLayer.graphics.lineTo(lBounds.maxx + mBackgroundMargin,lBounds.maxy + mBackgroundMargin);
			mMapLayer.graphics.lineTo(lBounds.maxx + mBackgroundMargin,lBounds.miny - mBackgroundMargin);
			mMapLayer.graphics.lineTo(lBounds.minx - mBackgroundMargin,lBounds.miny - mBackgroundMargin);
			mMapLayer.graphics.endFill();
			
			for each(var lRoom in mFloor.getRooms())
			{
				var lRoomDrawable:RoomDrawable = new RoomDrawable(lRoom);
				lRoomDrawable.draw(mRoomFill,mRoomEdge);				
				lRoomDrawable.addEventListener(MapEvent.ROOM_OVER, propagateEvent, false, 0, true);
				lRoomDrawable.addEventListener(MapEvent.ROOM_OUT, propagateEvent, false, 0, true);
				mMapLayer.addChild(lRoomDrawable);
			}
			
			mPanLayer.addChild(mMapLayer);
		}
		
		/**
		 * Map dragging
		 */
		private function onMapRelease(evt:Event)
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMapRelease);
			mPanLayer.stopDrag();
			dispatchEvent(new MapEvent(MapEvent.DRAG_STOP, this, false, false));
		}
		
		/**
		 * Map dragging
		 */
		private function onMapPress(evt:Event)
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMapRelease, false, 0, true);
			mPanLayer.startDrag(false);
			dispatchEvent(new MapEvent(MapEvent.DRAG_START, this, false, false));
			mFurnitureLayer.deSelectItem();
		}
		
	}
}