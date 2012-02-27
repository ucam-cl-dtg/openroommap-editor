var selectedFloor:Floor = null;
var visibleFloorDrawable:FloorDrawable = null;
var floorItemManager:FloorItemManager = null;
var remainingItemLoadAttempts:Number = 10;
var itemInsertFinished:Boolean = false;
var waitUntilItemLoadRetry:Number = 0;
var framesUntilNextUpdate:Number = 0
