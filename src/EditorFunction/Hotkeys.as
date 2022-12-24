
namespace EditorHelpers
{
    namespace Compatibility
    {
        void ToggleAirBlockMode(CGameCtnEditorFree@ Editor)
        {
#if TMNEXT
            if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block
                || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::GhostBlock
                || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::FreeBlock)
            {
                Editor.ButtonAirBlockModeOnClick();
            }
#endif
        }

        void SetNextMapElemColor(CGameCtnEditorFree@ Editor, int color)
        {
#if TMNEXT
            Editor.PluginMapType.NextMapElemColor = CGameEditorPluginMap::EMapElemColor(color);
#endif
        }

        int GetCurrentMapElemColor(CGameCtnEditorFree@ Editor)
        {
            int elemColor = 0;
#if TMNEXT
            elemColor = int(Editor.PluginMapType.NextMapElemColor);
#elif MP4
#endif
            return elemColor;
        }

        bool EnableHotkeysFunction()
        {
#if TMNEXT
#elif MP4
            Setting_Hotkeys_Enabled = false;
#endif
            return Setting_Hotkeys_Enabled;
        }
    }

    [Setting category="Functions" name="Hotkeys: Hotkeys Function Enabled" hidden]
    bool Setting_Hotkeys_Enabled = true;
    [Setting category="Functions" name="Hotkeys: Show Activation Notification" hidden]
    bool Setting_Hotkeys_ShowActivationNotification = false;

    [Setting category="Functions" name="Hotkeys: AirBlockHotKey Enabled" hidden]
    bool Setting_Hotkeys_AirBlockHotKeyEnabled = true;
    [Setting category="Functions" name="Hotkeys: AirBlockHotKey" hidden]
    VirtualKey Setting_Hotkeys_AirBlockHotKey = VirtualKey::A;

    [Setting category="Functions" name="Hotkeys: ToggleColors HotKey Enabled" hidden]
    bool Setting_Hotkeys_ToggleColorsHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: ToggleColors HotKey" hidden]
    VirtualKey Setting_Hotkeys_ToggleColorsHotKey = VirtualKey::F6;

    [Setting category="Functions" name="Hotkeys: FlipCursor180 HotKey Enabled" hidden]
    bool Setting_Hotkeys_FlipCursor180HotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: FlipCursor180 HotKey" hidden]
    VirtualKey Setting_Hotkeys_FlipCursor180HotKey = VirtualKey::OemPeriod;

    // Plugin: BlockCursor

    [Setting category="Functions" name="Hotkeys: BlockCursorToggleHide HotKey Enabled" hidden]
    bool Setting_Hotkeys_BlockCursorToggleHideHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomItemGhost HotKey" hidden]
    VirtualKey Setting_Hotkeys_BlockCursorToggleHideHotKey = VirtualKey::O;

    // Plugin: BlockHelpers

    [Setting category="Functions" name="Hotkeys: BlockHelpersToggle HotKey Enabled" hidden]
    bool Setting_Hotkeys_BlockHelpersToggleHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomItemGhost HotKey" hidden]
    VirtualKey Setting_Hotkeys_BlockHelpersToggleHotKey = VirtualKey::L;

    // Plugin: CustomItemPlacement

    [Setting category="Functions" name="Hotkeys: CustomItemGhost HotKey Enabled" hidden]
    bool Setting_Hotkeys_CustomItemGhostHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomItemGhost HotKey" hidden]
    VirtualKey Setting_Hotkeys_CustomItemGhostHotKey = VirtualKey::G;

    [Setting category="Functions" name="Hotkeys: CustomItemAutoRotation HotKey Enabled" hidden]
    bool Setting_Hotkeys_CustomItemAutoRotationHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomItemAutoRotation HotKey" hidden]
    VirtualKey Setting_Hotkeys_CustomItemAutoRotationHotKey = VirtualKey::Y;

    [Setting category="Functions" name="Hotkeys: CustomItemGrid HotKey Enabled" hidden]
    bool Setting_Hotkeys_CustomItemGridHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomItemGrid HotKey" hidden]
    VirtualKey Setting_Hotkeys_CustomItemGridHotKey = VirtualKey::I;

    [Setting category="Functions" name="Hotkeys: CustomItemPivot HotKey Enabled" hidden]
    bool Setting_Hotkeys_CustomItemPivotHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomItemPivot HotKey" hidden]
    VirtualKey Setting_Hotkeys_CustomItemPivotHotKey = VirtualKey::U;

    // Plugin: CustomPalette

    [Setting category="Functions" name="Hotkeys: CustomPaletteQuickswitchPrevious HotKey Enabled" hidden]
    bool Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomPaletteQuickswitchPrevious HotKey" hidden]
    VirtualKey Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKey = VirtualKey::B;

    // Plugin: FreeblockPlacement

    [Setting category="Functions" name="Hotkeys: FreeblockPlacementApplyGrid HotKey Enabled" hidden]
    bool Setting_Hotkeys_FreeblockPlacementApplyGridHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: FreeblockPlacementApplyGrid HotKey" hidden]
    VirtualKey Setting_Hotkeys_FreeblockPlacementApplyGridHotKey = VirtualKey::K;

    // Plugin: PlacementGrid

    [Setting category="Functions" name="Hotkeys: VisualPlacementGridOn HotKey Enabled" hidden]
    bool Setting_Hotkeys_VisualPlacementGridOnHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: VisualPlacementGridOn HotKey" hidden]
    VirtualKey Setting_Hotkeys_VisualPlacementGridOnHotKey = VirtualKey::J;

    [Setting category="Functions" name="Hotkeys: VisualPlacementGridTransparent HotKey Enabled" hidden]
    bool Setting_Hotkeys_VisualPlacementGridTransparentHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: VisualPlacementGridOn HotKey" hidden]
    VirtualKey Setting_Hotkeys_VisualPlacementGridTransparentHotKey = VirtualKey::N;

    // Plugin: Quicksave

    [Setting category="Functions" name="Hotkeys: ActivateQuicksave HotKey Enabled" hidden]
    bool Setting_Hotkeys_ActivateQuicksaveHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: ActivateQuicksave HotKey" hidden]
    VirtualKey Setting_Hotkeys_ActivateQuicksaveHotKey = VirtualKey::D;

    class Hotkeys : EditorHelpers::EditorFunction
    {
        private VirtualKey[] m_keysDown = {};
        private int m_mapElemColorPrev = 0;
        private int m_mapElemColorPrevPrev = 0;

        private string m_rebindKeyName = "";

        string Name() override { return "Hotkeys"; }
        bool Enabled() override { return Compatibility::EnableHotkeysFunction(); }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_Hotkeys_Enabled = UI::Checkbox("Enabled", Setting_Hotkeys_Enabled);
            UI::BeginDisabled(!Setting_Hotkeys_Enabled);
            UI::TextWrapped("Adds some custom hotkeys to the editor to manage things that are not already hotkeys in the game. It is recommended (but not required) to map these to hotkeys not already used by the game.");
            Setting_Hotkeys_ShowActivationNotification = UI::Checkbox("Display a notification when hotkeys are activated", Setting_Hotkeys_ShowActivationNotification);
            if (UI::BeginTable("SettingsHotkeysTable", 4 /*columns*/, UI::TableFlags::SizingFixedFit))
            {
                UI::TableSetupColumn("Action");
                UI::TableSetupColumn("Key");
                UI::TableSetupColumn("Enabled");
                UI::TableSetupColumn("");
                UI::TableHeadersRow();

                HotkeySettingsTableRow("Toggle AirBlock Mode", "AirBlockHotkey", Setting_Hotkeys_AirBlockHotKey, Setting_Hotkeys_AirBlockHotKeyEnabled, Setting_Hotkeys_AirBlockHotKeyEnabled);
                HotkeySettingsTableRow("Quickswitch To Last Color", "ToggleColors", Setting_Hotkeys_ToggleColorsHotKey, Setting_Hotkeys_ToggleColorsHotKeyEnabled, Setting_Hotkeys_ToggleColorsHotKeyEnabled);
                HotkeySettingsTableRow("Flip Block 180 deg", "FlipCursor180", Setting_Hotkeys_FlipCursor180HotKey, Setting_Hotkeys_FlipCursor180HotKeyEnabled, Setting_Hotkeys_FlipCursor180HotKeyEnabled);
                HotkeySettingsTableRow("Toggle Hide Block Cursor", "BlockCursorToggleHide", Setting_Hotkeys_BlockCursorToggleHideHotKey, Setting_Hotkeys_BlockCursorToggleHideHotKeyEnabled, Setting_Hotkeys_BlockCursorToggleHideHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Block Helpers", "BlockHelpersToggle", Setting_Hotkeys_BlockHelpersToggleHotKey, Setting_Hotkeys_BlockHelpersToggleHotKeyEnabled, Setting_Hotkeys_BlockHelpersToggleHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Apply Custom Item Ghost Mode", "CustomItemGhost", Setting_Hotkeys_CustomItemGhostHotKey, Setting_Hotkeys_CustomItemGhostHotKeyEnabled, Setting_Hotkeys_CustomItemGhostHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Apply Custom Item AutoRotation", "CustomItemAutoRotation", Setting_Hotkeys_CustomItemAutoRotationHotKey, Setting_Hotkeys_CustomItemAutoRotationHotKeyEnabled, Setting_Hotkeys_CustomItemAutoRotationHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Apply Custom Item Grid", "CustomItemGrid", Setting_Hotkeys_CustomItemGridHotKey, Setting_Hotkeys_CustomItemGridHotKeyEnabled, Setting_Hotkeys_CustomItemGridHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Apply Custom Item Pivot", "CustomItemPivot", Setting_Hotkeys_CustomItemPivotHotKey, Setting_Hotkeys_CustomItemPivotHotKeyEnabled, Setting_Hotkeys_CustomItemPivotHotKeyEnabled);
                HotkeySettingsTableRow("Quickswitch To Previous Block/Item/Macroblock", "CustomPaletteQuickswitchPrevious", Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKey, Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKeyEnabled, Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Apply Custom Freeblock Grid", "FreeblockPlacementApplyGrid", Setting_Hotkeys_FreeblockPlacementApplyGridHotKey, Setting_Hotkeys_FreeblockPlacementApplyGridHotKeyEnabled, Setting_Hotkeys_FreeblockPlacementApplyGridHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Show Editor Placement Grid", "VisualPlacementGridOn", Setting_Hotkeys_VisualPlacementGridOnHotKey, Setting_Hotkeys_VisualPlacementGridOnHotKeyEnabled, Setting_Hotkeys_VisualPlacementGridOnHotKeyEnabled);
                HotkeySettingsTableRow("Toggle Editor Placement Grid Transparency", "VisualPlacementGridTransparent", Setting_Hotkeys_VisualPlacementGridTransparentHotKey, Setting_Hotkeys_VisualPlacementGridTransparentHotKeyEnabled, Setting_Hotkeys_VisualPlacementGridTransparentHotKeyEnabled);
                HotkeySettingsTableRow("Quicksave", "ActivateQuicksave", Setting_Hotkeys_ActivateQuicksaveHotKey, Setting_Hotkeys_ActivateQuicksaveHotKeyEnabled, Setting_Hotkeys_ActivateQuicksaveHotKeyEnabled);

                UI::EndTable();
            }
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                m_keysDown.RemoveRange(0, m_keysDown.Length - 1);
                m_mapElemColorPrev = 0;
                m_mapElemColorPrevPrev = 0;
            }
        }

        void RenderInterface_Action() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Plugin Hotkeys are managed in the settings");
                UI::SameLine();
            }
            UI::Text("Hover for Active Hotkeys");
            if (UI::IsItemHovered())
            {
                UI::BeginTooltip();
                string activeHotkeysHelper = "";
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Airblock Mode", Setting_Hotkeys_AirBlockHotKey, Setting_Hotkeys_AirBlockHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Quickswitch Last Element Color", Setting_Hotkeys_ToggleColorsHotKey, Setting_Hotkeys_ToggleColorsHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Flip Block/Item 180 degrees", Setting_Hotkeys_FlipCursor180HotKey, Setting_Hotkeys_FlipCursor180HotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Hide Block Cursor", Setting_Hotkeys_BlockCursorToggleHideHotKey, Setting_Hotkeys_BlockCursorToggleHideHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Block Helpers", Setting_Hotkeys_BlockHelpersToggleHotKey, Setting_Hotkeys_BlockHelpersToggleHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Apply Custom Item Ghost Mode", Setting_Hotkeys_CustomItemGhostHotKey, Setting_Hotkeys_CustomItemGhostHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Apply Custom Item AutoRotation", Setting_Hotkeys_CustomItemAutoRotationHotKey, Setting_Hotkeys_CustomItemAutoRotationHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Apply Custom Item Grid", Setting_Hotkeys_CustomItemGridHotKey, Setting_Hotkeys_CustomItemGridHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Apply Custom Item Pivot", Setting_Hotkeys_CustomItemPivotHotKey, Setting_Hotkeys_CustomItemPivotHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Quickswitch To Previous Block/Item/Macroblock", Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKey, Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Apply Custom Freeblock Grid", Setting_Hotkeys_FreeblockPlacementApplyGridHotKey, Setting_Hotkeys_FreeblockPlacementApplyGridHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Show Editor Placement Grid", Setting_Hotkeys_VisualPlacementGridOnHotKey, Setting_Hotkeys_VisualPlacementGridOnHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Editor Placement Grid Transparency", Setting_Hotkeys_VisualPlacementGridTransparentHotKey, Setting_Hotkeys_VisualPlacementGridTransparentHotKeyEnabled);
                activeHotkeysHelper += HotkeyDisplayActiveRow("Quicksave", Setting_Hotkeys_ActivateQuicksaveHotKey, Setting_Hotkeys_ActivateQuicksaveHotKeyEnabled);
                UI::Text(activeHotkeysHelper);
                UI::EndTooltip();
            }
        }

        void Update(float) override
        {
            Debug_EnterMethod("Update");

            if (!Enabled() || Editor is null)
            {
                Debug_LeaveMethod();
                return;
            }

            if (m_mapElemColorPrev != Compatibility::GetCurrentMapElemColor(Editor))
            {
                m_mapElemColorPrevPrev = m_mapElemColorPrev;
                m_mapElemColorPrev = Compatibility::GetCurrentMapElemColor(Editor);
                Debug("NEW COLOR! Prev color is: " + tostring(m_mapElemColorPrev) + " PrevPrev color is: " + tostring(m_mapElemColorPrevPrev));
            }

            Debug_LeaveMethod();
        }

        void OnKeyPress(bool down, VirtualKey key) override
        {
            Debug_EnterMethod("OnKeyPress");

            auto currKeyIndex = m_keysDown.Find(key);
            if (down && currKeyIndex < 0)
            {
                m_keysDown.InsertLast(key);
                Debug("Add \"" + tostring(key) + "\" to m_keysDown");
            }
            else if (!down && currKeyIndex >= 0)
            {
                m_keysDown.RemoveAt(currKeyIndex);
                Debug("Remove \"" + tostring(key) + "\" from m_keysDown");
            }

            if (!down && m_rebindKeyName != "")
            {
                Debug("Rebind " + tostring(m_rebindKeyName) + " to " + tostring(key));

                if (m_rebindKeyName == "AirBlockHotkey")
                {
                    Setting_Hotkeys_AirBlockHotKey = key;
                }
                else if (m_rebindKeyName == "ToggleColors")
                {
                    Setting_Hotkeys_ToggleColorsHotKey = key;
                }
                else if (m_rebindKeyName == "FlipCursor180")
                {
                    Setting_Hotkeys_FlipCursor180HotKey = key;
                }
                else if (m_rebindKeyName == "BlockCursorToggleHide")
                {
                    Setting_Hotkeys_BlockCursorToggleHideHotKey = key;
                }
                else if (m_rebindKeyName == "BlockHelpersToggle")
                {
                    Setting_Hotkeys_BlockHelpersToggleHotKey = key;
                }
                else if (m_rebindKeyName == "CustomItemGhost")
                {
                    Setting_Hotkeys_CustomItemGhostHotKey = key;
                }
                else if (m_rebindKeyName == "CustomItemAutoRotation")
                {
                    Setting_Hotkeys_CustomItemAutoRotationHotKey = key;
                }
                else if (m_rebindKeyName == "CustomItemGrid")
                {
                    Setting_Hotkeys_CustomItemGridHotKey = key;
                }
                else if (m_rebindKeyName == "CustomItemPivot")
                {
                    Setting_Hotkeys_CustomItemPivotHotKey = key;
                }
                else if (m_rebindKeyName == "CustomPaletteQuickswitchPrevious")
                {
                    Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKey = key;
                }
                else if (m_rebindKeyName == "FreeblockPlacementApplyGrid")
                {
                    Setting_Hotkeys_FreeblockPlacementApplyGridHotKey = key;
                }
                else if (m_rebindKeyName == "VisualPlacementGridOn")
                {
                    Setting_Hotkeys_VisualPlacementGridOnHotKey = key;
                }
                else if (m_rebindKeyName == "VisualPlacementGridTransparent")
                {
                    Setting_Hotkeys_VisualPlacementGridTransparentHotKey = key;
                }
                else if (m_rebindKeyName == "ActivateQuicksave")
                {
                    Setting_Hotkeys_ActivateQuicksaveHotKey = key;
                }

                m_rebindKeyName = "";
                Debug_LeaveMethod();
                return;
            }

            if (!Enabled() || Compatibility::EditorIsNull() || Compatibility::IsMapTesting())
            {
                Debug("!Enabled():" + tostring(!Enabled()) + " Compatibility::EditorIsNull():" + tostring(Compatibility::EditorIsNull()) + " Compatibility::IsMapTesting():" + tostring(Compatibility::IsMapTesting()));
                Debug_LeaveMethod();
                return;
            }
            if (!down && m_keysDown.IsEmpty() && Editor.PluginMapType !is null && Editor.PluginMapType.IsEditorReadyForRequest)
            {
                Debug("Passing keypress \"" + tostring(key) + "\" to hotkey processing methods");
                OnKeyPress_AirBlockModeHotkey(key);
                OnKeyPress_ToggleColorsHotkey(key);
                OnKeyPress_FlipCursor180(key);
                OnKeyPress_BlockCursorToggleHide(key);
                OnKeyPress_BlockHelpersToggle(key);
                OnKeyPress_CustomItemGhost(key);
                OnKeyPress_CustomItemAutoRotation(key);
                OnKeyPress_CustomItemGrid(key);
                OnKeyPress_CustomItemPivot(key);
                OnKeyPress_CustomPaletteQuickswitchPrevious(key);
                OnKeyPress_FreeblockPlacementApplyGrid(key);
                OnKeyPress_VisualPlacementGridOn(key);
                OnKeyPress_VisualPlacementGridTransparent(key);
                OnKeyPress_ActivateQuicksave(key);
            }

            Debug_LeaveMethod();
        }

        private void OnKeyPress_AirBlockModeHotkey(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_AirBlockModeHotkey");
            if (Setting_Hotkeys_AirBlockHotKeyEnabled && key == Setting_Hotkeys_AirBlockHotKey)
            {
                Debug("Activate AirBlockModeHotkey");
                ShowHotkeyNotification("Toggle Airblock Mode", key);
                Compatibility::ToggleAirBlockMode(Editor);
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_ToggleColorsHotkey(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_ToggleColorsHotkey");
            if (Setting_Hotkeys_ToggleColorsHotKeyEnabled && key == Setting_Hotkeys_ToggleColorsHotKey)
            {
                Debug("Activate ToggleColorsHotkey");
                ShowHotkeyNotification("Quickswitch Last Element Color", key);
                Compatibility::SetNextMapElemColor(Editor, m_mapElemColorPrevPrev);
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_FlipCursor180(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_FlipCursor180");
            if (Setting_Hotkeys_FlipCursor180HotKeyEnabled && key == Setting_Hotkeys_FlipCursor180HotKey
                && Compatibility::FreeblockModePreciseRotationShouldBeActive(Editor))
            {
                Debug("Activate FlipCursor180");
                ShowHotkeyNotification("Flip Block/Item 180 degrees", key);
                if (Editor.Cursor.Pitch < 0.0)
                {
                    Editor.Cursor.Pitch = 0.0;
                }
                else
                {
                    Editor.Cursor.Pitch = Math::ToRad(-180.0);
                }
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_BlockCursorToggleHide(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_BlockCursorToggleHide");
            if (Setting_Hotkeys_BlockCursorToggleHideHotKeyEnabled && key == Setting_Hotkeys_BlockCursorToggleHideHotKey)
            {
                Debug("Activate BlockCursorToggleHide");
                ShowHotkeyNotification("Toggle Hide Block Cursor", key);
                HotkeyInterface::ToggleHideBlockCursor();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_BlockHelpersToggle(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_BlockHelpersToggle");
            if (Setting_Hotkeys_BlockHelpersToggleHotKeyEnabled && key == Setting_Hotkeys_BlockHelpersToggleHotKey)
            {
                Debug("Activate BlockHelpersToggle");
                ShowHotkeyNotification("Toggle Block Helpers", key);
                HotkeyInterface::ToggleShowBlockHelpers();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_CustomItemGhost(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_CustomItemGhost");
            if (Setting_Hotkeys_CustomItemGhostHotKeyEnabled && key == Setting_Hotkeys_CustomItemGhostHotKey)
            {
                Debug("Activate CustomItemGhost");
                ShowHotkeyNotification("Toggle Apply Custom Item Ghost Mode", key);
                HotkeyInterface::ToggleCustomItemApplyGhost();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_CustomItemAutoRotation(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_CustomItemAutoRotation");
            if (Setting_Hotkeys_CustomItemAutoRotationHotKeyEnabled && key == Setting_Hotkeys_CustomItemAutoRotationHotKey)
            {
                Debug("Activate CustomItemAutoRotation");
                ShowHotkeyNotification("Toggle Apply Custom Item AutoRotation", key);
                HotkeyInterface::ToggleCustomItemApplyAutoRotation();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_CustomItemGrid(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_CustomItemGrid");
            if (Setting_Hotkeys_CustomItemGridHotKeyEnabled && key == Setting_Hotkeys_CustomItemGridHotKey)
            {
                Debug("Activate CustomItemGrid");
                ShowHotkeyNotification("Toggle Apply Custom Item Grid", key);
                HotkeyInterface::ToggleCustomItemApplyGrid();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_CustomItemPivot(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_CustomItemPivot");
            if (Setting_Hotkeys_CustomItemPivotHotKeyEnabled && key == Setting_Hotkeys_CustomItemPivotHotKey)
            {
                Debug("Activate CustomItemPivot");
                ShowHotkeyNotification("Toggle Apply Custom Item Pivot", key);
                HotkeyInterface::ToggleCustomItemApplyPivot();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_CustomPaletteQuickswitchPrevious(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_CustomPaletteQuickswitchPrevious");
            if (Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKeyEnabled && key == Setting_Hotkeys_CustomPaletteQuickswitchPreviousHotKey)
            {
                Debug("Activate CustomPaletteQuickswitchPrevious");
                ShowHotkeyNotification("Quickswitch To Previous Block/Item/Macroblock", key);
                HotkeyInterface::QuickswitchPreviousArticle();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_FreeblockPlacementApplyGrid(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_FreeblockPlacementApplyGrid");
            if (Setting_Hotkeys_FreeblockPlacementApplyGridHotKeyEnabled && key == Setting_Hotkeys_FreeblockPlacementApplyGridHotKey)
            {
                Debug("Activate FreeblockPlacementApplyGrid");
                ShowHotkeyNotification("Toggle Apply Custom Freeblock Grid", key);
                HotkeyInterface::ToggleFreeblockApplyCustomGrid();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_VisualPlacementGridOn(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_VisualPlacementGridOn");
            if (Setting_Hotkeys_VisualPlacementGridOnHotKeyEnabled && key == Setting_Hotkeys_VisualPlacementGridOnHotKey)
            {
                Debug("Activate VisualPlacementGridOn");
                ShowHotkeyNotification("Toggle Show Editor Placement Grid", key);
                HotkeyInterface::TogglePlacementGridOn();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_VisualPlacementGridTransparent(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_VisualPlacementGridTransparent");
            if (Setting_Hotkeys_VisualPlacementGridTransparentHotKeyEnabled && key == Setting_Hotkeys_VisualPlacementGridTransparentHotKey)
            {
                Debug("Activate VisualPlacementGridTransparent");
                ShowHotkeyNotification("Toggle Editor Placement Grid Transparency", key);
                HotkeyInterface::TogglePlacementGridTransparent();
            }
            Debug_LeaveMethod();
        }

        private void OnKeyPress_ActivateQuicksave(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_ActivateQuicksave");
            if (Setting_Hotkeys_ActivateQuicksaveHotKeyEnabled && key == Setting_Hotkeys_ActivateQuicksaveHotKey)
            {
                Debug("Activate ActivateQuicksave");
                ShowHotkeyNotification("Quicksave", key);
                HotkeyInterface::ActivateQuicksave();
            }
            Debug_LeaveMethod();
        }

        private void HotkeySettingsTableRow(const string&in title, const string&in rebindName, const VirtualKey&in currentKey, bool&in enabledIn, bool&out enabledOut)
        {
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(title);
            UI::TableNextColumn();
            UI::Text(tostring(currentKey));
            UI::TableNextColumn();
            enabledOut = UI::Checkbox("Enabled##" + rebindName, enabledIn);
            UI::TableNextColumn();
            if (m_rebindKeyName == rebindName)
            {
                if (UI::Button("Cancel##" + rebindName))
                {
                    m_rebindKeyName = "";
                }
            }
            else if (UI::Button("Rebind##" + rebindName))
            {
                m_rebindKeyName = rebindName;
            }
        }

        private string HotkeyDisplayActiveRow(const string&in title, const VirtualKey&in key, const bool&in enabled)
        {
            string text = "";
            if (enabled)
            {
                text = "[ " + tostring(key) + " ]\t" + title + "\n";
            }
            return text;
        }

        private void ShowHotkeyNotification(const string&in name, const VirtualKey&in key)
        {
            if (Setting_Hotkeys_ShowActivationNotification)
            {
                UI::ShowNotification(
                    "Editor Helpers: " + Name(),
                    "Hotkey pressed: [ " + tostring(key) + " ] " + name,
                    750
                );
            }
        }
    }
}
