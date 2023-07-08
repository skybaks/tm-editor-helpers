namespace EditorHelpers
{
    class DefaultBlockModePreset : EditorFunctionPresetBase
    {
        bool EnableBlockMode = true;
        string BlockMode = "Normal";
        bool BlockModeEnabled = false;
        bool EnableItemMode = true;
        string ItemMode = "Normal";
        bool ItemModeEnabled = false;
        bool EnableMacroblockMode = true;
        string MacroblockMode = "Normal";
        bool MacroblockModeEnabled = false;

        DefaultBlockModePreset()
        {
            super("Default Block Mode");
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_block_mode"] = EnableBlockMode;
            m_json["block_mode"] = BlockMode;
            m_json["block_mode_enabled"] = BlockModeEnabled;
            m_json["enable_item_mode"] = EnableItemMode;
            m_json["item_mode"] = ItemMode;
            m_json["item_mode_enabled"] = ItemModeEnabled;
            m_json["enable_macroblock_mode"] = EnableMacroblockMode;
            m_json["macroblock_mode"] = MacroblockMode;
            m_json["macroblock_mode_enabled"] = MacroblockModeEnabled;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableBlockMode = json.Get("enable_block_mode", Json::Value(true));
            BlockMode = json.Get("block_mode", Json::Value("Normal"));
            BlockModeEnabled = json.Get("block_mode_enabled", Json::Value(false));
            EnableItemMode = json.Get("enable_item_mode", Json::Value(true));
            ItemMode = json.Get("item_mode", Json::Value("Normal"));
            ItemModeEnabled = json.Get("item_mode_enabled", Json::Value(false));
            EnableMacroblockMode = json.Get("enable_macroblock_mode", Json::Value(true));
            MacroblockMode = json.Get("macroblock_mode", Json::Value("Normal"));
            MacroblockModeEnabled = json.Get("macroblock_mode_enabled", Json::Value(false));
        }
    }

    enum PlaceModeCategory
    {
        Block,
        Item,
        Macroblock,
        Undefined
    }

    namespace Compatibility
    {
        PlaceModeCategory GetCurrentPlaceModeCategory(CGameCtnEditorFree@ editor)
        {
            PlaceModeCategory placeMode = PlaceModeCategory::Undefined;

            if (editor !is null && editor.PluginMapType !is null)
            {
                if (editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block
                    || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::GhostBlock
#if TMNEXT
                    || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::FreeBlock
#endif
                    )
                {
                    placeMode = PlaceModeCategory::Block;
                }
                else if (editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
                {
                    placeMode = PlaceModeCategory::Item;
                }
                else if (editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock
#if TMNEXT
                    || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::FreeMacroblock
#endif
                    )
                {
                    placeMode = PlaceModeCategory::Macroblock;
                }
            }

            return placeMode;
        }

        void SetModeBlockNormal(CGameCtnEditorFree@ editor)
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

    class DefaultBlockMode : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
    {
        private PlaceModeCategory m_lastPlaceModeCategory;
        private bool m_functionalityDisabled;

        string Name() override { return "Default Block Mode"; }
        bool Enabled() override { return Setting_DefaultBlockMode_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_DefaultBlockMode_Enabled = UI::Checkbox("Enabled", Setting_DefaultBlockMode_Enabled);
            UI::BeginDisabled(!Setting_DefaultBlockMode_Enabled);
            UI::TextWrapped("This allows you to choose a default mode for block, item, and macroblock modes. That means"
                " that when you switch to block, item, or macroblock mode your default will be picked.");
            DisplayModeOptions();
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("DefaultBlockMode::Blocks");
                EditorHelpers::SetHighlightId("DefaultBlockMode::Items");
                EditorHelpers::SetHighlightId("DefaultBlockMode::Macroblocks");
            }

            UI::PopID();
        }

        void RenderInterface_MainWindow() override
        {
            if (!Enabled() || Editor is null)
            {
                return;
            }

            UI::BeginDisabled(m_functionalityDisabled);
            UI::TextDisabled("\tMode Defaults");
            DisplayModeOptions(true, true);
            UI::EndDisabled();
        }

        void Init() override 
        {
            if (!Enabled() || Editor is null)
            {
                m_lastPlaceModeCategory = PlaceModeCategory::Undefined;
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

            PlaceModeCategory currentPlaceModeCategory = Compatibility::GetCurrentPlaceModeCategory(Editor);
            if (m_lastPlaceModeCategory != currentPlaceModeCategory)
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
            m_lastPlaceModeCategory = currentPlaceModeCategory;
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

        private void DisplayModeOptions(bool includeToolTips = false, bool allowHighlights = false)
        {
            vec2 spacingOrig = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing);
            vec2 spacingNew = vec2(1.0, spacingOrig.y);

            if (Compatibility::SelectableBlockModes.Length > 1)
            {
                if (allowHighlights) { EditorHelpers::BeginHighlight("DefaultBlockMode::Blocks"); }
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
                if (allowHighlights) { EditorHelpers::EndHighlight(); }
            }

            if (Compatibility::SelectableItemModes.Length > 1)
            {
                if (allowHighlights) { EditorHelpers::BeginHighlight("DefaultBlockMode::Items"); }
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
                if (allowHighlights) { EditorHelpers::EndHighlight(); }
            }

            if (Compatibility::SelectableMacroblockModes.Length > 1)
            {
                if (allowHighlights) { EditorHelpers::BeginHighlight("DefaultBlockMode::Macroblocks"); }
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
                if (allowHighlights) { EditorHelpers::EndHighlight(); }
            }
        }

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return DefaultBlockModePreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            DefaultBlockModePreset@ preset = cast<DefaultBlockModePreset>(data);
            if (preset is null) { return; }
            preset.BlockMode = Setting_DefaultBlockMode_BlockMode;
            preset.BlockModeEnabled = Setting_DefaultBlockMode_ActiveBlock;
            preset.ItemMode = Setting_DefaultBlockMode_ItemMode;
            preset.ItemModeEnabled = Setting_DefaultBlockMode_ActiveItem;
            preset.MacroblockMode = Setting_DefaultBlockMode_MacroblockMode;
            preset.MacroblockModeEnabled = Setting_DefaultBlockMode_ActiveMacroblock;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            DefaultBlockModePreset@ preset = cast<DefaultBlockModePreset>(data);
            if (preset is null) { return; }
            if (preset.EnableBlockMode)
            {
                Setting_DefaultBlockMode_BlockMode = preset.BlockMode;
                Setting_DefaultBlockMode_ActiveBlock = preset.BlockModeEnabled;
            }
            if (preset.EnableItemMode)
            {
                Setting_DefaultBlockMode_ItemMode = preset.ItemMode;
                Setting_DefaultBlockMode_ActiveItem = preset.ItemModeEnabled;
            }
            if (preset.EnableMacroblockMode)
            {
                Setting_DefaultBlockMode_MacroblockMode = preset.MacroblockMode;
                Setting_DefaultBlockMode_ActiveMacroblock = preset.MacroblockModeEnabled;
            }
        }

        bool CheckPreset(EditorFunctionPresetBase@ data) override
        {
            bool areSame = true;
            if (!Enabled()) { return areSame; }
            DefaultBlockModePreset@ preset = cast<DefaultBlockModePreset>(data);
            if (preset is null) { return areSame; }
            if (preset.EnableBlockMode)
            {
                if (Setting_DefaultBlockMode_BlockMode != preset.BlockMode
                    || Setting_DefaultBlockMode_ActiveBlock != preset.BlockModeEnabled) { areSame = false; }
            }
            if (preset.EnableItemMode)
            {
                if (Setting_DefaultBlockMode_ItemMode != preset.ItemMode
                    || Setting_DefaultBlockMode_ActiveItem != preset.ItemModeEnabled) { areSame = false; }
            }
            if (preset.EnableMacroblockMode)
            {
                if (Setting_DefaultBlockMode_MacroblockMode != preset.MacroblockMode
                    || Setting_DefaultBlockMode_ActiveMacroblock != preset.MacroblockModeEnabled) { areSame = false; }
            }
            return areSame;
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            DefaultBlockModePreset@ preset = cast<DefaultBlockModePreset>(data);
            if (preset is null) { return; }
            if (preset.EnableBlockMode)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Block Mode");
                UI::TableNextColumn();
                UI::Text(preset.BlockMode);

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Block Mode Active");
                UI::TableNextColumn();
                UI::Text(tostring(preset.BlockModeEnabled));
            }
            if (preset.EnableItemMode)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Item Mode");
                UI::TableNextColumn();
                UI::Text(preset.ItemMode);

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Item Mode Active");
                UI::TableNextColumn();
                UI::Text(tostring(preset.ItemModeEnabled));
            }
            if (preset.EnableMacroblockMode)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Macroblock Mode");
                UI::TableNextColumn();
                UI::Text(preset.MacroblockMode);

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Macroblock Mode Active");
                UI::TableNextColumn();
                UI::Text(tostring(preset.MacroblockModeEnabled));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            DefaultBlockModePreset@ preset = cast<DefaultBlockModePreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableBlockMode, preset.EnableBlockMode, "Block mode", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("DefaultBlockMode::Blocks");
            }
            if (ForcedCheckbox(preset.EnableItemMode, preset.EnableItemMode, "Item mode", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("DefaultBlockMode::Items");
            }
            if (ForcedCheckbox(preset.EnableMacroblockMode, preset.EnableMacroblockMode, "Macroblock mode", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("DefaultBlockMode::Macroblocks");
            }
            return changed;
        }
    }
}
