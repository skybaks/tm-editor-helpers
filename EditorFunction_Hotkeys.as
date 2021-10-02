
namespace EditorHelpers
{
    [Setting category="Hotkeys" name="Enabled"]
    bool Setting_Hotkeys_Enabled = true;

    [Setting category="Hotkeys" name="AirBlockHotKeyEnabled"]
    bool Setting_Hotkeys_AirBlockHotKeyEnabled = true;
    [Setting category="Hotkeys" name="AirBlockHotKey"]
    VirtualKey Setting_Hotkeys_AirBlockHotKey = VirtualKey::A;

    class Hotkeys : EditorHelpers::EditorFunction
    {
        VirtualKey[] m_keysDown = {};

        bool Enabled() override { return Setting_Hotkeys_Enabled; }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                m_keysDown.RemoveRange(0, m_keysDown.Length - 1);
            }
        }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            if (UI::CollapsingHeader("Hotkeys"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Hotkey for airblock mode toggle");
                    UI::SameLine();
                }
                Setting_Hotkeys_AirBlockHotKeyEnabled = UI::Checkbox("Enable AirBlockMode Hotkey", Setting_Hotkeys_AirBlockHotKeyEnabled);
            }
        }

        bool OnKeyPress(bool down, VirtualKey key) override
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

            bool handled = false;
            if (!Enabled()) return handled;
            if (!down && m_keysDown.IsEmpty())
            {
                if (Setting_Hotkeys_AirBlockHotKeyEnabled && key == Setting_Hotkeys_AirBlockHotKey)
                {
                    Editor.ButtonAirBlockModeOnClick();
                    handled = true;
                }
            }
            return handled;
        }
    }
}
