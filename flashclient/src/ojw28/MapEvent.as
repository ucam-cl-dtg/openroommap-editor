package ojw28
{
	import flash.events.*;
	
	public class MapEvent extends Event
    {
		public static const FLIP:String = "flip_start";
		public static const NEW_ITEM:String = "item_added";
		public static const ITEM_UPDATED:String = "item_updated";
		public static const ITEM_REMOVED:String = "item_removed";
		public static const ITEM_SELECTED:String = "item_select";
		public static const DRAG_START:String = "drag_start";
		public static const DRAG_STOP:String = "drag_stop";
		public static const ZOOM:String = "zoom";
		public static const ROOM_OVER:String = "mouse_over_room";
		public static const ROOM_OUT:String = "mouse_out_room";
		public static const ROOM_CLICK:String = "mouse_click_room";
		public static const ITEM_OVER:String = "mouse_over_item";
		public static const ITEM_OUT:String = "mouse_out_item";
		public static const ROTATE_START:String = "item_rotate_start";
		public static const ROTATE_STOP:String = "item_rotate_stop";
		public static const ROTATE_MOVE:String = "item_rotate_move";
		
		public var relatedObject:Object;
		
		public function MapEvent( type:String, related:Object, bubbles:Boolean, cancelable:Boolean )
		{
			super( type, bubbles, cancelable );
			relatedObject = related;
		}
		
		public override function clone():Event
		{
			return new MapEvent(type, relatedObject, bubbles, cancelable);
		}
  }
}
