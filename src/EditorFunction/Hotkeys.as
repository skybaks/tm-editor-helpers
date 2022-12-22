
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
            }

            Debug_LeaveMethod();
        }

        private void OnKeyPress_AirBlockModeHotkey(const VirtualKey&in key)
        {
            Debug_EnterMethod("OnKeyPress_AirBlockModeHotkey");
            if (Setting_Hotkeys_AirBlockHotKeyEnabled && key == Setting_Hotkeys_AirBlockHotKey)
            {
                Debug("Activate AirBlockModeHotkey");
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
                HotkeyInterface::ToggleCustomItemApplyPivot();
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
    }
}
