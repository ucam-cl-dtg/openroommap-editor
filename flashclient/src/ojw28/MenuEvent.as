package ojw28
{
	import flash.events.*;
	
	public class MenuEvent extends Event
    {
		public static const ZOOM_IN:String = "zoom_in";
		public static const ZOOM_OUT:String = "zoom_out";
		public static const CREATE_NEW:String = "create_new";
		public static const ITEM_ROLL_OVER:String = "item_roll_over";
		public static const ITEM_ROLL_OUT:String = "item_roll_out";
		public static const GOTO_ROOM:String = "goto_room";
		public static const GOTO_FLOOR:String = "goto_floor";
		
		public var relatedObject:Object;
		
		public function MenuEvent( type:String, related:Object, bubbles:Boolean, cancelable:Boolean )
		{
			super( type, bubbles, cancelable );
			relatedObject = related;
		}
		
		public override function clone():Event
		{
			return new MenuEvent(type, relatedObject, bubbles, cancelable);
		}
  }
}