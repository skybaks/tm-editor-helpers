namespace EditorHelpers
{
    namespace Compatibility
    {
        void SetModeBlockNormal(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonNormalBlockModeOnClick();
#else
            if (editor.PluginMapType.PlaceMode != CGameEditorPluginMap::EPlaceMode::Block)
            {
                editor.PluginMapType.PlaceMode = CGameEditorPluginMap::EPlaceMode::Block;
            }
#endif
        }

        void SetModeBlockGhost(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonGhostBlockModeOnClick();
#else
            editor.ButtonInventoryGhostBlocksOnClick();
#endif
        }

        void SetModeBlockFree(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonFreeBlockModeOnClick();
#endif
        }

        void SetModeItemNormal(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonNormalItemModeOnClick();
#else
            // TODO: Need way to differentiate between Free and Normal Item Mode
            // editor.ButtonInventoryObjectsOnClick();
#endif
        }

        void SetModeItemFreeGround(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonFreeGroundItemModeOnClick();
#endif
        }

        void SetModeItemFree(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonFreeItemModeOnClick();
#else
            // TODO: Need way to differentiate between Free and Normal Item Mode
            // editor.ButtonInventoryObjectsOnClick();
#endif
        }

        void SetModeMacroblockNormal(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonNormalMacroblockModeOnClick();
#endif
        }

        void SetModeMacroblockFree(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            editor.ButtonFreeMacroblockModeOnClick();
#endif
        }

        string[] SelectableBlockModes =
        {
            "Normal"
            , "Ghost"
#if TMNEXT
            , "Free"
#endif
        };

        string[] SelectableItemModes =
        {
            "Normal"
#if TMNEXT
            , "FreeGround"
            , "Free"
#endif
        };

        string[] SelectableMacroblockModes =
        {
            "Normal"
#if TMNEXT
            , "Free"
#endif
        };
    }

    [Setting category="Functions" name="DefaultBlockMode: Enabled" hidden]
    bool Setting_DefaultBlockMode_Enabled = false;
    [Setting category="Functions" name="DefaultBlockMode: Default Block Mode" hidden]
    string Setting_DefaultBlockMode_BlockMode = "Normal";
    [Setting category="Functions" name="DefaultBlockMode: Default Item Mode" hidden]
    string Setting_DefaultBlockMode_ItemMode = "Normal";
    [Setting category="Functions" name="DefaultBlockMode: Default Macroblock Mode" hidden]
    string Setting_DefaultBlockMode_MacroblockMode = "Normal";

    class DefaultBlockMode : EditorHelpers::EditorFunction
    {
        private string lastPlaceModeCategory;

        string Name() override { return "Default Block Mode"; }
        bool Enabled() override { return Setting_DefaultBlockMode_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_DefaultBlockMode_Enabled = UI::Checkbox("Enabled", Setting_DefaultBlockMode_Enabled);
            UI::BeginDisabled(!Setting_DefaultBlockMode_Enabled);
            UI::TextWrapped("This allows you to choose a default mode for block, item, and macroblock modes. That means that when you switch to block, item, or macroblock mode your default will be picked.");

            UI::Text("Default Block Mode:");
            UI::SameLine();
            for (uint i = 0; i < Compatibility::SelectableBlockModes.Length; i++)
            {
                if (UI::RadioButton(Compatibility::SelectableBlockModes[i] + "##Block", Compatibility::SelectableBlockModes[i] == Setting_DefaultBlockMode_BlockMode))
                {
                    Setting_DefaultBlockMode_BlockMode = Compatibility::SelectableBlockModes[i];
                }
                if (i < (Compatibility::SelectableBlockModes.Length - 1))
                {
                    UI::SameLine();
                }
            }

            UI::Text("Default Item Mode:");
            UI::SameLine();
            for (uint i = 0; i < Compatibility::SelectableItemModes.Length; i++)
            {
                if (UI::RadioButton(Compatibility::SelectableItemModes[i] + "##Item", Compatibility::SelectableItemModes[i] == Setting_DefaultBlockMode_ItemMode))
                {
                    Setting_DefaultBlockMode_ItemMode = Compatibility::SelectableItemModes[i];
                }
                if (i < (Compatibility::SelectableItemModes.Length - 1))
                {
                    UI::SameLine();
                }
            }

            UI::Text("Default Macroblock Mode:");
            UI::SameLine();
            for (uint i = 0; i < Compatibility::SelectableMacroblockModes.Length; i++)
            {
                if (UI::RadioButton(Compatibility::SelectableMacroblockModes[i] + "##Macroblock", Compatibility::SelectableMacroblockModes[i] == Setting_DefaultBlockMode_MacroblockMode))
                {
                    Setting_DefaultBlockMode_MacroblockMode = Compatibility::SelectableMacroblockModes[i];
                }
                if (i < (Compatibility::SelectableMacroblockModes.Length - 1))
                {
                    UI::SameLine();
                }
            }

            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override 
        {
            if (!Enabled() || Editor is null)
            {
                lastPlaceModeCategory = "";
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

            if (lastPlaceModeCategory != currentPlaceModeCategory)
            {

                if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block)
                {
                    if (tostring(Setting_DefaultBlockMode_BlockMode) == "Normal")
                    {
                        Compatibility::SetModeBlockNormal(Editor);
                    }
                    else if (tostring(Setting_DefaultBlockMode_BlockMode) == "Ghost")
                    {
                        Compatibility::SetModeBlockGhost(Editor);
                    }
                    else if (tostring(Setting_DefaultBlockMode_BlockMode) == "Free")
                    {
                        Compatibility::SetModeBlockFree(Editor);
                    }
                }
                else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
                {
                    if (tostring(Setting_DefaultBlockMode_ItemMode) == "Normal")
                    {
                        Compatibility::SetModeItemNormal(Editor);
                    }
                    else if (tostring(Setting_DefaultBlockMode_ItemMode) == "FreeGround")
                    {
                        Compatibility::SetModeItemFreeGround(Editor);
                    }
                    else if (tostring(Setting_DefaultBlockMode_ItemMode) == "Free")
                    {
                        Compatibility::SetModeItemFree(Editor);
                    }
                }
                else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock)
                {
                    if (tostring(Setting_DefaultBlockMode_MacroblockMode) == "Normal")
                    {
                        Compatibility::SetModeMacroblockNormal(Editor);
                    }
                    else if (tostring(Setting_DefaultBlockMode_MacroblockMode) == "Free")
                    {
                        Compatibility::SetModeMacroblockFree(Editor);
                    }
                }
            }
            lastPlaceModeCategory = currentPlaceModeCategory;
        }
    }
}