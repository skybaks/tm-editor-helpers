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

        enum SelectableBlockModes
        {
            Normal
            , Ghost
#if TMNEXT
            , Free
#endif
        }

        enum SelectableItemModes
        {
            Normal
#if TMNEXT
            , FreeGround
            , Free
#endif
        }

        enum SelectableMacroblockModes
        {
            Normal
#if TMNEXT
            , Free
#endif
        }
    }

    [Setting category="Functions" name="DefaultBlockMode: Enabled" description="Uncheck to disable all plugin functions related to DefaultBlockMode"]
    bool Setting_DefaultBlockMode_Enabled = true;
    [Setting category="Functions" name="DefaultBlockMode: Default Block Mode" description="Default when switching into block mode"]
    EditorHelpers::Compatibility::SelectableBlockModes Setting_DefaultBlockMode_BlockMode = Compatibility::SelectableBlockModes::Normal;
    [Setting category="Functions" name="DefaultBlockMode: Default Item Mode" description="Default when switching into item mode"]
    EditorHelpers::Compatibility::SelectableItemModes Setting_DefaultBlockMode_ItemMode = Compatibility::SelectableItemModes::Normal;
    [Setting category="Functions" name="DefaultBlockMode: Default Macroblock Mode" description="Default when switching into macroblock mode"]
    EditorHelpers::Compatibility::SelectableMacroblockModes Setting_DefaultBlockMode_MacroblockMode = Compatibility::SelectableMacroblockModes::Normal;
    class DefaultBlockMode : EditorHelpers::EditorFunction
    {
        private string lastPlaceModeCategory;

        bool Enabled() override { return Setting_DefaultBlockMode_Enabled; }

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