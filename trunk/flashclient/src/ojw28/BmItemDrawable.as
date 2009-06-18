package ojw28
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class BmItemDrawable extends Sprite {
		
		private static var mBitmaps:Object = new Object();
		
		//The map on which this item is drawn
		private var mMapBase:FloorDrawable;
		//The item that is drawn
		private var mItem:PlacedItem;
	
		private var mDragging:Boolean;
		private var mRotating:Boolean;
		//The co-ordinates at which the item has been picked up
		private var mGrabX:Number;
		private var mGrabY:Number;
		
		private var mRemoved:Boolean;

		private var mLineColour:Number = 0x000000;
		private var mFillColour:Number = 0xE0E0E0;

		//A movieclip within which the item itself is drawn
		private var mItemDrawable:Bitmap;
		//A movieclip within which the rotation overlay is drawn when the item is selected
		private var mRotateDrawable:MovieClip;

		public function BmItemDrawable(iMapBase:FloorDrawable, iItem:PlacedItem) {
			var lItemDef = iItem.getItemDef();
			if(mBitmaps[lItemDef.getName()] == null)
			{
				var lDrawable = new ItemDrawable(iMapBase,iItem);
				lDrawable.draw(false);
				var buffer:BitmapData = new BitmapData (lDrawable.width,lDrawable.height,true);  
				buffer.fillRect(new flash.geom.Rectangle(0,0,lDrawable.width,lDrawable.height),0x00000000);
				buffer.draw (lDrawable, new Matrix(1,0,0,1,-lItemDef.getBounds().minx,-lItemDef.getBounds().miny));
				mBitmaps[lItemDef.getName()] = buffer;
			}
			mItemDrawable = new Bitmap(mBitmaps[lItemDef.getName()]);
			mItemDrawable.smoothing = true;
			addChild(mItemDrawable);
			
			mRemoved = false;
			mMapBase = iMapBase;
			mItem = iItem;
		
			x = mItem.getX() * 100;
			y = mItem.getY() * 100;
			rotation = mItem.getTheta();
	
			if(iItem.isFlipped())
			{
				mItemDrawable.scaleY = -1;
			}
			else
			{
				mItemDrawable.scaleY = 1;
			}
			//addChild(mItemDrawable);
			
			mRotateDrawable = new RotateDrawable(iItem.getItemDef().isFlipable());
			addChild(mRotateDrawable);
			mRotateDrawable.visible = false;
			mRotateDrawable.draw();
			mRotateDrawable.addEventListener(MapEvent.ROTATE_START, startRotation);
			mRotateDrawable.addEventListener(MapEvent.ROTATE_STOP, stopRotation);
			mRotateDrawable.addEventListener(MapEvent.FLIP, doFlip);
			mItemDrawable.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseRoll);
			addEventListener(MouseEvent.MOUSE_OUT, mouseRollOut);
			
			iItem.addEventListener(MapEvent.ITEM_UPDATED, onItemUpdate);
			iItem.addEventListener(MapEvent.ITEM_REMOVED, onItemRemove);
		}
				
		private function onItemUpdate(evt:MapEvent)
		{
			if(!mDragging && !mRotating)
			{
				x = mItem.getX() * 100;
				y = mItem.getY() * 100;
				rotation = mItem.getTheta();
				if(mItem.isFlipped())
				{
					mItemDrawable.scaleY = -1;
				}
				else
				{
					mItemDrawable.scaleY = 1;
				}
			}
			else
			{
				//Ignore updates on the item if it is currently being edited
			}
		}
		
		private function doFlip(evt:MapEvent)
		{
			mirrorPositionUpdate(!mItem.isFlipped());
		}
		
		public function deleteItem()
		{
			mItem.deleteItem();
			onItemRemove(null);
		}
		
		private function onItemRemove(evnt:MapEvent)
		{
			if(!mRemoved)
			{
				mRemoved = true;				
				if(mMapBase.getSelectedItem() == this)
				{
					mMapBase.setSelectedItem(null);
				}
				parent.removeChild(this);
			}
		}
	
		public function draw(iValid:Boolean) {
			if (iValid) {
				drawInternal(mFillColour);
			} else {
				drawInternal(0xFF0000);
			}
			visible = true;
		}

		private function drawInternal(iFillColour:Number) {
			/*
			mItemDrawable.graphics.clear();

			for(var lPolyIdx in mItem.getItemDef().getPolys())
			{
				var lPoly:ItemDefPoly = mItem.getItemDef().getPolys()[lPolyIdx];
				mItemDrawable.graphics.lineStyle(0,lPoly.getEdgeColour(),lPoly.getEdgeAlpha());
				mItemDrawable.graphics.beginFill(lPoly.getFillColour(),lPoly.getFillAlpha());
	
				var mPoints:Array = lPoly.getVertices();
				mItemDrawable.graphics.moveTo(mPoints[0],mPoints[1]);
				var idx:Number = 3;
				while (idx<mPoints.length) {
					mItemDrawable.graphics.lineTo(mPoints[idx],mPoints[idx+1]);
					idx += 3;
				}
				mItemDrawable.graphics.lineTo(mPoints[0],mPoints[1]);
				mItemDrawable.graphics.endFill();
			}*/
		}
	
		public function getItem():PlacedItem {
			return mItem;
		}
	
		public function select() {
			//mRotateDrawable.scaleX = 1/mMapBase.getZoom();
			//mRotateDrawable.scaleY = 1/mMapBase.getZoom();
			//mRotateDrawable.visible = true;
		}
		
		public function unSelect() {
			mRotateDrawable.visible = false;
		}
			
		/*
		 Updates the item whilst it is being dragged
		 */
		private function updateDragging(evt:Event) {
			//Make sure the item remains "grabbed" at the correct offset.
			//This is necessary as the default flash dragging mechanism
			//breaks when a zoom occurs during a drag.
			x = mMapBase.getMouseX()-mGrabX;
			y = mMapBase.getMouseY()-mGrabY;
	
			//Update the appearance of the item to reflect whether the cursor
			//is over a valid drop position (draw as normal), an invalid drop
			//postion (draw but in the an invalid colour), or on an overlay
			//(draw at old position or draw nothing).
			if (mMapBase.isValidDrop(mItemDrawable)) {
				draw(true);
			} else if (mMapBase.isMouseOver()) {
				draw(false);
			} else {
				if (mItem.isServerMapped()) {
					x = mItem.getX();
					y = mItem.getY();
				} else {
					visible = false;
				}
			}
		}
	
		public function notifyMapZoom() {
			if(mDragging)
			{
				updateDragging(null);
			}
			else if(mRotating)
			{
				updateRotation(null);
			}
			mRotateDrawable.scaleX = 1/mMapBase.getZoom();
			mRotateDrawable.scaleY = 1/mMapBase.getZoom();
		}
	
		private function startRotation(evt:Event) {			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateRotation);
			mRotating = true;
		}
		
		private function stopRotation(evt:Event)
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateRotation);
			mRotating = false;
			mirrorPositionUpdate(mItem.isFlipped());
		}
		
		/*
		 Updates the item's rotation during the rotation operation.
		 The rotation has 5 degree granularity
		 */
		private function updateRotation(evt:Event) {
			rotation = Math.round((rotation-90+getRotation(mouseX, mouseY)/Math.PI*180)/5)*5;
		}
	
		/*
		 Computes the angle of rotation given the specified mouse co-ordinates
		 */
		private function getRotation(iX:Number, iY:Number):Number {
			var lTheta:Number = 0;
			if (iX == 0) {
				if (iY<0) {
					lTheta = -Math.PI/2;
				} else {
					lTheta = Math.PI/2;
				}
			} else {
				lTheta = Math.atan(Math.abs(iY)/Math.abs(iX));
				if (iX<0) {
					if (iY<0) {
						lTheta -= Math.PI;
					} else {
						lTheta = Math.PI-lTheta;
					}
				} else if (iY<0) {
					lTheta = -lTheta;
				}
			}
			return lTheta;
		}
	
		public function startDragging(evt:Event) {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			mMapBase.setSelectedItem(this);		
			mDragging = true;
			mGrabX = parent.mouseX-x;
			mGrabY = parent.mouseY-y;
		}
	
		private function stopDragging(evt:MouseEvent) {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateDragging);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			mDragging = false;
	
			var lValidDrop:Boolean = mMapBase.isValidDrop(mItemDrawable);
			if(lValidDrop)
			{
				mirrorPositionUpdate(mItem.isFlipped());		
				
				mRotateDrawable.scaleX = 1/mMapBase.getZoom();
				mRotateDrawable.scaleY = 1/mMapBase.getZoom();
				mRotateDrawable.visible = true;
			}
			else
			{
				if(mItem.isServerMapped())
				{
					x = mItem.getX()*100;
					y = mItem.getY()*100;
					rotation = mItem.getTheta();
					
					mRotateDrawable.scaleX = 1/mMapBase.getZoom();
					mRotateDrawable.scaleY = 1/mMapBase.getZoom();
					mRotateDrawable.visible = true;	
				}
				else
				{
					onItemRemove(null);
				}
			}
	
			draw(true);
		}
		
		private function mirrorPositionUpdate(iFlipped:Boolean)
		{
			var lX:Number = x/100;
			var lY:Number = y/100;
			if(lX != mItem.getX() || lY != mItem.getY() || rotation != mItem.getTheta() || iFlipped != mItem.isFlipped())
			{
				mItem.setPosition(x/100,y/100,rotation,iFlipped);				
			}
		}
		
		private function mouseRoll(evt:MouseEvent)
		{
			dispatchEvent(new MapEvent(MapEvent.ITEM_OVER, mItem, false, false));
		}
		
		private function mouseRollOut(evt:MouseEvent)
		{
			dispatchEvent(new MapEvent(MapEvent.ITEM_OUT, mItem, false, false));
		}

	}
}