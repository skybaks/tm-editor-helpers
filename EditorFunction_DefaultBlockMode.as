namespace EditorHelpers
{
    [Setting category="DefaultBlockMode" name="Enabled"]
    bool settingDefaultBlockModeEnabled = true;
    [Setting category="DefaultBlockMode" name="Default Block Mode"]
    string settingDefaultBlockMode = "Normal";
    [Setting category="DefaultBlockMode" name="Default Item Mode"]
    string settingDefaultItemMode = "Normal";
    [Setting category="DefaultBlockMode" name="Default Macroblock Mode"]
    string settingDefaultMacroblockMode = "Normal";
    class DefaultBlockMode : EditorHelpers::EditorFunction
    {
        private string lastPlaceModeCategory;

        bool Enabled() override { return settingDefaultBlockModeEnabled; }

        void Init() override 
        {
            if (!Enabled() || Editor is null)
            {
                lastPlaceModeCategory = "";
            }
        }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            if (UI::CollapsingHeader("Default Block Modes"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Default when switching into block mode");
                    UI::SameLine();
                }
                if (UI::BeginCombo("Block Mode", settingDefaultBlockMode))
                {
                    if (UI::Selectable("Normal", false))
                    {
                        settingDefaultBlockMode = "Normal";
                    }
                    else if (UI::Selectable("Ghost", false))
                    {
                        settingDefaultBlockMode = "Ghost";
                    }
#if TMNEXT
                    else if (UI::Selectable("Free", false))
                    {
                        settingDefaultBlockMode = "Free";
                    }
#endif
                    UI::EndCombo();
                }

                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Default when switching into item mode");
                    UI::SameLine();
                }
                if (UI::BeginCombo("Item Mode", settingDefaultItemMode))
                {
                    if (UI::Selectable("Normal", false))
                    {
                        settingDefaultItemMode = "Normal";
                    }
#if TMNEXT
                    else if (UI::Selectable("Free Ground", false))
                    {
                        settingDefaultItemMode = "Free Ground";
                    }
#else
                    else if (UI::Selectable("Free", false))
                    {
                        settingDefaultItemMode = "Free";
                    }
                    UI::EndCombo();
                }

                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Default when switching into macroblock mode");
                    UI::SameLine();
                }
                if (UI::BeginCombo("Macroblock Mode", settingDefaultMacroblockMode))
                {
                    if (UI::Selectable("Normal", false))
                    {
                        settingDefaultMacroblockMode = "Normal";
                    }
#if TMNEXT
                    else if (UI::Selectable("Free", false))
                    {
                        settingDefaultMacroblockMode = "Free";
                    }
#endif
                    UI::EndCombo();
                }
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
                    if (settingDefaultBlockMode == "Normal")
                    {
#if TMNEXT
                        Editor.ButtonNormalBlockModeOnClick();
#else
                        Editor.ButtonInventoryBlocksOnClick();
#endif
                    }
                    else if (settingDefaultBlockMode == "Ghost")
                    {
#if TMNEXT
                        Editor.ButtonGhostBlockModeOnClick();
#else
                        Editor.ButtonInventoryGhostBlocksOnClick();
#endif
                    }
#if TMNEXT
                    else if (settingDefaultBlockMode == "Free")
                    {
                        Editor.ButtonFreeBlockModeOnClick();
                    }
#endif
                }
                else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
                {
                    if (settingDefaultItemMode == "Normal")
                    {
#if TMNEXT
                        Editor.ButtonNormalItemModeOnClick();
#else
                        Editor.ButtonInventoryObjectsOnClick();
#endif
                    }
#if TMNEXT
                    else if (settingDefaultItemMode == "Free Ground")
                    {
                        Editor.ButtonFreeGroundItemModeOnClick();
                    }
#endif
                    else if (settingDefaultItemMode == "Free")
                    {
#if TMNEXT
                        Editor.ButtonFreeItemModeOnClick();
#else
                        Editor.ButtonInventoryObjectsOnClick();
#endif
                    }
                }
                else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock)
                {
                    if (settingDefaultMacroblockMode == "Normal")
                    {
#if TMNEXT
                        Editor.ButtonNormalMacroblockModeOnClick();
#else
                        Editor.ButtonInventoryMacroBlocksOnClick();
#endif
                    }
#if TMNEXT
                    else if (settingDefaultMacroblockMode == "Free")
                    {
                        Editor.ButtonFreeMacroblockModeOnClick();
                    }
#endif
                }
            }
            lastPlaceModeCategory = currentPlaceModeCategory;
        }
    }
}