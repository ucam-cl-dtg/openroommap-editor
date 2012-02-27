framesUntilNextUpdate--;
if(framesUntilNextUpdate <= 0)
{
        framesUntilNextUpdate = 240;
        floorItemManager.doUpdate();
}

visibleFloorDrawable.updateNextFurnitureBitmap();
