import ojw28.*;
import flash.text.*;

var remainingMapLoadAttempts:Number = 10;
var waitUntilMapLoadRetry:Number = 0;
var mapLoader:ojw28.Loader = new ojw28.Loader();
var zoomToUsersRoom:Boolean = false;
