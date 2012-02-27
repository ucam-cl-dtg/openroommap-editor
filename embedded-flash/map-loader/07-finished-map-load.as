mLoadScreen.mText.text = "";

//Zoom to the user's room if we know what it is (if there are multiple rooms, just choose the first one)
var lUserRooms:Array = Map.getSingleton().getUsersRooms(Config.USER);
if(lUserRooms != null && lUserRooms.length > 0)
{
        selectedFloor = lUserRooms[0].getParent();
        zoomToUsersRoom = true;
}
else
{
        selectedFloor = Map.getSingleton().getFloors()[0];
}

mNavBar.refreshMap();
mComponentList.refreshLibrary();
gotoAndPlay("startItemLoad");
