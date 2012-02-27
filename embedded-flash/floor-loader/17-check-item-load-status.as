//Check on the status of the load
if(!floorItemManager.isUpdateInProgress())
{
        gotoAndPlay("insertLoadedItems");
}
else if(floorItemManager.isErrorFlagSet())
{
        gotoAndPlay("retryItemLoad");
}
