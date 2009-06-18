package ojw28
{
public class Category
{	
	private var mName:String;
	private var mItems:Array;
	
	function Category(iName:String,iItems:Array) {
		mName = iName;
		mItems = iItems;
	}
	
	public function getName():String
	{
		return mName;
	}
	
	public function getItems():Array
	{
		return mItems;
	}
}
}