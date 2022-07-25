namespace EditorHelpers
{
    [Setting category="Functions" name="Mood Changer: Enabled" hidden]
    bool Setting_MoodChanger_Enabled = true;

    class MoodChanger : EditorHelpers::EditorFunction
    {
        string SetTime;
        bool SettingChanged;
        bool EntreingEditor;

        bool TimeMatchesRegex(const string &in time)
        {
            string regex = "^(0[0-9]|1[0-9]|2[0-4]):([0-5][0-9]):([0-5][0-9])$";
            return Regex::IsMatch(time, regex);
        }

        string Name() override { return "Mood Changer"; }
        bool Enabled() override { return Setting_MoodChanger_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_MoodChanger_Enabled = UI::Checkbox("Enabled", Setting_MoodChanger_Enabled);
            UI::BeginDisabled(!Setting_MoodChanger_Enabled);
            UI::TextWrapped("This provides an interface to modify the game time of a map down to the second for a 24 hour period.");
            UI::EndDisabled();
            UI::PopID();
        }

        void Update(float dt) override
        {
            if (Editor !is null && SettingChanged) {
                SettingChanged = false;
                Editor.MoodTimeOfDayStr = SetTime;
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled()) return;

            UI::TextDisabled("\tMood");

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the mood to a specific time of the day");
                UI::SameLine();
            }
            if (Editor !is null) UI::Text("Actual map time: " + Editor.MoodTimeOfDayStr);
            UI::Text("Set map time:");
            UI::SameLine();
            UI::SetNextItemWidth(UI::GetWindowSize().x * 0.4f);
            SetTime = UI::InputText("###Map Time", SetTime);
            UI::SameLine();
            if (TimeMatchesRegex(SetTime)) {
                if (UI::Button("Set time")) {
                    SettingChanged = true;
                }
            }
            else {
                UI::Text("\\$f00"+Icons::Times);
                UI::SameLine();
                EditorHelpers::HelpMarker("Time format is invalid.\nFormat should be HH:MM:SS");
            }
        }
    }
}