
namespace EditorHelpers
{
    namespace HotkeyInterface
    {
        bool Enabled_BlockCursor()
        {
            return Setting_BlockCursor_Enabled;
        }

        void ToggleHideBlockCursor()
        {
            if (Setting_BlockCursor_Enabled)
            {
                Setting_BlockCursor_HideBlockCursor = !Setting_BlockCursor_HideBlockCursor;
            }
        }
    }

    [Setting category="Functions" name="BlockCursor: Enabled" hidden]
    bool Setting_BlockCursor_Enabled = true;
    [Setting category="Functions" name="BlockCursor: Hide Block Cursor" hidden]
    bool Setting_BlockCursor_HideBlockCursor = false;

    class BlockCursor : EditorHelpers::EditorFunction
    {
        private bool lastBlockCursorOff;

        string Name() override { return "Block Cursor"; }
        bool Enabled() override { return Setting_BlockCursor_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_BlockCursor_Enabled = UI::Checkbox("Enabled", Setting_BlockCursor_Enabled);
            UI::BeginDisabled(!Setting_BlockCursor_Enabled);
            UI::TextWrapped("Enables hiding/showing the colored box that surrounds the current block or item in your cursor.");
            Setting_BlockCursor_HideBlockCursor = UI::Checkbox("Block Cursor Hidden", Setting_BlockCursor_HideBlockCursor);
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                lastBlockCursorOff = false;
            }
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Hide/Show block cursor box");
                UI::SameLine();
            }
            Setting_BlockCursor_HideBlockCursor = UI::Checkbox("Block Cursor Hidden", Setting_BlockCursor_HideBlockCursor);
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Setting_BlockCursor_HideBlockCursor)
            {
                Editor.Cursor.CursorBox.IsShowQuads = false;
                Editor.Cursor.CursorBox.IsShowLines = false;
            }
            else if (lastBlockCursorOff && !Setting_BlockCursor_HideBlockCursor)
            {
                Editor.Cursor.CursorBox.IsShowQuads = true;
                Editor.Cursor.CursorBox.IsShowLines = true;
            }
            lastBlockCursorOff = Setting_BlockCursor_HideBlockCursor;
        }
    }
}
