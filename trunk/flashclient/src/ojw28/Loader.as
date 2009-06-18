package ojw28
{
	import flash.xml.*;
	import flash.net.*;
	import flash.events.*;
	
	public class Loader
	{	
		private var mMapLoaded:Boolean = false;
		private var mMapLoader:URLLoader;
	
		private var mUserLoaded:Boolean = false;
		private var mUserLoader:URLLoader;
		
		private var mComponentsLoaded:Boolean = false;
		private var mComponentLoader:URLLoader;
		
		private var mErrorRaised:Boolean = false;
		private var mErrorMessage:String;
		
		public function Loader() {
		}
	
		public function doLoad()
		{
			mErrorRaised = false;
			mErrorMessage = null;
			loadUser();
			loadMap();
			loadComponents();
		}
			
		private function loadUser()
		{
			mUserLoaded = false;
		
			mUserLoader = new URLLoader();
			mUserLoader.addEventListener(Event.COMPLETE, onLoadUser);
			mUserLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			var lRequest:URLRequest = new URLRequest(Config.SERVLET + "whoami");
			//Prevents caching
			lRequest.data = new URLVariables("time="+Number(new Date().getTime()));
			
			mUserLoader.load(lRequest);
		}
		
		private function onLoadUser(evt:Event)
		{
			try
			{
				var lUserXml:XML = new XML(mUserLoader.data);
				var lUser:String = lUserXml.attribute("crsid");
				//if(lUser == "no_auth")
				//{
					Config.USER = lUser;
				//}
				mUserLoaded = true;
			}
			catch(error:Error)
			{
				trace(error);
				mErrorMessage = "Error decoding map data";
				mErrorRaised = true;
			}
			finally
			{
				mUserLoader = null;
			}
		}
		
		private function loadMap()
		{
			mMapLoaded = false;
		
			mMapLoader = new URLLoader();
			mMapLoader.addEventListener(Event.COMPLETE, onLoadMap);
			mMapLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			var lRequest:URLRequest = new URLRequest(Config.SERVLET + "getmap");
			//Prevents caching
			lRequest.data = new URLVariables("time="+Number(new Date().getTime()));
			
			mMapLoader.load(lRequest);
		}
	
		private function loadComponents()
		{
			mComponentsLoaded = false;
			
			mComponentLoader = new URLLoader();
			mComponentLoader.addEventListener(Event.COMPLETE, onLoadComponents);
			mComponentLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			var lRequest:URLRequest = new URLRequest(Config.SERVLET + "components");
			//Prevents caching
			lRequest.data = new URLVariables("time="+Number(new Date().getTime()));
			
			mComponentLoader.load(lRequest);	
		}
	
		private function onLoadMap(evt:Event)
		{
			try
			{
				var lLoadedXml:XML = new XML(mMapLoader.data);
				Map.initSingleton(lLoadedXml);
				if(Map.getSingleton().getFloors().length == 0)
				{
					//No floors were loaded. Probably a server error
					throw new Error();
				}
				mMapLoaded = true;
			}
			catch(error:Error)
			{
				trace(error);
				mErrorMessage = "Error decoding map data";
				mErrorRaised = true;
			}
			finally
			{
				mMapLoader = null;
			}
		}

		private function onLoadComponents(evt:Event)
		{
			try
			{
				var lFurnitureDefinitions:XML = new XML(mComponentLoader.data);
				
				ComponentLibrary.initSingleton(lFurnitureDefinitions);				
				if(ComponentLibrary.getSingleton().getComponents().length == 0)
				{
					//No item definitions were loaded. Probably a server error
					throw new Error();
				}
				mComponentsLoaded = true;
			}
			catch(error:Error)
			{
				trace(error);
				mErrorMessage = "Error decoding item definitions";
				mErrorRaised = true;				
			}
			finally
			{
				mComponentLoader = null;
			}
		}
			
		private function errorHandler(evt:Event)
		{
			mErrorMessage = "Error contacting server";
			mErrorRaised = true;				
		}
	
		public function isFinished():Boolean
		{
			return !mErrorRaised && mMapLoaded && mComponentsLoaded && mUserLoaded;
		}
		
		public function isFailed():Boolean
		{
			return mErrorRaised;
		}
		
		public function getErrorMessage():String
		{
			return mErrorMessage;
		}
	}

}