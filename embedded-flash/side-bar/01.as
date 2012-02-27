mProperties.updateProperties();

stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
mComponentList.addEventListener(MenuEvent.ITEM_ROLL_OVER, onListOver);
mComponentList.addEventListener(MenuEvent.ITEM_ROLL_OUT, onListOut);
mComponentList.addEventListener(MenuEvent.CREATE_NEW, onDragStart);

function onKeyPressed(evt:KeyboardEvent)
{
        if(evt.keyCode == Keyboard.DELETE)
        {
                if(visibleFloorDrawable != null)
                {
                        visibleFloorDrawable.deleteSelectedItem();
                }
        }
}

function onListOver(evt_obj:Object) {
        mProperties.setMouseOverComponent(evt_obj.relatedObject);
};

function onListOut(evt_obj:Object) {
        mProperties.setMouseOverComponent(null);
};

function onDragStart(evt_obj:Object) {
        if(visibleFloorDrawable != null)
        {
                visibleFloorDrawable.createItemAndDrag(evt_obj.relatedObject.getItemDefId());
        }
};
