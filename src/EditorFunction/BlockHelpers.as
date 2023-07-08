
namespace EditorHelpers
{
    class BlockHelpersPreset : EditorFunctionPresetBase
    {
        bool EnableHelpersOff = true;
        bool HelpersOff = false;

        BlockHelpersPreset()
        {
            super("Block Helpers");
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_helpers_off"] = EnableHelpersOff;
            m_json["helpers_off"] = HelpersOff;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableHelpersOff = json.Get("enable_helpers_off", Json::Value(true));
            HelpersOff = json.Get("helpers_off", Json::Value(false));
        }
    }

    namespace Compatibility
    {
        void SetHideBlockHelpers(CGameCtnEditorFree@ editor, bool setValue)
        {
#if TMNEXT
            editor.HideBlockHelpers = setValue;
#elif MP4
            if (editor !is null && editor.PluginMapType !is null)
            {
                editor.PluginMapType.HideBlockHelpers = setValue;
            }
#endif
        }
    }

    namespace HotkeyInterface
    {
        bool Enabled_BlockHelpers()
        {
            return Setting_BlockHelpers_Enabled;
        }

        void ToggleShowBlockHelpers()
        {
            if (Setting_BlockHelpers_Enabled)
            {
                Setting_BlockHelpers_BlockHelpersOff = !Setting_BlockHelpers_BlockHelpersOff;
            }
        }
    }

    [Setting category="Functions" name="BlockHelpers: Enabled" hidden]
    bool Setting_BlockHelpers_Enabled = true;
    [Setting category="Functions" name="BlockHelpers: Block Helpers Off" hidden]
    bool Setting_BlockHelpers_BlockHelpersOff = false;

    class BlockHelpers : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
    {
        private bool lastBlockHelpersOff;
        private bool m_functionalityDisabled;

        string Name() override { return "Block Helpers"; }
        bool Enabled() override { return Setting_BlockHelpers_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_BlockHelpers_Enabled = UI::Checkbox("Enabled", Setting_BlockHelpers_Enabled);
            UI::BeginDisabled(!Setting_BlockHelpers_Enabled);
            UI::TextWrapped("Enables hiding/showing the clip helpers on placed blocks in the editor.");
            Setting_BlockHelpers_BlockHelpersOff = UI::Checkbox("Block Helpers Off", Setting_BlockHelpers_BlockHelpersOff);
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("BlockHelpers::HelpersOff");
            }

            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                lastBlockHelpersOff = false;
            }
        }

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            UI::BeginDisabled(m_functionalityDisabled);
            EditorHelpers::BeginHighlight("BlockHelpers::HelpersOff");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Hide/Show block clip helpers");
                UI::SameLine();
            }
            Setting_BlockHelpers_BlockHelpersOff = UI::Checkbox("Block Helpers Off", Setting_BlockHelpers_BlockHelpersOff);
            EditorHelpers::EndHighlight();
            UI::EndDisabled();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null || Editor.PluginMapType is null)
            {
                m_functionalityDisabled = true;
                return;
            }
            else
            {
                m_functionalityDisabled = false;
            }

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

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return BlockHelpersPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            BlockHelpersPreset@ preset = cast<BlockHelpersPreset>(data);
            if (preset is null) { return; }
            preset.HelpersOff = Setting_BlockHelpers_BlockHelpersOff;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            BlockHelpersPreset@ preset = cast<BlockHelpersPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableHelpersOff)
            {
                Setting_BlockHelpers_BlockHelpersOff = preset.HelpersOff;
            }
        }

        bool CheckPreset(EditorFunctionPresetBase@ data) override
        {
            bool areSame = true;
            if (!Enabled()) { return areSame; }
            BlockHelpersPreset@ preset = cast<BlockHelpersPreset>(data);
            if (preset is null) { return areSame; }
            if (preset.EnableHelpersOff)
            {
                if (Setting_BlockHelpers_BlockHelpersOff != preset.HelpersOff) { areSame = false; }
            }
            return areSame;
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            BlockHelpersPreset@ preset = cast<BlockHelpersPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableHelpersOff)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Block Helpers Off");
                UI::TableNextColumn();
                UI::Text(tostring(preset.HelpersOff));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            BlockHelpersPreset@ preset = cast<BlockHelpersPreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableHelpersOff, preset.EnableHelpersOff, "Helpers Off", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("BlockHelpers::HelpersOff");
            }
            return changed;
        }
    }
}