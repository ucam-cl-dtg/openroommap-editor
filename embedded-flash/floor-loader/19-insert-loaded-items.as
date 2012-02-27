itemInsertFinished = true;

var lFractionCompleted:Number = visibleFloorDrawable.doItemInsertWork();
visibleFloorDrawable.updateNextFurnitureBitmap();
if(lFractionCompleted != 1)
{
        itemInsertFinished = false;
}

mLoadScreen.mText.text = "Inserting furniture items "+Math.round(lFractionCompleted*100)+"%";
