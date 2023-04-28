
namespace EditorHelpers
{
    [Setting category="Functions" name="Links: Enabled" hidden]
    bool Setting_Links_Enabled = true;

    class Links : EditorHelpers::EditorFunction
    {
        string Name() override { return "Links"; }
        bool Enabled() override { return Setting_Links_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_Links_Enabled = UI::Checkbox("Enabled", Setting_Links_Enabled);
            UI::BeginDisabled(!Setting_Links_Enabled);
            UI::TextWrapped("Displays some links in the Info section of the Editor Helpers window.");
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("Links::Display");
            }

            UI::PopID();
        }

        void RenderInterface_Info() override
        {
            if (!Enabled()) { return; }

            EditorHelpers::BeginHighlight("Links::Display");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Open the Editor Helpers Github Wiki");
                UI::SameLine();
            }
            if (UI::Button("Github Wiki " + Icons::ExternalLink))
            {
                OpenBrowserURL("https://github.com/skybaks/tm-editor-helpers/wiki");
            }
            EditorHelpers::EndHighlight();
        }
    }
}