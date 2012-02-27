//Check on the status of the loader
if(mapLoader.isFinished())
{
        gotoAndPlay("finishedMapLoad");
}
else if(mapLoader.isFailed())
{
        gotoAndPlay("retryMapLoad");
}
