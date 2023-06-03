
namespace EditorHelpers
{
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

    class BlockHelpers : EditorHelpers::EditorFunction
    {
        private bool lastBlockHelpersOff;
        private bool m_functionalityDisabled;

        string Name() override { return "Block Helpers"; }
        bool Enabled() override { return Setting_BlockHelpers_Enabled; }
        bool SupportsPresets() override { return true; }

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

        void SerializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            json["helpers_off"] = Setting_BlockHelpers_BlockHelpersOff;
        }

        void DeserializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_helpers_off", Json::Value(true))))
            {
                Setting_BlockHelpers_BlockHelpersOff = bool(json.Get("helpers_off", Json::Value(false)));
            }
        }

        void RenderPresetValues(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_helpers_off", Json::Value(true))))
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Block Helpers Off");
                UI::TableNextColumn();
                UI::Text(tostring(bool(json.Get("helpers_off", Json::Value(false)))));
            }
        }

        bool RenderPresetEnables(Json::Value@ json, bool defaultValue, bool forceValue) override
        {
            bool changed = false;
            if (!Enabled()) { return changed; }
            if (JsonCheckboxChanged(json, "enable_helpers_off", "Helpers Off", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("BlockHelpers::HelpersOff");
            }
            return changed;
        }
    }
}