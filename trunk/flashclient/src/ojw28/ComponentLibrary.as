package ojw28
{
	import flash.xml.*;
	
	public class ComponentLibrary
	{	
		private var mSingleton:ComponentLibrary;
		
		private var mIndexedItems:Object;
		private var mItems:Array;
	
		public function ComponentLibrary(iXml:XML, enforcer:SingletonEnforcer) {
			parseXml(iXml);
		}
		
		public static function initSingleton(iXml:XML)
		{
			mSingleton = new ComponentLibrary(iXml,new SingletonEnforcer());
		}
		
		public static function getSingleton():ComponentLibrary
		{
			return mSingleton;
		}
	
		private function parseXml(iXml:XML)
		{
			mIndexedItems = new Object();
			mItems = new Array();
			
			for each (var lItemXml in iXml.elements())
			{
				var lItem:ItemDef = new ItemDef(lItemXml);
				mIndexedItems[lItem.getItemDefId()] = lItem;
				mItems.push(lItem);
			}
		}
	
		public function getComponents():Array
		{
			return mItems;
		}
		
		public function getComponent(iId:Number):ItemDef
		{
			return mIndexedItems[iId];
		}
	
	}
}

//The private class
class SingletonEnforcer {};