namespace EditorHelpers
{
    [Setting category="Functions" name="Mood Changer: Enabled" description="Uncheck to disable plugin function for mood changer"]
    bool Setting_MoodChanger_Enabled = true;

    class MoodChanger : EditorHelpers::EditorFunction
    {
        string UserTimeSet = Editor.MoodTimeOfDayStr;

        bool TimeMatchesRegex(const string &in time)
        {
            string regex = "^(0[0-9]|1[0-9]|2[0-4]):([0-5][0-9]):([0-5][0-9])$";
            return Regex::IsMatch(time, regex);
        }

        bool Enabled() override { return Setting_MoodChanger_Enabled; }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the mood to a specific time of the day");
                UI::SameLine();
            }
            UI::SetNextItemWidth(UI::GetWindowSize().x * 0.4f);
            UserTimeSet = UI::InputText("Map Time", Editor.MoodTimeOfDayStr);
            if (TimeMatchesRegex(UserTimeSet))
                Editor.MoodTimeOfDayStr = UserTimeSet;
            else {
                UI::SameLine();
                UI::Text("\\$f00"+Icons::Times);
            }

            Editor.MoodTimeOfDay01 = UI::SliderFloat("Map time", Editor.MoodTimeOfDay01, 0.0f, 1.0f);
        }
    }
}