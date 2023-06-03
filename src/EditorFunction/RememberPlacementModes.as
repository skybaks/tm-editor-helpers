
namespace EditorHelpers
{
    namespace Compatibility
    {
        void SetModeBlock(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonNormalBlockModeOnClick();
#else
            if (editor !is null
                && editor.PluginMapType !is null
                && editor.PluginMapType.PlaceMode != CGameEditorPluginMap::EPlaceMode::Block)
            {
                editor.PluginMapType.PlaceMode = CGameEditorPluginMap::EPlaceMode::Block;
            }
#endif
        }

        void SetModeItem(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonNormalItemModeOnClick();
#else
            editor.ButtonInventoryObjectsOnClick();
#endif
        }

        void SetModeMacroblock(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonNormalMacroblockModeOnClick();
#else
            editor.ButtonInventoryMacroBlocksOnClick();
#endif
        }

        bool EnableCopySelectionTool()
        {
#if TMNEXT
            return true;
#else
            return false;
#endif
        }
    }

    [Setting category="Functions" name="RememberPlacementModes: Enabled" hidden]
    bool Setting_RememberPlacementModes_Enabled = true;
    [Setting category="Functions" name="RememberPlacementModes: Maintain Block/Item Mode After Test" hidden]
    bool Setting_RememberPlacementModes_MaintainBlockModeAfterTest = true;
    [Setting category="Functions" name="RememberPlacementModes: Maintain Selection Mode" hidden]
    bool Setting_RememberPlacementModes_MaintainSelectionMode = true;

    class RememberPlacementModes : EditorHelpers::EditorFunction
    {
        private string lastPlaceModeCategory;
        private CGameEditorPluginMap::EditMode lastSelectionEditMode;
        private bool lastSelectionModeAddSub;
        private string lastPlaceModeCategoryBeforeTest;
        private bool m_functionalityDisabled;

        string Name() override { return "Remember Placement Modes"; }
        bool Enabled() override { return Setting_RememberPlacementModes_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_RememberPlacementModes_Enabled = UI::Checkbox("Enabled", Setting_RememberPlacementModes_Enabled);
            UI::BeginDisabled(!Setting_RememberPlacementModes_Enabled);
            UI::TextWrapped("This function will remember the placement mode you were using before testing your map and switch you back to it afterwards. For example, if you were in Item or Macroblock modes prior to entering test mode then this can switch you back to those modes instead of always to block mode. This works best when you use the ESC or CTRL keys to leave test mode (when the car is in your cursor). Additionally, the option to remember add or remove selection modes between camera usage covers the case where you are using remove selection mode and you move the camera. In that case the plugin will return you to remove selection mode instead of the default behavior to always return you to add selection mode.");
            Setting_RememberPlacementModes_MaintainBlockModeAfterTest = UI::Checkbox("Remember placement mode after exiting test mode", Setting_RememberPlacementModes_MaintainBlockModeAfterTest);
            Setting_RememberPlacementModes_MaintainSelectionMode = UI::Checkbox("Remember selection add/remove mode after using camera", Setting_RememberPlacementModes_MaintainSelectionMode);
            UI::EndDisabled();
            UI::PopID();
        }

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

        void Update(float) override
        {
            if (!Enabled() || Editor is null || Editor.PluginMapType is null)
            {
                m_functionalityDisabled = true;
                return;
            }
            else
            {
                m_functionalityDisabled = false;
            }

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
                if (Setting_RememberPlacementModes_MaintainBlockModeAfterTest
                && lastPlaceModeCategory == "Test")
                {
                    if (lastPlaceModeCategoryBeforeTest == "Block")
                    {
                        Compatibility::SetModeBlock(Editor);
                    }
                    else if (lastPlaceModeCategoryBeforeTest == "Item")
                    {
                        Compatibility::SetModeItem(Editor);
                    }
                    else if (lastPlaceModeCategoryBeforeTest == "Macroblock")
                    {
                        Compatibility::SetModeMacroblock(Editor);
                    }
                }
                if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Test)
                {
                    lastPlaceModeCategoryBeforeTest = lastPlaceModeCategory;
                }
            }

            if (Compatibility::EnableCopySelectionTool()
                &&  Setting_RememberPlacementModes_MaintainSelectionMode
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