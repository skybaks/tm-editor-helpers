
namespace EditorHelpers
{
    [Setting category="Functions" name="BlockCursor: Enabled" description="Uncheck to disable all plugin functions relating to Block Cursor"]
    bool Setting_BlockCursor_Enabled = true;
    [Setting category="Functions" name="BlockCursor: Hide Block Cursor"]
    bool Setting_BlockCursor_HideBlockCursor = false;
    class BlockCursor : EditorHelpers::EditorFunction
    {
        private bool lastBlockCursorOff;

        bool Enabled() override { return Setting_BlockCursor_Enabled; }

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
