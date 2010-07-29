// This is a fairly simple UIAutomation script written as an example.
// It defines three tests and executes them. A screenshot is captured
// after running each test - no automated verification is done, though
// that is certainly possible.
// For more on the UI Automation framework, see
// http://developer.apple.com/iphone/library/documentation/DeveloperTools/Reference/UIAutomationRef/Introduction/Introduction.html

// handy variables to cache
target = UIATarget.localTarget();
app = target.frontMostApp();

// helpers
function tapIncrementButtonNTimes(n)
{
    var i;
    for(i = 0; i < n; ++i)
    {
        app.mainWindow().buttons()["Increment"].tap();
        target.delay(1);
    }
}

function tapDecrementButtonNTimes(n)
{
    var i;
    for(i = 0; i < n; ++i)
    {
        app.mainWindow().buttons()["Decrement"].tap();
        target.delay(1);
    }
}

function tapResetButton()
{
    app.mainWindow().buttons()["Reset"].tap();
    target.delay(1);
}

// test routines
function test1()
{
    UIALogger.logStart("Beginning test 1 - tapping increment 5 times makes the label read 5");
    tapResetButton();
    tapIncrementButtonNTimes(5);    
    target.captureScreenWithName("test1-screenshot");
}

function test2()
{
    UIALogger.logStart("Beginning test 2 - tapping increment 6 times and decrement twice makes the label read 4");
    tapResetButton();
    tapIncrementButtonNTimes(6);
    tapDecrementButtonNTimes(2);
    target.captureScreenWithName("test2-screenshot");
}

function test3()
{
    UIALogger.logStart("Beginning test 3 - tapping decrement 3 times makes the label read -3");
    tapResetButton();
    tapDecrementButtonNTimes(3);
    target.captureScreenWithName("test3-screenshot");
}

// Actually run the tests
test1();
test2();
test3();