namespace EditorHelpers
{
    [Setting category="Functions" name="Mood Changer: Enabled" description="Uncheck to disable plugin function for mood changer"]
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

        bool Enabled() override { return Setting_MoodChanger_Enabled; }

        void Update(float dt) override
        {
            if (Editor !is null && SettingChanged) {
                SettingChanged = false;
                Editor.MoodTimeOfDayStr = SetTime;
            }
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

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