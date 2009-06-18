package ojw28
{
	import flash.xml.*;
	import flash.net.*;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	
	public class Room extends EventDispatcher
	{
		private var mParent:Floor;
		
		public var mName:String;
		private var mUid:Number;
		private var mAccessLevel:Number;
		
		private var mFloorPolys:Array;
		private var mBounds:BoundingBox3D;
		
		private var mPlacedItems:Array;
		
		function Room(iParent:Floor, iXmlNode:XML)
		{
			mParent = iParent;
			mPlacedItems = new Array();
			parseXml(iXmlNode);
		}
		
		private function parseXml(iXmlNode:XML)
		{
			mName = iXmlNode.attribute("name");
			mUid = Number(iXmlNode.attribute("uid"));
			mAccessLevel = Number(iXmlNode.attribute("accesslevel"));
			
			mFloorPolys = new Array();
			mBounds = new BoundingBox3D();
			
			for each (var lItem in iXmlNode.elements())
			{
				var lPoly:FloorPoly = new FloorPoly(this, lItem);
				
				mFloorPolys.push(lPoly);
				mBounds.expandAroundVertices(lPoly.getVertices());
			}
		}
		
		public function getOccupants():Array 
		{
			var lMapping:OccupancyMap = mParent.getParent().getOccupancyMap();
			if(lMapping != null)
			{
				return lMapping.getOccupants(this);
			}
			return null;
		}
		
		public function getName():String
		{
			return mName;
		}
		
		public function getUid():Number
		{
			return mUid;
		}
		
		function getAccessLevel():Number
		{
			return mAccessLevel;
		}
		
		function getFloorPolys():Array
		{
			return mFloorPolys;
		}
		
		function getBounds():BoundingBox3D
		{
			return mBounds;
		}
		
		public function getParent():Floor
		{
			return mParent;
		}		
		
		public function getPlacedItems():Array
		{
			return mPlacedItems;
		}
		
		public function addPlacedItem(iItem:PlacedItem)
		{
			mPlacedItems.push(iItem);
			dispatchEvent(new MapEvent(MapEvent.NEW_ITEM, iItem, false, false));
			mParent.addPlacedItem(iItem);
		}
		
		public function removePlacedItem(iItem:PlacedItem)
		{
			var lIdx:Number = mPlacedItems.indexOf(iItem);
			if(lIdx != -1)
			{
				mPlacedItems.splice(lIdx,1);
			}
			dispatchEvent(new MapEvent(MapEvent.ITEM_REMOVED, iItem, false, false));
			removePlacedItem.addPlacedItem(iItem);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		public function createFurnitureBitmap(iScreenWidth:Number, iScreenHeight:Number):Bitmap
		{
			var lSprite:Sprite = new Sprite();
			var lLayers:Object = new Object();
			for each(var iPlacedItem in mPlacedItems)
			{
				createPlacedItemDrawable(iPlacedItem,lSprite,lLayers);
			}
			//Now we have lSprite containing the furniture
			
			var lScale = Math.min(1,Math.min(Math.min(iScreenHeight,1000)/(mBounds.maxy - mBounds.miny),Math.min(iScreenWidth,1000)/(mBounds.maxx - mBounds.minx)));
			
			var lBmData:BitmapData = new BitmapData((mBounds.maxx - mBounds.minx)*lScale,(mBounds.maxy - mBounds.miny)*lScale,true,0x00000000);
			lBmData.draw(lSprite, new Matrix(lScale,0,0,lScale,-mBounds.minx*lScale,-mBounds.miny*lScale), null, null, null, false);
						
			var lBm:Bitmap = new Bitmap(lBmData,"auto", true);
			lBm.scaleX = 1/lScale;
			lBm.scaleY = 1/lScale;
			return lBm;
		}
		
		/**
		 * Creates an ItemDrawable to represent the specified PlacedItem object,
		 * and inserts it into the furniture layers.
		 */
		private function createPlacedItemDrawable(iItem:PlacedItem, lSprite:Sprite, lLayers:Object):ItemDrawable
		{
			var lDrawable:ItemDrawable = new ItemDrawable(null, iItem);
			lDrawable.draw();
			insertPlacedItemDrawable(lDrawable, lSprite, lLayers);
			return lDrawable;
		}
		
		/**
		 * Inserts an item drawable into the furniture layers, creating a new layer
		 * if it is the first furniture item to be added at a particular depth.
		 */
		private function insertPlacedItemDrawable(iItem:ItemDrawable, lSprite:Sprite, lLayers:Object)
		{
			var lDepth:Number = iItem.getItem().getItemDef().getHeight();
			if(lLayers[""+lDepth] == null)
			{
				var lDepthLayer:FurnitureLayer = new FurnitureLayer(lDepth);
				lLayers[""+lDepth] = lDepthLayer;
				var li:Number = 0;
				for(; li < lSprite.numChildren; li++)
				{
					var lLayer:FurnitureLayer = lSprite.getChildAt(li);
					if(lLayer.getDepth() > lDepth)
					{
						break;
					}
				}
				lSprite.addChildAt(lDepthLayer, li);
			}
			lLayers[""+lDepth].addChild(iItem);
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