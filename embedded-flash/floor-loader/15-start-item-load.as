if(visibleFloorDrawable != null)
{
        removeChild(visibleFloorDrawable);
        visibleFloorDrawable.deSelectItem();
        visibleFloorDrawable.removeEventListener(MapEvent.ROOM_OVER, onRoomOver);
        visibleFloorDrawable.removeEventListener(MapEvent.ROOM_OUT, onRoomOut);
        visibleFloorDrawable.removeEventListener(MapEvent.ITEM_OVER, onItemOver);
        visibleFloorDrawable.removeEventListener(MapEvent.ITEM_OUT, onItemOut);
        visibleFloorDrawable.removeEventListener(MapEvent.ITEM_SELECTED, onItemSelect);
        visibleFloorDrawable = null;
        floorItemManager = null;
        flash.system.System.gc();
}

floorItemManager = new FloorItemManager(selectedFloor);

//Create a floor drawable
visibleFloorDrawable = new FloorDrawable(selectedFloor,floorItemManager,20 + 715/2, 55 + 655/2, 715, 655);
//Make the drawable visible and add listeners
visibleFloorDrawable.addEventListener(MapEvent.ROOM_OVER, onRoomOver, false, 0, true);
visibleFloorDrawable.addEventListener(MapEvent.ROOM_OUT, onRoomOut, false, 0, true);
visibleFloorDrawable.addEventListener(MapEvent.ITEM_OVER, onItemOver, false, 0, true);
visibleFloorDrawable.addEventListener(MapEvent.ITEM_OUT, onItemOut, false, 0, true);
visibleFloorDrawable.addEventListener(MapEvent.ITEM_SELECTED, onItemSelect, false, 0, true);

//Zoom to the user's room if we know what it is (if there are multiple rooms, just choose the first one)
if(zoomToUsersRoom)
{
        var lUserRoom:Room = Map.getSingleton().getUsersRooms(Config.USER)[0];
        visibleFloorDrawable.zoomToRoom(lUserRoom);
        zoomToUsersRoom = false;
}

addChildAt(visibleFloorDrawable,0);

//Notify the nav bar and properties window of the new floor selection
mProperties.setCurrentFloor(selectedFloor);
mNavBar.setCurrentFloor(selectedFloor);

function onRoomOver(evt:MapEvent)
{
        mNavBar.setCurrentRoom(evt.relatedObject);
        mProperties.setCurrentRoom(evt.relatedObject);
}

function onRoomOut(evt:MapEvent)
{
        mProperties.setCurrentRoom(null);
}

function onItemOver(evt:MapEvent)
{
        mProperties.setMouseOverItem(evt.relatedObject);
}

function onItemOut(evt:MapEvent)
{
        mProperties.setMouseOverItem(null);
}

function onItemSelect(evt:MapEvent)
{
        mProperties.setSelectedItem(evt.relatedObject);
