
namespace EditorHelpers
{
    [Setting category="RememberPlacementModes" name="Enabled"]
    bool settingRememberPlacementModesEnabled = true;
    [Setting category="RememberPlacementModes" name="Maintain Block/Item Mode After Test"]
    bool settingRememberPlacementModesMaintainBlockModeAfterTest = true;
    [Setting category="RememberPlacementModes" name="Maintain Selection Mode"]
    bool settingRememberPlacementModesMaintainSelectionMode = true;
    class RememberPlacementModes : EditorHelpers::EditorFunction
    {
        private string lastPlaceModeCategory;
        private CGameEditorPluginMap::EditMode lastSelectionEditMode;
        private bool lastSelectionModeAddSub;
        private string lastPlaceModeCategoryBeforeTest;

        bool Enabled() override { return settingRememberPlacementModesEnabled; }

        void Init() override 
        {
            if (!Enabled() || Editor is null)
            {
                lastPlaceModeCategory = "";
                lastSelectionEditMode = CGameEditorPluginMap::EditMode::Unknown;
                lastSelectionModeAddSub = false;
                lastPlaceModeCategoryBeforeTest = "";
            }
        }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            if (UI::CollapsingHeader("Remember Placement Modes"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Remember Block, Item, or Macroblock mode after 'Esc' from Test mode");
                    UI::SameLine();
                }
                settingRememberPlacementModesMaintainBlockModeAfterTest = UI::Checkbox("Maintain Block Mode After Test", settingRememberPlacementModesMaintainBlockModeAfterTest);
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Remember selection add or remove mode while using camera");
                    UI::SameLine();
                }
                settingRememberPlacementModesMaintainSelectionMode = UI::Checkbox("Maintain Copy Tool Selection Mode", settingRememberPlacementModesMaintainSelectionMode);
            }
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            string currentPlaceModeCategory = "Undefined";
            if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block
            || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::GhostBlock
            || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Unknown)
            {
                currentPlaceModeCategory = "Block";
            }
            else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
            {
                currentPlaceModeCategory = "Item";
            }
            else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock)
            {
                currentPlaceModeCategory = "Macroblock";
            }
            else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Test)
            {
                currentPlaceModeCategory = "Test";
            }

            if (lastPlaceModeCategory != currentPlaceModeCategory)
            {
                if (settingRememberPlacementModesMaintainBlockModeAfterTest
                && lastPlaceModeCategory == "Test")
                {
                    if (lastPlaceModeCategoryBeforeTest == "Block")
                    {
#if TMNEXT
                        Editor.ButtonNormalBlockModeOnClick();
#else
                        Editor.ButtonInventoryBlocksOnClick();
#endif
                    }
                    else if (lastPlaceModeCategoryBeforeTest == "Item")
                    {
#if TMNEXT
                        Editor.ButtonNormalItemModeOnClick();
#else
                        Editor.ButtonInventoryObjectsOnClick();
#endif
                    }
                    else if (lastPlaceModeCategoryBeforeTest == "Macroblock")
                    {
#if TMNEXT
                        Editor.ButtonNormalMacroblockModeOnClick();
#else
                        Editor.ButtonInventoryMacroBlocksOnClick();
#endif
                    }
                }
                if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Test)
                {
                    lastPlaceModeCategoryBeforeTest = lastPlaceModeCategory;
                }
            }

            if (settingRememberPlacementModesMaintainSelectionMode
            && Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::CopyPaste)
            {
                if (Editor.PluginMapType.EditMode == CGameEditorPluginMap::EditMode::SelectionAdd
                || Editor.PluginMapType.EditMode == CGameEditorPluginMap::EditMode::SelectionRemove)
                {
                    if (!lastSelectionModeAddSub)
                    {
                        if (lastSelectionEditMode == CGameEditorPluginMap::EditMode::SelectionAdd)
                        {
                            Editor.ButtonSelectionBoxAddModeOnClick();
                        }
                        else if (lastSelectionEditMode == CGameEditorPluginMap::EditMode::SelectionRemove)
                        {
                            Editor.ButtonSelectionBoxSubModeOnClick();
                        }
                    }
                    lastSelectionModeAddSub = true;
                    lastSelectionEditMode = Editor.PluginMapType.EditMode;
                }
                else
                {
                    lastSelectionModeAddSub = false;
                }
            }
            lastPlaceModeCategory = currentPlaceModeCategory;
        }
    }
}