package ojw28
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	
	/**
	 * Renders furniture items placed on a floor in a scalable manner. Furniture
	 * is inserted into a grid of cells. Each cell can be cached as a bitmap for
	 * fast rendering, or each item in a cell can be rendered individually.
	 */
	public class FurnitureLayerDrawable extends Sprite
	{
		private var mMaxCellLength = 1000;
		
		private var mItemManager:FloorItemManager;
		
		private var mCellsX:Number;
		private var mCellsY:Number;
		private var mMinX:Number;
		private var mMinY:Number;
		private var mCellWidth:Number;
		private var mCellHeight:Number;
		private var mCells:Array;
		private var mNextToUpdate:Number = 0;
		
		private var mMouseCellX:Number = -2;
		private var mMouseCellY:Number = -2;
		private var mZoom:Number;
		
		private var mItems:Object;
		private var mSelectedDrawable:ItemDrawable;
		
		private var mNextToInsert:Number = 0;
		private var mInsertFinished:Boolean = false;
		
		public function FurnitureLayerDrawable(iManager:FloorItemManager, iMapMargin:Number)
		{			
			mItemManager = iManager;
			
			//Get the bounds of the entire map (not just the floor)
			var lMapBounds:BoundingBox3D = iManager.getFloor().getParent().getBounds();
			
			mCells = new Array();
			mMinX = lMapBounds.minx - iMapMargin;
			mMinY = lMapBounds.miny - iMapMargin;
			mCellsX = Math.ceil((lMapBounds.maxx - lMapBounds.minx + iMapMargin*2)/mMaxCellLength);
			mCellsY = Math.ceil((lMapBounds.maxy - lMapBounds.miny + iMapMargin*2)/mMaxCellLength);
			mCellWidth = (lMapBounds.maxx - lMapBounds.minx + iMapMargin*2)/mCellsX;
			mCellHeight = (lMapBounds.maxy - lMapBounds.miny + iMapMargin*2)/mCellsY;
		
			//Build the grid of furniture cells
			var lX:Number = mMinX;			
			for(var li:Number = 0; li < mCellsX; li++)
			{
				var lY:Number = mMinY;
				for(var lj:Number = 0; lj < mCellsY; lj++)
				{
					var lCell:FurnitureCell = new FurnitureCell(lX,lY,lX+mCellWidth,lY+mCellHeight);
					lCell.addEventListener(MapEvent.DRAG_START, itemDragStart, false, 0, true);
					lCell.addEventListener(MapEvent.ITEM_OVER, propagateItemEvent, false, 0, true);
					lCell.addEventListener(MapEvent.ITEM_OUT, propagateItemEvent, false, 0, true);
					mCells.push(lCell);
					addChild(lCell);
					
					lY += mCellHeight;
				}
				lX += mCellWidth;
			}			
			mItems = new Object();
		}	
						
		public function doItemInsertWork():Number
		{
			var lItems:Array = mItemManager.getPlacedItems();
			
			var li:Number = 0;
			for(li = mNextToInsert; li < Math.min(mNextToInsert + 100, lItems.length); li++)
			{
				insertPlacedItem(lItems[li],false);				
			}
			
			mNextToInsert = li;
			if(lItems.length == 0)
			{
				//Register to receive item updates
				mItemManager.addEventListener(MapEvent.NEW_ITEM, itemAdded, false, 0, true);
				mItemManager.addEventListener(MapEvent.ITEM_REMOVED, itemRemoved, false, 0, true);
				mItemManager.addEventListener(MapEvent.ITEM_UPDATED, itemUpdated, false, 0, true);
				mInsertFinished = true;
				return 1;
			}
			else
			{
				if(mNextToInsert == lItems.length)
				{
					//Register to receive item updates
					mItemManager.addEventListener(MapEvent.NEW_ITEM, itemAdded, false, 0, true);
					mItemManager.addEventListener(MapEvent.ITEM_REMOVED, itemRemoved, false, 0, true);
					mItemManager.addEventListener(MapEvent.ITEM_UPDATED, itemUpdated, false, 0, true);
					mInsertFinished = true;
					return 1;
				}
				return (mNextToInsert)/lItems.length;
			}
		}
		
		/**
		 * Gets the currently selected item, or null
		 */
		public function getSelectedItem():PlacedItem
		{
			if(mSelectedDrawable != null)
			{
				return mSelectedDrawable.getItem();
			}
			return null;
		}
			
		/**
		 * Creates a new PlacedItem and its graphical representation, then starts a drag operation
		 * to allow the user to place the item
		 */
		public function createNewItem(iComponentId:Number)
		{			
			//Unselect any currently selected itemn
			deSelectItem();
			
			//Create the new item
			var lComponent:ItemDef = ComponentLibrary.getSingleton().getComponent(iComponentId);				
			var lNew:PlacedItem = new PlacedItem(mItemManager,lComponent,true,0,mItemManager.getFloor(),0,0,0,false,"");
			//Insert the new item into the items list
			mItems[lNew.getLocalId()] = lNew;
			//Create a graphical representation
			mSelectedDrawable = new ItemDrawable(lNew);
			mSelectedDrawable.x = mouseX;
			mSelectedDrawable.y = mouseY;
			addChild(mSelectedDrawable);
			mSelectedDrawable.startDragging(mouseX,mouseY);			
			mSelectedDrawable.addEventListener(MapEvent.DRAG_START, reDrag, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);			
			dispatchEvent(new MapEvent(MapEvent.ITEM_SELECTED, lNew, false, false));
		}
		
		/**
		 * Called when an item is added to the floor.
		 */
		private function itemAdded(iEvent:Event)
		{
			var lItem:PlacedItem = iEvent.relatedObject;
			//Check we aren't already drawing this item (which occurs when an item is added locally)
			if(mItems[lItem.getLocalId()] == null)
			{
				insertPlacedItem(lItem,true);
			}
		}
		
		/**
		 * Called when an item is removed from the floor.
		 */
		private function itemRemoved(iEvent:Event)
		{
			var lItem:PlacedItem = iEvent.relatedObject;
			if(mSelectedDrawable != null && mSelectedDrawable.getItem() == lItem)
			{
				//Remove the selected item drawable directly
				mSelectedDrawable.removeEventListener(MapEvent.DRAG_START, reDrag);
				if(mSelectedDrawable.parent == this)
				{
					removeChild(mSelectedDrawable);
				}
				mSelectedDrawable = null;		
				dispatchEvent(new MapEvent(MapEvent.ITEM_SELECTED, null, false, false));		
			}
			else
			{
				//Remove the item from the cells
				removePlacedItem(lItem,true);
			}
			mItems[lItem.getLocalId()] == null;
		}
		
		/**
		 * Called when an item is updated
		 */
		private function itemUpdated(iEvent:Event)
		{
			var lItem:PlacedItem = iEvent.relatedObject;
			if(mSelectedDrawable != null && mSelectedDrawable.getItem() == lItem)
			{
				//Update the selected item directly
				mSelectedDrawable.onItemUpdate();
			}
			else
			{
				//Re-insert the item into the cells
				removePlacedItem(lItem,true);
				insertPlacedItem(lItem,true);
			}
		}					
		
		/**
		 * Propagates mouse over and mouse out events
		 */
		private function propagateItemEvent(iEvent:Event)
		{
			dispatchEvent(iEvent);
		}
						
		/**
		 * Called when the user selects a placed item.
		 */
		private function itemDragStart(evt:Event)
		{		
			var lItem = evt.relatedObject;
			
			//Unselect any item that is currently selected
			deSelectItem();
			//Remove the item from the cells
			removePlacedItem(lItem,true);
			
			//Create a new drawable for the item
			mSelectedDrawable = new ItemDrawable(lItem);
			addChild(mSelectedDrawable);
			//Start dragging
			mSelectedDrawable.startDragging(mouseX,mouseY);
			mSelectedDrawable.addEventListener(MapEvent.DRAG_START, reDrag, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			dispatchEvent(new MapEvent(MapEvent.ITEM_SELECTED, mSelectedDrawable.getItem(), false, false));
		}
		
		/**
		 * Called when the user starts dragging the currently selected item
		 */
		private function reDrag(evt:Event)
		{
			mSelectedDrawable.startDragging(mouseX,mouseY);			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
						
		/**
		 * Updates the item being dragged
		 */
		private function updateDragging(evt:Event) {
			mSelectedDrawable.updateDragging(mouseX,mouseY);
		}
		
		/**
		 * Stops the current drag operation
		 */
		private function stopDragging(evt:Event) 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateDragging);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			mSelectedDrawable.stopDragging(mZoom);
		}
						
		/**
		 * Deselects the currently selected object
		 */
		public function deSelectItem()
		{
			if(mSelectedDrawable != null)
			{
				mSelectedDrawable.removeEventListener(MapEvent.DRAG_START, reDrag);
				removeChild(mSelectedDrawable);				
				if(!mSelectedDrawable.getItem().isRemoved())
				{
					insertPlacedItem(mSelectedDrawable.getItem(),true);
				}
				mSelectedDrawable = null;
				dispatchEvent(new MapEvent(MapEvent.ITEM_SELECTED, null, false, false));
			}
		}
						
		/**
		 * Deletes the currently selected object
		 */
		public function deleteSelectedItem()
		{
			if(mSelectedDrawable != null)
			{
				mSelectedDrawable.getItem().deleteItem();
				deSelectItem();
			}
		}
						
		/**
		 * Called when the mouse moves. Updates which cells are drawn as sprites
		 * and which are rendered as cached bitmaps.
		 */
		public function updateMousePosition(iMouseX:Number,iMouseY:Number)
		{
			if(mInsertFinished)
			{
				var lX:Number = Math.floor((mouseX - mMinX)/mCellWidth);
				var lY:Number = Math.floor((mouseY - mMinY)/mCellHeight);	
				if(lX != mMouseCellX || lY != mMouseCellY)
				{
					var li:Number = 0;
					var lj:Number = 0;
					for(li = Math.max(0,mMouseCellX-1); li < Math.min(mCellsX,mMouseCellX+2); li++)
					{
						for(lj = Math.max(0,mMouseCellY-1); lj < Math.min(mCellsY,mMouseCellY+2); lj++)
						{
							//Don't bother showing bitmaps for the cells we are about to render as sprites
							if(Math.abs(lX - li) > 1 || Math.abs(lY - lj) > 1)
							{
								mCells[li*mCellsY + lj].showAsBitmap();									
							}				
						}
					}
					mMouseCellX = lX;
					mMouseCellY = lY;
					for(li = Math.max(0,mMouseCellX-1); li < Math.min(mCellsX,mMouseCellX+2); li++)
					{
						for(lj = Math.max(0,mMouseCellY-1); lj < Math.min(mCellsY,mMouseCellY+2); lj++)
						{
							mCells[li*mCellsY + lj].showAsSprites();						
						}
					}
				}
			}
		}
		
		/**
		 * Called when the zoom is changed by the user.
		 */
		public function setZoom(iZoom:Number)
		{
			mZoom = iZoom;
			if(mSelectedDrawable != null)
			{
				mSelectedDrawable.notifyMapZoom(mouseX,mouseY,iZoom);
			}
		}
		
		/**
		 * Tries to find a cached bitmap that requires an update. When one is found,
		 * it is updated.
		 */
		public function updateNextBitmap()
		{
			mToUpdateStart = mNextToUpdate;
			var lGotOne:Boolean = false;
			
			var lToUpdate:FurnitureCell = null;
			while(!lGotOne)
			{
				lGotOne = true;
				lToUpdate = mCells[mNextToUpdate++];
				
				if(!lToUpdate.isRenderedAsBitmap())
				{
					lGotOne = false;
				}
				else if (!lToUpdate.isVisible())
				{
					//The bitmap is outside the viewable region. Drop it?
					lToUpdate.dropBitmap();
					lGotOne = false;
				}
				else
				{
					var lWasUpdated:Boolean = lToUpdate.refreshBitmap();
					if(!lWasUpdated)
					{
						//Didn't need the update
						lGotOne = false;
					}
				}
				
				mNextToUpdate = mNextToUpdate % mCells.length;
				if(mNextToUpdate == mToUpdateStart)
				{
					return;
				}
			}
		}		
						
		/**
		 * Removes a placed item from all furniture cells
		 */
		private function removePlacedItem(iItem:PlacedItem, iUpdateBitmap:Boolean)
		{
			for(var li:Number = 0; li < mCells.length; li++)
			{
				mCells[li].removePlacedItem(iItem, iUpdateBitmap);
			}		
		}
		
		/**
		 * Inserts a placed item into the furniture cells which it overlaps
		 */
		private function insertPlacedItem(iItem:PlacedItem, iUpdateBitmap:Boolean)
		{
			var lMinCellX:Number = Math.floor((iItem.getBounds().minx - mMinX)/mCellWidth);
			var lMinCellY:Number = Math.floor((iItem.getBounds().miny - mMinY)/mCellHeight);
			var lMaxCellX:Number = Math.floor((iItem.getBounds().maxx - mMinX)/mCellWidth);
			var lMaxCellY:Number = Math.floor((iItem.getBounds().maxy - mMinY)/mCellHeight);
			for(var li:Number = Math.max(0,lMinCellX); li < Math.min(lMaxCellX+1,mCellsX); li++)
			{
				for(var lj:Number = Math.max(0,lMinCellY); lj < Math.min(lMaxCellY+1,mCellsY); lj++)
				{
					mCells[li*mCellsY + lj].addPlacedItem(iItem,iUpdateBitmap);	
				}
			}
		}
				
	}
}