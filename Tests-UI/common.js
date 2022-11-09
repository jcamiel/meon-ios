

//--
function resetPreferences()
{
    return;
	UIALogger.logMessage("Reset Meon preferences, as cold start");
	
    var app = UIATarget.localTarget().frontMostApp();
    
	app.setPreferencesValueForKey(0,"classic.level");
	app.setPreferencesValueForKey(0,"classic.levelMaximum");
	app.setPreferencesValueForKey("classic","mode");
	app.setPreferencesValueForKey("MainMenu","currentViewController");
	
	UIALogger.logMessage("valueForKey" + app.preferencesValueForKey("tata"));
}


//--
UIATarget.onAlert = function onAlert(alert) 
{ 
	var title = alert.name();
	UIALogger.logWarning("Alert with title '" + title + "' encountered!");
	return false;
}

//--
function goToMainMenu()
{
    var window = UIATarget.localTarget().frontMostApp().mainWindow();
    
	UIALogger.logMessage("Go to the Main Menu");
	
    dismissTutorial();
    
	// back from the Play Menu
	var button = window.buttons()["Menu"];
	if (button.isValid()){
		button.tap();
	}
    
	// Back from various page
	var view = window.images()["Default.png"];
	if (view.isValid()){
		button = view.buttons()["Back"];
		
		if (button.isValid())
			button.tap();
	}
}

//--
function dismissTutorial()
{
    var window = UIATarget.localTarget().frontMostApp().mainWindow();

    target.delay(1);
    
	do {
		var view = window.images()["Common/tip-background.png"];
//        UIATarget.localTarget().logElementTree();
        
		if (view.isValid() && view.isVisible()){
			UIALogger.logMessage("Dismiss tutorial");
			target.tap({x:160, y:200});
			target.delay( 1 );
		}
        else
            break;
	} while (1);
    
}

//--
function goToLevel(level)
{
    var window = UIATarget.localTarget().frontMostApp().mainWindow();

	UIALogger.logMessage("Go to the level " + level);
	
	dismissTutorial();
	
	// back from the Play Menu
	var button = window.buttons()["gotoButton"];
	if (button.isValid()){
		button.tap();
	}
	target.delay( 2 );
    
    var cell = window.tableViews()[0].cells()[0];
    
    cell.scrollToVisible();


    target.tap({x:50,y:106});

	target.delay( 2 );
    
    //var button = window.tableViews()[0].cells()[0].buttons()[ level / 4];
    //button.scrollToVisible();
    
    //UIATarget.localTarget().frontMostApp().logElementTree();
    
    //target.delay( 4 );
    
    //button.tap()
    
    
    checkLevel( level) ;
}

function getLevel()
{
    var window = UIATarget.localTarget().frontMostApp().mainWindow();
    var app = UIATarget.localTarget().frontMostApp();
    
	var imageLevel = window.elements().firstWithPredicate("name beginswith 'Common/level'");
    var value = imageLevel.value();
    return parseInt( value.substring(6) );
}

//--
function checkLevel(level)
{
    var window = UIATarget.localTarget().frontMostApp().mainWindow();
    var app = UIATarget.localTarget().frontMostApp();
    
//	app.logElementTree();
	var name = "Level "+level;
	var imageLevel = window.elements().firstWithPredicate("name beginswith 'Common/level'");
    var valueExpected = "Level " + level;
	assertEquals(valueExpected, imageLevel.value(), "Level not match");
}




function tapOnClassicOnMain()
{
    var window = UIATarget.localTarget().frontMostApp().mainWindow();
    
    //-- select Play classic from Main Menu
    UIALogger.logMessage("Tap Play Classic");
    var view = window.images()["Default.png"];
    view.buttons()["Play Classic"].tap();

}