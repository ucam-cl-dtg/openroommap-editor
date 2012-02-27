remainingMapLoadAttempts--;
if(remainingMapLoadAttempts > 0)
{
        //Attempt to load the map and item definitions from the server
        mLoadScreen.mText.text = "Loading map and item definitions";
        mapLoader.doLoad();
}
else
{
        //We have already tried the maximum number of times. Give up.
        mLoadScreen.mText.text = "Failed to contact server. Please try again later.";
        stop();
}
