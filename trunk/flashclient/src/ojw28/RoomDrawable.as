package ojw28
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	
	public class RoomDrawable extends MovieClip
	{
		private var mRoom:Room;
		private var mFillColour:Number;
		private var mMouseDown:Boolean = false;
				
		private var mFurnitureLayer:Sprite;
		private var mFurnitureSubLayers:Object;
		private var mFurnitureDrawables:Object;
		
		public function RoomDrawable(iRoom:Room)
		{
			mRoom = iRoom;
						
			addEventListener(MouseEvent.MOUSE_DOWN, mouseClickStart, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, mouseClickEnd, false, 0, true);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseClickCancel, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, mouseRoll, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseRollOut, false, 0, true);
		}
		
		public function getRoom():Room
		{
			return mRoom;
		}
		
		public function draw(iFillColour:Number, iEdgeColour:Number)
		{
			while(numChildren > 0 )
       		{
				removeChildAt( 0 );
			}
			graphics.clear();
			
			graphics.lineStyle(0, iEdgeColour, 1);
			graphics.beginFill(iFillColour,1);
		
			var lPolys:Array = mRoom.getFloorPolys();
			for(var lIdx in lPolys)
			{
				var mPoints:Array = lPolys[lIdx].getVertices();
				graphics.moveTo((mPoints[0]), (mPoints[1]));
				var idx:Number = 2;
				while(idx < mPoints.length)
				{
					if(lPolys[lIdx].isConnection(idx/2 - 1))
					{
						graphics.lineStyle(0, iEdgeColour, 0.3);
					}
					else
					{
						graphics.lineStyle(0, iEdgeColour, 1);
					}
					graphics.lineTo((mPoints[idx]),(mPoints[idx+1]));
					idx+=2;
				}
				if(lPolys[lIdx].isConnection(idx/2 - 1))
				{
					graphics.lineStyle(0, iEdgeColour, 0.3);
				}
				else
				{
					graphics.lineStyle(0, iEdgeColour, 1);
				}
				graphics.lineTo((mPoints[0]),(mPoints[1]));
			}		
			graphics.endFill();
		}
		
		private function createFurnitureLayer()
		{
			mFurnitureDrawables = new Object();
			mFurnitureLayer = new Sprite();
			mFurnitureSubLayers = new Object();
			
			for each(var iPlacedItem in mRoom.getPlacedItems())
			{
				createPlacedItemDrawable(iPlacedItem);
			}
			mRoom.addEventListener(MapEvent.NEW_ITEM, onNewItem, false, 0, true);
			mRoom.addEventListener(MapEvent.ITEM_REMOVED, onItemRemoved, false, 0, true);
		}
		
		/**
		 * Called when a new PlacedItem has been added to the room that is currently being
		 * edited.
		 */
		private function onNewItem(iEvent:MapEvent)
		{
			mUpdate = true;
			var lItem:PlacedItem = iEvent.relatedObject;
			createPlacedItemDrawable(lItem);
		}
		
		/**
		 * Called when a PlacedItem has been removed from the room that is currently
		 * being edited
		 */
		private function onItemRemoved(evt:MapEvent)
		{
			mUpdate = true;
			var lItem:PlacedItem = evt.relatedObject;			
			var lDrawable:ItemDrawable = mFurnitureDrawables[""+lItem.getLocalId()];
			if(lDrawable != null)
			{
				lDrawable.parent.removeChild(lDrawable);
				mFurnitureDrawables[""+lItem.getLocalId()] = null;
			}
		}
		
		/**
		 * Creates an ItemDrawable to represent the specified PlacedItem object,
		 * and inserts it into the furniture layers.
		 */
		private function createPlacedItemDrawable(iItem:PlacedItem)
		{
			var lDrawable:ItemDrawable = new ItemDrawable(null, iItem);
			lDrawable.draw();
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
		
		private function mouseRoll(evt:MouseEvent)
		{
			//stage.focus = null; 
			dispatchEvent(new MapEvent(MapEvent.ROOM_OVER, mRoom, false, false));
		}
		
		private function mouseRollOut(evt:MouseEvent)
		{
			dispatchEvent(new MapEvent(MapEvent.ROOM_OUT, mRoom, false, false));
		}
		
		private function mouseClickStart(evt:MouseEvent)
		{
			mMouseDown = true;
		}
		private function mouseClickCancel(evt:MouseEvent)
		{
			mMouseDown = false;
		}
		private function mouseClickEnd(evt:MouseEvent)
		{
			if(mMouseDown)
			{
				dispatchEvent(new MapEvent(MapEvent.ROOM_CLICK, mRoom, false, false));
			}
			mMouseDown = false;
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