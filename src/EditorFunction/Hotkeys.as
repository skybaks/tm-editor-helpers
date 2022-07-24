
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

    [Setting category="Functions" name="Hotkeys: Hotkeys Function Enabled" description="Uncheck to disable all hotkey plugin code"]
    bool Setting_Hotkeys_Enabled = true;

    [Setting category="Functions" name="Hotkeys: AirBlock HotKey Enabled"]
    bool Setting_Hotkeys_AirBlockHotKeyEnabled = true;
    [Setting category="Functions" name="Hotkeys: AirBlock HotKey"]
    VirtualKey Setting_Hotkeys_AirBlockHotKey = VirtualKey::A;

    [Setting category="Functions" name="Hotkeys: ToggleColors HotKey Enabled"]
    bool Setting_Hotkeys_ToggleColorsHotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: ToggleColors HotKey"]
    VirtualKey Setting_Hotkeys_ToggleColorsHotKey = VirtualKey::F6;

    [Setting category="Functions" name="Hotkeys: FlipCursor180 HotKey Enabled"]
    bool Setting_Hotkeys_FlipCursor180HotKeyEnabled = false;
    [Setting category="Functions" name="Hotkeys: FlipCursor180 HotKey"]
    VirtualKey Setting_Hotkeys_FlipCursor180HotKey = VirtualKey::OemPeriod;

    class Hotkeys : EditorHelpers::EditorFunction
    {
        VirtualKey[] m_keysDown = {};
        int m_mapElemColorPrev = 0;
        int m_mapElemColorPrevPrev = 0;

        bool Enabled() override { return Compatibility::EnableHotkeysFunction(); }

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
                if (Setting_Hotkeys_AirBlockHotKeyEnabled)
                {
                    activeHotkeysHelper += "[ " + tostring(Setting_Hotkeys_AirBlockHotKey) + " ]\tToggle Airblock Mode\n";
                }
                if (Setting_Hotkeys_ToggleColorsHotKeyEnabled)
                {
                    activeHotkeysHelper += "[ " + tostring(Setting_Hotkeys_ToggleColorsHotKey) + " ]\tQuickswitch Last Element Color\n";
                }
                if (Setting_Hotkeys_FlipCursor180HotKeyEnabled)
                {
                    activeHotkeysHelper += "[ " + tostring(Setting_Hotkeys_FlipCursor180HotKey) + " ]\tFlip Block/Item 180 degrees\n";
                }
                UI::Text(activeHotkeysHelper);
                UI::EndTooltip();
            }
        }

        void Update(float)
        {
            if (!Enabled() || Editor is null) return;

            if (m_mapElemColorPrev != Compatibility::GetCurrentMapElemColor(Editor))
            {
                m_mapElemColorPrevPrev = m_mapElemColorPrev;
                m_mapElemColorPrev = Compatibility::GetCurrentMapElemColor(Editor);
            }
        }

        void OnKeyPress(bool down, VirtualKey key) override
        {
            auto currKeyIndex = m_keysDown.Find(key);
            if (down && currKeyIndex < 0)
            {
                m_keysDown.InsertLast(key);
            }
            else if (!down && currKeyIndex >= 0)
            {
                m_keysDown.RemoveAt(currKeyIndex);
            }

            if (!Enabled()) return;
            if (!down && m_keysDown.IsEmpty() && Editor.PluginMapType !is null && Editor.PluginMapType.IsEditorReadyForRequest)
            {
                Compatibility::OnKeyPress_AirBlockModeHotkey(Editor, key);
                Compatibility::OnKeyPress_ToggleColorsHotkey(Editor, key, m_mapElemColorPrevPrev);
                Compatibility::OnKeyPress_FlipCursor180(Editor, key);
            }
        }
    }
}
