package ojw28
{
	import flash.display.*;
	import flash.events.*;
	
	public class ItemDrawable extends Sprite {
		
		//The item that is drawn
		private var mItem:PlacedItem;
	
		private var mDragging:Boolean;
		private var mRotating:Boolean;
		//The co-ordinates at which the item has been picked up
		private var mGrabX:Number;
		private var mGrabY:Number;

		//A sprite within which the item itself is drawn
		private var mItemDrawable:Sprite;
		//A sprite within which the rotation overlay is drawn when the item is selected
		//when the item is not selected this reference is null
		private var mRotateDrawable:Sprite;

		public function ItemDrawable(iItem:PlacedItem) {
		
			mItem = iItem;
		
			x = mItem.getX();
			y = mItem.getY();
			rotation = mItem.getTheta();
			
			mItemDrawable = new Sprite();
			if(iItem.isFlipped())
			{
				mItemDrawable.scaleY = -1;
			}
			else
			{
				mItemDrawable.scaleY = 1;
			}
			addChild(mItemDrawable);
			mItemDrawable.addEventListener(MouseEvent.MOUSE_DOWN, propagateMouseDown);
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseRoll, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseRollOut, false, 0, true);
			
			draw();
		}
				
		private function showRotateDrawable()
		{
			if(mRotateDrawable != null)
			{
				return;
			}
			else
			{
				mRotateDrawable = new RotateDrawable(mItem.getItemDef().isFlipable());
				mRotateDrawable.addEventListener(MapEvent.ROTATE_START, startRotation);
				mRotateDrawable.addEventListener(MapEvent.ROTATE_STOP, stopRotation);
				mRotateDrawable.addEventListener(MapEvent.FLIP, doFlip);
				addChild(mRotateDrawable);
			}
		}
		
		private function hideRotateDrawable()
		{
			if(mRotateDrawable != null)
			{
				mRotateDrawable.removeEventListener(MapEvent.ROTATE_START, startRotation);
				mRotateDrawable.removeEventListener(MapEvent.ROTATE_STOP, stopRotation);
				mRotateDrawable.removeEventListener(MapEvent.FLIP, doFlip);
				removeChild(mRotateDrawable());
			}
		}
				
		public function propagateMouseDown(evt:Event) {
			dispatchEvent(new MapEvent(MapEvent.DRAG_START,mItem,false,false));
		}
				
		public function onItemUpdate()
		{
			if(!mDragging && !mRotating)
			{
				x = mItem.getX();
				y = mItem.getY();
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
			mItemDrawable.scaleY = -mItemDrawable.scaleY;
			mirrorPositionUpdate();
		}
					
		private function draw() {
			mItemDrawable.graphics.clear();
			for(var lPolyIdx in mItem.getItemDef().getPolys())
			{
				var lPoly:ItemDefPoly = mItem.getItemDef().getPolys()[lPolyIdx];
				mItemDrawable.graphics.lineStyle(0,lPoly.getEdgeColour(),lPoly.getEdgeAlpha());
				mItemDrawable.graphics.beginFill(lPoly.getFillColour(),lPoly.getFillAlpha());
				var mPoints:Array = lPoly.getVertices();
				mItemDrawable.graphics.moveTo(mPoints[0],mPoints[1]);
				var idx:Number = 2;
				while (idx<mPoints.length) {
					mItemDrawable.graphics.lineTo(mPoints[idx],mPoints[idx+1]);
					idx += 2;
				}
				mItemDrawable.graphics.lineTo(mPoints[0],mPoints[1]);
				mItemDrawable.graphics.endFill();
			}
		}
	
		public function getItem():PlacedItem {
			return mItem;
		}
		
		public function unSelect() {
			hideRotateDrawable();
		}
			
		/*
		 Updates the item whilst it is being dragged
		 */
		public function updateDragging(iMouseX:Number, iMouseY:Number) {
			//Make sure the item remains "grabbed" at the correct offset.
			//This is necessary as the default flash dragging mechanism
			//breaks when a zoom occurs during a drag.
			x = iMouseX-mGrabX;
			y = iMouseY-mGrabY;
		}
			
		public function notifyMapZoom(iMouseX:Number, iMouseY:Number, iZoom:Number) {
			if(mDragging)
			{
				updateDragging(iMouseX, iMouseY);
			}
			else if(mRotating)
			{
				updateRotation(null);
			}
			if(mRotateDrawable != null)
			{
				mRotateDrawable.scaleX = 1/iZoom;
				mRotateDrawable.scaleY = 1/iZoom;				
			}
		}
	
		private function startRotation(evt:Event) {			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateRotation, false, 0, true);
			mRotating = true;
		}
		
		private function stopRotation(evt:Event)
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateRotation);
			mRotating = false;
			mirrorPositionUpdate();
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
				
		public function startDragging(iMouseX:Number,iMouseY:Number)
		{
			mDragging = true;
			mGrabX = iMouseX-x;
			mGrabY = iMouseY-y;
		}
		
		public function stopDragging(iZoom:Number) {
			mDragging = false;
			mirrorPositionUpdate();
			showRotateDrawable();
			mRotateDrawable.scaleX = 1/iZoom;
			mRotateDrawable.scaleY = 1/iZoom;
		}
		
		private function mirrorPositionUpdate()
		{
			var lX:Number = x;
			var lY:Number = y;
			var lFlipped:Boolean = (mItemDrawable.scaleY == -1);
			if(lX != mItem.getX() || lY != mItem.getY() || rotation != mItem.getTheta() || lFlipped != mItem.isFlipped())
			{
				mItem.setPosition(x,y,rotation,lFlipped,true);				
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