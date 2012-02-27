remainingItemLoadAttempts--;
if(remainingItemLoadAttempts > 0)
{
        //Start an attempt to load items from the server
        mLoadScreen.mText.text = "Loading furniture items";
        floorItemManager.doUpdate();
}
else
{
        //We have already tried the maximum number of times. Give up.
        mLoadScreen.mText.text = "Failed to contact server. Please try again later.";
        stop();
}
