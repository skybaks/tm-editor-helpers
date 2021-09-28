
namespace EditorHelpers
{
    [Setting category="AirBlockModeHotkey" name="Enabled"]
    bool Setting_AirBlockModeHotkey_Enabled = true;
    [Setting category="AirBlockModeHotkey" name="AirBlockHotKeyEnabled"]
    bool Setting_AirBlockModeHotkey_AirBlockHotKeyEnabled = true;
    [Setting category="AirBlockModeHotkey" name="AirBlockHotKey"]
    VirtualKey Setting_AirBlockModeHotkey_AirBlockHotKey = VirtualKey::A;

    class AirBlockModeHotkey : EditorHelpers::EditorFunction
    {
        bool m_keyDownCtrl = false;

        bool Enabled() override { return Setting_AirBlockModeHotkey_Enabled; }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                m_keyDownCtrl = false;
            }
        }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            if (UI::CollapsingHeader("AirBlockMode Hotkey"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Hotkey for airblock mode toggle");
                    UI::SameLine();
                }
                Setting_AirBlockModeHotkey_AirBlockHotKeyEnabled = UI::Checkbox("Enable AirBlockMode Hotkey", Setting_AirBlockModeHotkey_AirBlockHotKeyEnabled);
            }
        }

        bool OnKeyPress(bool down, VirtualKey key) override
        {
            if (key == VirtualKey::LControl || key == VirtualKey::RControl)
            {
                m_keyDownCtrl = down;
            }

            bool handled = false;
            if (!Enabled()) return handled;
            if (Setting_AirBlockModeHotkey_AirBlockHotKeyEnabled
                && key == Setting_AirBlockModeHotkey_AirBlockHotKey
                && !down
                && !m_keyDownCtrl)
            {
                Editor.ButtonAirBlockModeOnClick();
                handled = true;
            }
            return handled;
        }
    }
}
