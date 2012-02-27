mNavBar.addEventListener(MenuEvent.GOTO_ROOM, onGotoRoom);
mNavBar.addEventListener(MenuEvent.GOTO_FLOOR, onGotoFloor);
mNavBar.addEventListener(MenuEvent.ZOOM_IN, onZoomIn);
mNavBar.addEventListener(MenuEvent.ZOOM_OUT, onZoomOut);

function onGotoRoom(evt:Object) {
        if(visibleFloorDrawable != null)
        {
                visibleFloorDrawable.zoomToRoom(evt.relatedObject);
        }
        stage.focus = stage;
};

function onGotoFloor(evt:Object) {
        selectedFloor = evt.relatedObject;
        if(visibleFloorDrawable != null && selectedFloor == visibleFloorDrawable.getFloor())
        {
                visibleFloorDrawable.zoomToMap();
        }
        else
        {
                gotoAndPlay("startItemLoad");
        }
        stage.focus = stage;
};

function onZoomIn(evt:Object) {
        if(visibleFloorDrawable != null)
        {
                visibleFloorDrawable.setZoom(visibleFloorDrawable.getZoom() * 1/0.9 * 1/0.9);
        }
        stage.focus = stage;
};

function onZoomOut(evt:Object) {
        if(visibleFloorDrawable != null)
        {
                visibleFloorDrawable.setZoom(visibleFloorDrawable.getZoom() * 0.9 * 0.9);
        }
        stage.focus = stage;
};]
