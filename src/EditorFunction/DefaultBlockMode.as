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
    [Setting category="Functions" name="DefaultBlockMode: Block Mode Active" hidden]
    bool Setting_DefaultBlockMode_ActiveBlock = true;
    [Setting category="Functions" name="DefaultBlockMode: Item Mode Active" hidden]
    bool Setting_DefaultBlockMode_ActiveItem = true;
    [Setting category="Functions" name="DefaultBlockMode: Macroblock Mode Active" hidden]
    bool Setting_DefaultBlockMode_ActiveMacroblock = true;

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

            Setting_DefaultBlockMode_ActiveBlock = UI::Checkbox("Default Block Mode:", Setting_DefaultBlockMode_ActiveBlock);
            UI::SameLine();
            UI::BeginDisabled(!Setting_DefaultBlockMode_ActiveBlock);
            Setting_DefaultBlockMode_BlockMode = DisplayRadioSelection("Block", Compatibility::SelectableBlockModes, Setting_DefaultBlockMode_BlockMode);
            UI::EndDisabled();

            Setting_DefaultBlockMode_ActiveItem = UI::Checkbox("Default Item Mode:", Setting_DefaultBlockMode_ActiveItem);
            UI::SameLine();
            UI::BeginDisabled(!Setting_DefaultBlockMode_ActiveItem);
            Setting_DefaultBlockMode_ItemMode = DisplayRadioSelection("Item", Compatibility::SelectableItemModes, Setting_DefaultBlockMode_ItemMode);
            UI::EndDisabled();

            Setting_DefaultBlockMode_ActiveMacroblock = UI::Checkbox("Default Macroblock Mode:", Setting_DefaultBlockMode_ActiveMacroblock);
            UI::SameLine();
            UI::BeginDisabled(!Setting_DefaultBlockMode_ActiveMacroblock);
            Setting_DefaultBlockMode_MacroblockMode = DisplayRadioSelection("Macroblock", Compatibility::SelectableMacroblockModes, Setting_DefaultBlockMode_MacroblockMode);
            UI::EndDisabled();

            UI::EndDisabled();
            UI::PopID();
        }

        void RenderInferface_Build()
        {
            if (!Enabled() || Editor is null)
            {
                return;
            }
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
                if (Setting_DefaultBlockMode_ActiveBlock
                    && Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block)
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
                else if (Setting_DefaultBlockMode_ActiveItem
                    && Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
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
                else if (Setting_DefaultBlockMode_ActiveMacroblock
                    && Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock)
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

        private string DisplayRadioSelection(const string&in idName, const string[]@ options, const string&in selection)
        {
            string newSelection = selection;
            for (uint i = 0; i < options.Length; i++)
            {
                if (UI::RadioButton(options[i] + "##" + idName, options[i] == selection))
                {
                    newSelection = options[i];
                }
                if (i < (options.Length - 1))
                {
                    UI::SameLine();
                }
            }
            return newSelection;
        }
    }
}