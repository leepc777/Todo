# Todo
Being a busy full-time dad for a 6 years old first grader and a 4 years old preschooler, I need a simple App to maintain to-do-list. 

And in order to drive kids to many places quickly and safely, I want a App quickly load in locations from the To-Do-List and show me the direction and traffic.

So when switching to driving mode by tapping the tab with Car icon, user can tap locations in lists to show it on a map. Then user can tap the pin to open Map app to show the direction and traffic. In this way, users don’t need to open Map app separately and manually type in the destination anymore. 

Also by tapping the pin on map, the info icon is to show Flickr photos about the location. User can edit those photos and store them persistently.

## Main Features
* To Do list for Category and Items/location.
* Show location on a map and direct user to the Location (GPS) by one click.


## Main Goals:
* Add Category and Items with auto correction keyboard.
* **swipe** to delete ( **Cocoapods SwipeCellKit** ) . An UNDO button to undo the deletion.
* use **Cocoapods Chameleon** to make App look good.
* Tap items to mark done and undone
* Switch Edit mode and Driving mode by tapping tabs.
* Build a single view controller class for both tabs view to reduce duplicate codes.
* Store Data persistently ( **Core Data** )
* Tap the item to show it on a MAP in driving mode ( **MapKit** )
* Show Flickr photos about the location. ( **REQS API Web services** )
* Tap the location to open **MAP App** to show direction (GPS).
* **GCD**, **multi-threaded ** and **asynchronous codes** for internet access.
* Build Super Class to contain duplicate codes for two Table View Controllers.

## Resource
* Cocoapods ([here](https://cocoapods.org/))
* Chameleon Framework ( [here](https://github.com/ViccAlexander/Chameleon))
* SwipeCellKit ([here](https://github.com/SwipeCellKit/SwipeCellKit))
