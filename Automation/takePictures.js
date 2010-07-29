// handy variables to cache
target = UIATarget.localTarget();
app = target.frontMostApp();
nextButton = app.toolbar().elements()["nextButton"];
effectTitle = app.mainWindow().textFields()[0]; 

// test routines
function go()
{
    UIALogger.logStart("Begin");
    
    for(i = 0; i < 16; ++i)
    {
        var rect =
        {
            origin: { x: 110, y: 270},
            size: { width: 410, height: 420 }
        };
        target.captureRectWithName(rect, effectTitle.value() + "_thumb");
        nextButton.tap();
        target.delay(2);
    }
    
    UIALogger.logPass();
}

go();