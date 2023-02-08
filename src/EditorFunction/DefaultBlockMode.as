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
    bool Setting_DefaultBlockMode_Enabled = true;
    [Setting category="Functions" name="DefaultBlockMode: Default Block Mode" hidden]
    string Setting_DefaultBlockMode_BlockMode = "Normal";
    [Setting category="Functions" name="DefaultBlockMode: Default Item Mode" hidden]
    string Setting_DefaultBlockMode_ItemMode = "Normal";
    [Setting category="Functions" name="DefaultBlockMode: Default Macroblock Mode" hidden]
    string Setting_DefaultBlockMode_MacroblockMode = "Normal";
    [Setting category="Functions" name="DefaultBlockMode: Block Mode Active" hidden]
    bool Setting_DefaultBlockMode_ActiveBlock = false;
    [Setting category="Functions" name="DefaultBlockMode: Item Mode Active" hidden]
    bool Setting_DefaultBlockMode_ActiveItem = false;
    [Setting category="Functions" name="DefaultBlockMode: Macroblock Mode Active" hidden]
    bool Setting_DefaultBlockMode_ActiveMacroblock = false;

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

            DisplayModeOptions();

            UI::EndDisabled();
            UI::PopID();
        }

        void RenderInterface_Build() override
        {
            if (!Enabled() || Editor is null)
            {
                return;
            }

            UI::TextDisabled("\tMode Defaults");
            DisplayModeOptions(true);
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

        private void DisplayModeOptions(bool includeToolTips = false)
        {
            vec2 spacingOrig = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing);
            vec2 spacingNew = vec2(1.0, spacingOrig.y);

            if (includeToolTips && settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Enable and set the default block mode to use");
                UI::SameLine();
            }
            Setting_DefaultBlockMode_ActiveBlock = UI::Checkbox("Block:", Setting_DefaultBlockMode_ActiveBlock);
            UI::PushStyleVar(UI::StyleVar::ItemSpacing, spacingNew);
            UI::SameLine();
            UI::BeginDisabled(!Setting_DefaultBlockMode_ActiveBlock);
            Setting_DefaultBlockMode_BlockMode = DisplayRadioSelection("Block", Compatibility::SelectableBlockModes, Setting_DefaultBlockMode_BlockMode);
            UI::EndDisabled();
            UI::PopStyleVar();

            if (includeToolTips && settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Enable and set the default item mode to use");
                UI::SameLine();
            }
            Setting_DefaultBlockMode_ActiveItem = UI::Checkbox("Item:", Setting_DefaultBlockMode_ActiveItem);
            UI::PushStyleVar(UI::StyleVar::ItemSpacing, spacingNew);
            UI::SameLine();
            UI::BeginDisabled(!Setting_DefaultBlockMode_ActiveItem);
            Setting_DefaultBlockMode_ItemMode = DisplayRadioSelection("Item", Compatibility::SelectableItemModes, Setting_DefaultBlockMode_ItemMode);
            UI::EndDisabled();
            UI::PopStyleVar();

            if (includeToolTips && settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Enable and set the default macroblock mode to use");
                UI::SameLine();
            }
            Setting_DefaultBlockMode_ActiveMacroblock = UI::Checkbox("Macroblock:", Setting_DefaultBlockMode_ActiveMacroblock);
            UI::PushStyleVar(UI::StyleVar::ItemSpacing, spacingNew);
            UI::SameLine();
            UI::BeginDisabled(!Setting_DefaultBlockMode_ActiveMacroblock);
            Setting_DefaultBlockMode_MacroblockMode = DisplayRadioSelection("Macroblock", Compatibility::SelectableMacroblockModes, Setting_DefaultBlockMode_MacroblockMode);
            UI::EndDisabled();
            UI::PopStyleVar();
        }
    }
}
