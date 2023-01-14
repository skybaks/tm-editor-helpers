namespace EditorHelpers
{
    class MoodChangerPreset
    {
        MoodChangerPreset(const string&in name, const string&in time)
        {
            Name = name;
            Time = time;
        }

        string Name;
        string Time;
    }

    MoodChangerPreset@[] g_moodChangerPresets = {
        MoodChangerPreset("Sunrise - Before First Light", "06:03:59"),
        MoodChangerPreset("Sunrise - First Light", "06:04:00"),
        MoodChangerPreset("Sunrise - No Moon", "06:30:00"),
        MoodChangerPreset("Sunrise - Default", "07:37:12"),

        MoodChangerPreset("Day - Default", "12:06:00"),

        MoodChangerPreset("Sunset - Faint Moon", "17:50:00"),
        MoodChangerPreset("Sunset - Moon", "18:20:00"),
        MoodChangerPreset("Sunset - Default", "19:22:48"),
        MoodChangerPreset("Sunset - Last Light", "20:57:17"),
        MoodChangerPreset("Sunset - After Last Light", "20:57:18"),

        MoodChangerPreset("Night - Midnight", "00:00:00"),
        MoodChangerPreset("Night - Default", "02:24:01")
    };

    [Setting category="Functions" name="Mood Changer: Enabled" hidden]
    bool Setting_MoodChanger_Enabled = true;

    class MoodChanger : EditorHelpers::EditorFunction
    {
        private string m_setTime;
        private bool m_settingChanged;
        private int m_selectedPresetIndex;

        private bool TimeMatchesRegex(const string &in time)
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
            if (!Enabled() || Editor is null) return;

            if (m_settingChanged)
            {
                m_settingChanged = false;
                Editor.MoodTimeOfDayStr = m_setTime;
            }

            m_selectedPresetIndex = -1;
            for (uint i = 0; i < g_moodChangerPresets.Length; ++i)
            {
                if (g_moodChangerPresets[i].Time == Editor.MoodTimeOfDayStr)
                {
                    m_selectedPresetIndex = int(i);
                    break;
                }
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled() || Editor is null) return;

            UI::TextDisabled("\tMood");

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the mood to a specific time of the day");
                UI::SameLine();
            }
            UI::Text("Current map time: " + Editor.MoodTimeOfDayStr);

            if (UI::BeginCombo("Mood Presets",
                m_selectedPresetIndex >= 0 && m_selectedPresetIndex < int(g_moodChangerPresets.Length)
                    ? g_moodChangerPresets[m_selectedPresetIndex].Name
                    : ""))
            {
                for (uint i = 0; i < g_moodChangerPresets.Length; ++i)
                {
                    if (UI::Selectable(g_moodChangerPresets[i].Name, m_selectedPresetIndex == int(i)))
                    {
                        m_setTime = g_moodChangerPresets[i].Time;
                        m_settingChanged = true;
                    }
                }
                UI::EndCombo();
            }

            UI::Text("Set map time:");
            UI::SameLine();
            UI::SetNextItemWidth(UI::GetWindowSize().x * 0.4f);
            m_setTime = UI::InputText("###Map Time", m_setTime);
            UI::SameLine();
            if (TimeMatchesRegex(m_setTime))
            {
                if (UI::Button("Set time"))
                {
                    m_settingChanged = true;
                }
            }
            else
            {
                UI::Text("\\$f00"+Icons::Times);
                UI::SameLine();
                EditorHelpers::HelpMarker("Time format is invalid.\nFormat should be HH:MM:SS");
            }
        }
    }
}