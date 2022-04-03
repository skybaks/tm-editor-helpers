
namespace EditorHelpers
{
    namespace Compatibility
    {
        void SetHideBlockHelpers(CGameCtnEditorFree@ editor, bool setValue)
        {
#if TMNEXT
            editor.HideBlockHelpers = setValue;
#elif MP4
            editor.PluginMapType.HideBlockHelpers = setValue;
#endif
        }
    }

    [Setting category="Functions" name="BlockHelpers: Enabled" description="Uncheck to disable all plugin functions related to block helpers"]
    bool Setting_BlockHelpers_Enabled = true;
    [Setting category="Functions" name="BlockHelpers: Block Helpers Off"]
    bool Setting_BlockHelpers_BlockHelpersOff = false;
    class BlockHelpers : EditorHelpers::EditorFunction
    {
        private bool lastBlockHelpersOff;

        bool Enabled() override { return Setting_BlockHelpers_Enabled; }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                lastBlockHelpersOff = false;
            }
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Hide/Show block clip helpers");
                UI::SameLine();
            }
            Setting_BlockHelpers_BlockHelpersOff = UI::Checkbox("Block Helpers Off", Setting_BlockHelpers_BlockHelpersOff);
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Setting_BlockHelpers_BlockHelpersOff)
            {
                Compatibility::SetHideBlockHelpers(Editor, true);
            }
            else if (lastBlockHelpersOff && !Setting_BlockHelpers_BlockHelpersOff)
            {
                Compatibility::SetHideBlockHelpers(Editor, false);
            }
            lastBlockHelpersOff = Setting_BlockHelpers_BlockHelpersOff;
        }
    }
}