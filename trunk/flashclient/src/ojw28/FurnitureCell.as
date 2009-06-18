package ojw28
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	
	public class FurnitureCell extends Sprite
	{				
		private var mMask:Sprite;
		private var mFurnitureLayer:Sprite;
		private var mFurnitureSubLayers:Object;
		private var mFurnitureDrawables:Object;
		
		//The bounds of the cell
		private var mMaxX:Number;
		private var mMinX:Number;
		private var mMaxY:Number;
		private var mMinY:Number;
		
		private var mUsingBitmap:Boolean = false;
		private var mBitmapNeedsRefresh:Boolean = false;
		private var mBitmap:Bitmap;
		private var mBitmapHeight:Number;
		private var mBitmapWidth:Number;
		
		private var mItemCount = 0;
				
		public function FurnitureCell(iMinX, iMinY, iMaxX, iMaxY)
		{						
			mMaxX = iMaxX;
			mMinX = iMinX;
			mMaxY = iMaxY;
			mMinY = iMinY;
			
			createMask();
			mFurnitureLayer = new Sprite();
			mFurnitureDrawables = new Object();
			mFurnitureSubLayers = new Object();
			createFurnitureLayer();
			
			mUsingBitmap = true;
		}
		
		public function addPlacedItem(iPlacedItem:PlacedItem, iUpdateBitmap:Boolean)
		{
			mItemCount++;
			createPlacedItemDrawable(iPlacedItem);
			mMask.visible = true;
			
			mBitmapNeedsRefresh = true;
			if(iUpdateBitmap)
			{
				refreshBitmap();
			}
		}
		
		public function removePlacedItem(iItem:PlacedItem, iUpdateBitmap:Boolean)
		{
			var lDrawable:ItemDrawable = mFurnitureDrawables[""+iItem.getLocalId()];
			if(lDrawable != null)
			{
				//Remove the drawable from the furniture layer in which it is inserted
				lDrawable.parent.removeChild(lDrawable);
				//Remove any references to the drawable
				mFurnitureDrawables[""+iItem.getLocalId()] = null;
				mItemCount--;
				
				if(mItemCount == 0)
				{
					mMask.visible = false;
				}
				
				mBitmapNeedsRefresh = true;
				if(iUpdateBitmap)
				{
					refreshBitmap();
				}
			}
		}
		
		private function createMask()
		{
			mMask = new Sprite();
			mMask.graphics.beginFill(0xCCCCCC,0.5);
			mMask.graphics.drawRect(0,0, mMaxX - mMinX, mMaxY - mMinY);			
			mMask.graphics.endFill();
			mMask.x = mMinX;
			mMask.y = mMinY;
			mMask.visible = false;
			addChild(mMask);
		}
		
		private function createFurnitureLayer()
		{
			mFurnitureLayer = new Sprite();
			mFurnitureDrawables = new Object();
			mFurnitureSubLayers = new Object();
		}
		
		/**
		 * Creates an ItemDrawable to represent the specified PlacedItem object,
		 * and inserts it into the furniture layers.
		 */
		private function createPlacedItemDrawable(iItem:PlacedItem)
		{
			var lDrawable:ItemDrawable = new ItemDrawable(iItem);
			lDrawable.addEventListener(MapEvent.DRAG_START, propagateItemEvent, false, 0, true);
			lDrawable.addEventListener(MapEvent.ITEM_OVER, propagateItemEvent, false, 0, true);
			lDrawable.addEventListener(MapEvent.ITEM_OUT, propagateItemEvent, false, 0, true);
			mFurnitureDrawables[""+iItem.getLocalId()] = lDrawable;
			insertPlacedItemDrawable(lDrawable);
		}
				
		/**
		 * Inserts an item drawable into the furniture layers, creating a new layer
		 * if it is the first furniture item to be added at a particular depth.
		 */
		private function insertPlacedItemDrawable(iItem:ItemDrawable)
		{
			var lDepth:Number = iItem.getItem().getItemDef().getHeight();
			if(mFurnitureSubLayers[""+lDepth] == null)
			{
				var lDepthLayer:FurnitureLayer = new FurnitureLayer(lDepth);
				mFurnitureSubLayers[""+lDepth] = lDepthLayer;
				var li:Number = 0;
				for(; li < mFurnitureLayer.numChildren; li++)
				{
					var lLayer:FurnitureLayer = mFurnitureLayer.getChildAt(li);
					if(lLayer.getDepth() > lDepth)
					{
						break;
					}
				}
				mFurnitureLayer.addChildAt(lDepthLayer, li);
			}
			mFurnitureSubLayers[""+lDepth].addChild(iItem);
		}
		
		/**
		 * Propagates item drag events
		 */
		private function propagateItemEvent(iEvent:Event)
		{
			dispatchEvent(iEvent);
		}
		
		public function showAsSprites()
		{
			if(mUsingBitmap)
			{
				if(mBitmap != null)
				{
					mBitmap.mask = null;
					removeChild(mBitmap);
				}
				
				addChild(mFurnitureLayer);
				mFurnitureLayer.mask = mMask;
				mUsingBitmap = false;
			}
		}
		
		public function showAsBitmap()
		{				
			if(!mUsingBitmap)
			{
				mFurnitureLayer.mask = null;
				removeChild(mFurnitureLayer);
				
				if(mBitmapNeedsRefresh)
				{
					createFurnitureBitmap();
				}
								
				if(mBitmap != null)
				{
					mBitmap.mask = mMask;
					addChild(mBitmap);
				}
				mUsingBitmap = true;
			}
		}
		
		public function refreshBitmap():Boolean
		{
			if(!mUsingBitmap)
			{
				return false;
			}
			else
			{
				var lPrevious:Bitmap = mBitmap;
				
				var lUpdated:Boolean = createFurnitureBitmap();
				if(lUpdated)
				{
					if(lPrevious != null)
					{
						lPrevious.mask = null;
						removeChild(lPrevious);						
					}
					if(mBitmap != null)
					{
						mBitmap.mask = mMask;
						addChild(mBitmap);
					}
				}				
				return lUpdated;
			}
		}
		
		public function dropBitmap()
		{
			if(mUsingBitmap)
			{
				if(mBitmap != null)
				{
					mBitmap.mask = null;
					removeChild(mBitmap);
				}
			}
			mBitmap = null;
		}
		
		public function isVisible():Boolean
		{
			return !(mMask.transform.pixelBounds.right < 0 ||
					mMask.transform.pixelBounds.left > stage.stageWidth ||
					mMask.transform.pixelBounds.top > stage.stageHeight ||
					mMask.transform.pixelBounds.bottom < 0);
		}
		
		public function isRenderedAsBitmap():Boolean 
		{
			return mUsingBitmap;
		}
		
		private function createFurnitureBitmap():Boolean
		{
			var iScreenWidth:Number = mMask.transform.pixelBounds.width;
			var iScreenHeight:Number = mMask.transform.pixelBounds.height;
			
			if((mBitmap == null && mItemCount == 0) ||
			   (mBitmap != null && !mBitmapNeedsRefresh && (mBitmapHeight == iScreenHeight && mBitmapWidth == iScreenWidth)))
			{
				//We have already created a suitable bitmap - dont change it
				return false;
			}
			else if(mItemCount == 0)
			{
				mBitmap = null;
				mBitmapNeedsRefresh = false;
				return true;
			}
			else
			{				
				var lScale = Math.min(1,Math.min(Math.min(iScreenHeight,1000)/(mMaxY - mMinY),Math.min(iScreenWidth,1000)/(mMaxX - mMinX)));
				var lBmData:BitmapData = new BitmapData((mMaxX - mMinX + 10)*lScale,(mMaxY - mMinY + 10)*lScale,true,0x00000000);
				lBmData.draw(mFurnitureLayer, new Matrix(lScale,0,0,lScale,-mMinX*lScale,-mMinY*lScale), null, null, null, false);
							
				var lBm:Bitmap = new Bitmap(lBmData,"auto",true);
				lBm.scaleX = 1/lScale;
				lBm.scaleY = 1/lScale;
				
				lBm.x = mMinX;
				lBm.y = mMinY;
			
				mBitmap = lBm;
				mBitmapHeight = iScreenHeight;
				mBitmapWidth = iScreenWidth;
				mBitmapNeedsRefresh = false;
				return true;
			}
		}
				
	}
}

class FurnitureLayer extends flash.display.Sprite
{
	private var mDepth:Number;
	
	function FurnitureLayer(iDepth:Number)
	{
		mDepth = iDepth;
	}
	
	function getDepth():Number
	{
		return mDepth;
	}
}