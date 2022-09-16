# 5.6
* From nbeerten - Change behavior of hotkeys so that they will now work even when the helpers window is hidden
* Change behavior of color toggle hotkey. New behavior is to quickswitch to your previous selected color. (Old behavior was simply to cycle through all colors.)
* Add UI showing what plugin hotkeys are currently active.
* Add toggle for item AutoRotation to custom item placement function. Thanks to Plantathon for the suggestion. Activating this will apply AutoRotation to the current item as well as force the item grid to 0, 0.
* Rework plugin settings page. New page should provide better information about each plugin feature.


## 5.5
* Add hotkey to flip item/freeblock 180 deg. Defaulted off, needs to be enabled in settings. Default key is `.`
* Fix issue with changing openplanet API in MP4
* From Rxelux - Add Freeblock Precise Translation function which allows you to set a numeric placement offset while in freeblock mode


## 5.4
* Add FIXED_STEP option to rotation randomizer. This mode increments on the selected axis's after each block/item placement.
* From Greep (thanks!) - Add Mood Changer function which allows you to set your map's time of day down to the second
* From Greep (thanks!) - Add Camera Modes function which lets you switch between orbital and free cam in the editor
* Add Locator Check function. This scans your map file header and checks that all embedded media has a url linked to it (excluding game resources).


## 5.3
* Add new feature - Rotation Randomizer. Turning this on will cause your block/item cursor to be rotated randomly on the selected axis's after each placement. (Thanks to Raveout for the idea)


## 5.2
* Remove use of 'handled' in OnKeyPress functions to match change in Openplanet API
* Rework some internal logic in quicksave function


## 5.1
* Re-add selection persistence to item placement. See "Persist Ghost Mode", "Persist Item Grid", and "Persist Item Pivot" in the settings.
* Add selection persistence to item/block rotation. See "Persist Step Size" in the settings.


## 5.0 - Spring cleaning update
* UI Overhaul
  * Move many things to only display in the openplanet settings page to reduce clutter
  * Re-organize commonly used functions into more logical groups
  * Consolidate settings page
* Add ability to show/hide the block cursor box. This is the (normally) green box which is displayed around the block in your cursor.
* Add more preset angles (Slope3, and Slope4) to the custom rotation step sizes
* Change permission checks to happen all the time instead of just once.

## 4.4
* Add hotkey for cycling through block colors
* Fix issue with rotation of items in TM2020, it was disabled when it didnt need to be
* Add ability to manipulate the pivot point of a custom item
* Re-add support for Maniaplanet

## 4.1
* Fixed a bug in custom item placement vertical step
* Added new feature, hotkeys! First hotkey added is airblockmode, defaulted to 'A'

## 4.0
* Added a compatibility layer and support for MP4
* Further backend code refactoring

## 3.0
* Convert to *new* plugin format!
* Correct Enums for new API
* Bugfix to Quicksave, format codes were being stripped from the map name

## 2.4
* Correct permissions checks to allow standard access usage (I hope)

## 2.3
* Signature for standard access users
* Cleanup/Removal of map statistics, considering moving to a standalone plugin

## 2.1
* Added Map Statistics Function
* Added Freeblockmode precise rotation Function
* Refactored settings into categories
* Refactored Update loop to be in Main instead