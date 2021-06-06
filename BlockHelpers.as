
namespace EditorHelpers
{
    namespace Setting
    {
        [Setting category="BlockHelpers" name="Enabled"]
        bool BlockHelpers = true;
        [Setting category="BlockHelpers" name="Block Helpers Off"]
        bool BlockHelpersBlockHelpersOff = false;
    }

    class BlockHelpers : EditorFunction
    {
        private bool lastBlockHelpersOff;

        bool Enabled() override { return Setting::BlockHelpers; }

        void Init() override 
        {
            if (!Enabled() || Editor is null)
            {
                lastBlockHelpersOff = false;
            }
        }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            if (UI::CollapsingHeader("Block Helpers"))
            {
                if (Setting::ToolTipsEnabled)
                {
                    HelpMarker("Hide/Show block clip helpers");
                    UI::SameLine();
                }
                Setting::BlockHelpersBlockHelpersOff = UI::Checkbox("Block Helpers Off", Setting::BlockHelpersBlockHelpersOff);
            }
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Setting::BlockHelpersBlockHelpersOff)
            {
                Editor.HideBlockHelpers = true;
            }
            else if (lastBlockHelpersOff && !Setting::BlockHelpersBlockHelpersOff)
            {
                Editor.HideBlockHelpers = false;
            }
            lastBlockHelpersOff = Setting::BlockHelpersBlockHelpersOff;
        }
    }
}