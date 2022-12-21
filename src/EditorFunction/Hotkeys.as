
namespace EditorHelpers
{
    namespace Compatibility
    {
        void OnKeyPress_AirBlockModeHotkey(CGameCtnEditorFree@ Editor, VirtualKey key)
        {
#if TMNEXT
            if (Setting_Hotkeys_AirBlockHotKeyEnabled && key == Setting_Hotkeys_AirBlockHotKey
                && (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block
                    || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::GhostBlock
                    || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::FreeBlock))
            {
                Editor.ButtonAirBlockModeOnClick();
            }
#endif
        }

        void OnKeyPress_ToggleColorsHotkey(CGameCtnEditorFree@ Editor, VirtualKey key, int previousColor)
        {
#if TMNEXT
            if (Setting_Hotkeys_ToggleColorsHotKeyEnabled && key == Setting_Hotkeys_ToggleColorsHotKey)
            {
                Editor.PluginMapType.NextMapElemColor = CGameEditorPluginMap::EMapElemColor(previousColor);
            }
#endif
        }

        void OnKeyPress_FlipCursor180(CGameCtnEditorFree@ Editor, VirtualKey key)
        {
            if (Setting_Hotkeys_FlipCursor180HotKeyEnabled
                && Setting_Hotkeys_FlipCursor180HotKey == key
                && Compatibility::FreeblockModePreciseRotationShouldBeActive(Editor))
            {
                if (Editor.Cursor.Pitch < 0.0)
                {
                    Editor.Cursor.Pitch = 0.0;
                }
                else
                {
                    Editor.Cursor.Pitch = Math::ToRad(-180.0);
                }
            }
        }

        void OnKeyPress_CustomItemGrid(CGameCtnEditorFree@ Editor, VirtualKey key)
        {
            if (Setting_Hotkeys_CustomItemGridHotKeyEnabled
                && Setting_Hotkeys_CustomItemGridHotKey == key)
            {
                Interface::ToggleCustomItemApplyGrid();
            }
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

    [Setting category="Functions" name="Hotkeys: CustomItemGrid HotKey Enabled" hidden]
    bool Setting_Hotkeys_CustomItemGridHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: CustomItemGrid HotKey" hidden]
    VirtualKey Setting_Hotkeys_CustomItemGridHotKey = VirtualKey::I;

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
            UI::TextWrapped("Adds some custom hotkeys to the editor to manage things that are not already hotkeys the game.");
            if (UI::BeginTable("SettingsHotkeysTable", 4 /*columns*/))
            {
                UI::TableSetupColumn("Action");
                UI::TableSetupColumn("Key");
                UI::TableSetupColumn("Enabled");
                UI::TableSetupColumn("");
                UI::TableHeadersRow();

                HotkeySettingsTableRow("Toggle AirBlock Mode", "AirBlockHotkey", Setting_Hotkeys_AirBlockHotKey, Setting_Hotkeys_AirBlockHotKeyEnabled, Setting_Hotkeys_AirBlockHotKeyEnabled);
                HotkeySettingsTableRow("Quickswitch To Last Color", "ToggleColors", Setting_Hotkeys_ToggleColorsHotKey, Setting_Hotkeys_ToggleColorsHotKeyEnabled, Setting_Hotkeys_ToggleColorsHotKeyEnabled);
                HotkeySettingsTableRow("Flip Block 180 deg", "FlipCursor180", Setting_Hotkeys_FlipCursor180HotKey, Setting_Hotkeys_FlipCursor180HotKeyEnabled, Setting_Hotkeys_FlipCursor180HotKeyEnabled);
                HotkeySettingsTableRow("Toggle Apply Custom Item Grid", "CustomItemGrid", Setting_Hotkeys_CustomItemGridHotKey, Setting_Hotkeys_CustomItemGridHotKeyEnabled, Setting_Hotkeys_CustomItemGridHotKeyEnabled);

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
                activeHotkeysHelper += HotkeyDisplayActiveRow("Toggle Apply Custom Item Grid", Setting_Hotkeys_CustomItemGridHotKey, Setting_Hotkeys_CustomItemGridHotKeyEnabled);
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
                else if (m_rebindKeyName == "CustomItemGrid")
                {
                    Setting_Hotkeys_CustomItemGridHotKey = key;
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
                Compatibility::OnKeyPress_AirBlockModeHotkey(Editor, key);
                Compatibility::OnKeyPress_ToggleColorsHotkey(Editor, key, m_mapElemColorPrevPrev);
                Compatibility::OnKeyPress_FlipCursor180(Editor, key);
                Compatibility::OnKeyPress_CustomItemGrid(Editor, key);
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
