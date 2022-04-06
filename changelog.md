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