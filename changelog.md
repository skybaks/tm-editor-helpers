## 6.4.2
* Bugfixes
  * Fix a script exception in the locator check when leaving the editor quickly after entering
  * Fix a game crash in inventory indexing when leaving the editor quickly after entering


## 6.4.1
* Bugfixes
  * Fix an issue where leaving the editor too quickly would result in a script crash or even a game crash in some cases.


## 6.4.0
* Features
  * Force "manually switch pivot" flag when overriding item pivot. Use "Q" to cycle through item pivots.


## 6.3.1
* Bugfixes
  * Fix inventory validation not passing due to recent block restructure


## 6.3.0
* Features
  * Locator check can now test that media URLs return a valid HTTP response. See plugin settings to enable


## 6.2.0
* Features
  * Add new option to Quicksave function to create a backup copy of the map each time it is saved
  * Improve backend implementation of presets
  * Preset buttons now show as disabled when there are no changes to apply
  * Add persistence to block color widget and force macroblock color through editor sessions and game restarts. Configure this in the settings for "Remember Placement Modes"
  * Add markers to highlight new features. Can be disabled in the settings
  * Add ability to reorder objects in a custom palette
  * Add ability to reorder custom palettes
  * Add ability to reorder presets
  * Create a standard "Plugin Defaults" preset which contains the default settings of the plugin
* Bugfixes
  * Fix mixed usage of path separators
  * Fix issue where previously selected preset was affected by creating a new preset


## 6.1.0
* Features
  * Added several "How To" guides on the Wiki: https://github.com/skybaks/tm-editor-helpers/wiki
* Bugfixes
  * Fix issue where cached inventory could become unstable when creating/deleting articles
  * Fix inventory not remembering the selected custom palette between reloads
  * Fix script exceptions in some MP4 titlepacks


## 6.0.0
* Features
  * Add Presets feature
    * Access Presets from **Windows | Presets**
    * Create a custom preset to recall specific settings at any time
    * Add an optional hotkey to each preset
  * Add "About" window to display the changelog for a new plugin version
  * Improvements to UI
    * "Custom Palette" renamed to "Editor Inventory"
    * Move toggle for Editor Inventory window from Display to "Windows" menu in each window's menu bar
    * Add separators between each specific function to add clarity and visible grouping to the UI
    * Add highlighting to function UI when hovering over settings for that function
    * Reorganize settings page to group by UI section
  * Create wiki on Github: https://github.com/skybaks/tm-editor-helpers/wiki
* Bugfixes
  * Slight improvement to wording of freeblock placement tooltips
  * Fix bug where entering editor does not update podium status
  * Fix bug where tab wouldnt autoselect when creating a new palette
  * Backend code cleanup for EditorFunction base class
  * Fix hotkeys not being enabled for MP4


## 5.15
* Refactor usage of class CSystemFids - No change to functionaity


## 5.14
* Fix issue with custom palette timing out when loading 10k+ custom items


## 5.13
* Update Default Block Modes function to allow enabling for specific modes only and add a quick-use interface to the "Build" display category
* Fix issue with custom palette not working properly with ghost and free block modes
* Fix backend hotkey management not getting properly cleaned up
* Optimize initialization code in the locator check function. It's hard work should only be done once now instead of every time you enter the editor
* Fix issue with locator check not correctly identifying game assets due to some unexpected naming oddities
* Fix default block modes not fully detecting all the possible place modes
* Fix default block modes to only display a mode if more than one setting is supported for the current game


## 5.12
* Added presets for the time of day to the Mood Changer. This has the game defaults but also includes some other interesting times.
* Fix podium reminder for TM 2020. Apparently placing more than one podium is perfectly valid.


## 5.11
* Small change to detection of podiums in map for generating reminders.
* Add new display of cursor position. This show the current X, Y, Z position of the block/item cursor.
* Rework the "Freeblock Mode Precise Translation" to have a similar interface to setting custom item placment grid. It now allows you to specify horizontal and vertical step for placement in addition to a translation offset.
* Added tons of new optional hotkeys which can control plugin functions if you prefer to use that instead of the GUI:
  * For Custom Item Placement settings: Toggle for Ghost Mode, Autorotation, Apply Custom Grid, and Apply Custom Pivot.
  * For Block Cursor Highlight: Toggle to show/hide block cursor
  * For Block Helpers: Toggle to show/hide clip helpers
  * For Custom Freeblock Placement: Toggle for Apply Custom Grid
  * For Visual Placement Grid: Toggle for show/hide grid and toggle for apply grid transparency
  * For Quicksave: Hotkey to save the map
  * For Custom Palette: Hotkey to quickswitch to last block/item/macroblock
* Add setting for activated hotkeys to generate a short notification
* Added new custom block/item palette function
  * Contains a searchable list of all blocks, items, and macroblocks in your editor
  * Keeps a history of blocks, items, and macroblocks that you use so that you can quickly switch back and forth.
  * Allows for you to build and customize your own palettes; a collection of blocks, items, or macroblocks
  * Randomizer function allow for you to randomize the current block, item, or macroblock from inside the current palette each time a block, item or macroblock is placed.


## 5.10
* nbeerten - Fix for 12/2022 TM update. There was an API change in the class CGameItemModel.


## 5.9
* Performance fix for Podium Reminder on maps with a large amount of blocks or items


## 5.8
* Update the behavior of item pivot position override. Previously, the item pivot position would be reset each time you select a new item. Now if the pivot position override is applied the pivot position will remain in place when switching between items. If the pivot position override is not applied then the display window will be updated with the item's current pivot position.
* Add new function - Podium Reminder - Displays a notification when saving if the map does not contain exactly one podium.


## 5.7
* Remove directive blocking non-paid players from loading the plugin


## 5.6
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