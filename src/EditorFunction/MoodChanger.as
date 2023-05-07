namespace EditorHelpers
{
    namespace Compatibility
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

#if TMNEXT
        MoodChangerPreset@[] g_moodChangerPresetsStadiumNext = {
            MoodChangerPreset("Sunrise - Before First Light", "06:03:59"),
            MoodChangerPreset("Sunrise - First Light", "06:04:00"),
            MoodChangerPreset("Sunrise - Last Spotlights On", "06:30:00"),
            MoodChangerPreset("Sunrise - First Spotlights Off", "06:30:01"),
            MoodChangerPreset("Sunrise - Default", "07:37:12"),

            MoodChangerPreset("Day - Default", "12:06:00"),

            MoodChangerPreset("Sunset - Faint Moon", "17:50:00"),
            MoodChangerPreset("Sunset - Moon", "18:20:00"),
            MoodChangerPreset("Sunset - Last Spotlights Off", "18:30:00"),
            MoodChangerPreset("Sunset - First Spotlights On", "18:30:01"),
            MoodChangerPreset("Sunset - Default", "19:22:48"),
            MoodChangerPreset("Sunset - Last Light", "20:57:17"),
            MoodChangerPreset("Sunset - After Last Light", "20:57:18"),

            MoodChangerPreset("Night - Midnight", "00:00:00"),
            MoodChangerPreset("Night - Default", "02:24:01")
        };
#elif MP4
        MoodChangerPreset@[] g_moodChangerPresetsCanyon = {
            MoodChangerPreset("Sunrise - Last Lights On", "06:30:00"),
            MoodChangerPreset("Sunrise - First Lights Off", "06:30:01"),
            MoodChangerPreset("Sunrise - Default", "07:20:24"),

            MoodChangerPreset("Day - Midday", "12:00:00"),
            MoodChangerPreset("Day - Default", "14:33:50"),

            MoodChangerPreset("Sunset - Last Lights Off", "18:30:00"),
            MoodChangerPreset("Sunset - First Lights On", "18:30:01"),
            MoodChangerPreset("Sunset - Default", "20:30:00"),

            MoodChangerPreset("Night - Midnight", "00:00:00"),
            MoodChangerPreset("Night - Default", "02:24:01")
        };

        MoodChangerPreset@[] g_moodChangerPresetsLagoon = {
            MoodChangerPreset("Sunrise - Last Lights On", "06:30:00"),
            MoodChangerPreset("Sunrise - First Lights Off", "06:30:01"),
            MoodChangerPreset("Sunrise - Default", "07:30:29"),

            MoodChangerPreset("Day - Midday", "12:00:00"),
            MoodChangerPreset("Day - Default", "15:10:49"),

            MoodChangerPreset("Sunset - Default", "18:15:36"),
            MoodChangerPreset("Sunset - Last Lights Off", "18:30:00"),
            MoodChangerPreset("Sunset - First Lights On", "18:30:01"),

            MoodChangerPreset("Night - Midnight", "00:00:00"),
            MoodChangerPreset("Night - Default", "02:24:01")
        };

        MoodChangerPreset@[] g_moodChangerPresetsValley = {
            MoodChangerPreset("Sunrise - Last Lights On", "06:30:00"),
            MoodChangerPreset("Sunrise - First Lights Off", "06:30:01"),
            MoodChangerPreset("Sunrise - Default", "07:10:19"),

            MoodChangerPreset("Day - Midday", "12:00:00"),
            MoodChangerPreset("Day - Default", "14:33:50"),

            MoodChangerPreset("Sunset - Last Lights Off", "19:09:59"),
            MoodChangerPreset("Sunset - First Lights On", "19:10:00"),
            MoodChangerPreset("Sunset - Default", "19:22:48"),

            MoodChangerPreset("Night - Midnight", "00:00:00"),
            MoodChangerPreset("Night - Default", "02:24:01")
        };

        MoodChangerPreset@[] g_moodChangerPresetsStadium2 = {
            MoodChangerPreset("Sunrise - Last Lights On", "06:30:00"),
            MoodChangerPreset("Sunrise - First Lights Off", "06:30:01"),
            MoodChangerPreset("Sunrise - Default", "07:37:12"),

            MoodChangerPreset("Day - Default", "12:06:00"),

            MoodChangerPreset("Sunset - Last Lights Off", "18:30:00"),
            MoodChangerPreset("Sunset - First Lights On", "18:30:01"),
            MoodChangerPreset("Sunset - Default", "19:22:48"),

            MoodChangerPreset("Night - Midnight", "00:00:00"),
            MoodChangerPreset("Night - Default", "02:24:01")
        };
#endif

        MoodChangerPreset@[]@ GetMoodChangerPresets(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            return g_moodChangerPresetsStadiumNext;
#elif MP4
            if (editor !is null && editor.Challenge !is null)
            {
                if (editor.Challenge.CollectionName == "Canyon")
                {
                    return g_moodChangerPresetsCanyon;
                }
                else if (editor.Challenge.CollectionName == "Lagoon")
                {
                    return g_moodChangerPresetsLagoon;
                }
                else if (editor.Challenge.CollectionName == "Valley")
                {
                    return g_moodChangerPresetsValley;
                }
                else if (editor.Challenge.CollectionName == "Stadium")
                {
                    return g_moodChangerPresetsStadium2;
                }
            }
            return null;
#else
            return null;
#endif
        }

    }

    [Setting category="Functions" name="Mood Changer: Enabled" hidden]
    bool Setting_MoodChanger_Enabled = true;

    class MoodChanger : EditorHelpers::EditorFunction
    {
        private string m_setTime;
        private bool m_settingChanged;
        private int m_selectedPresetIndex;
        private EditorHelpers::Compatibility::MoodChangerPreset@[]@ m_presets;

        private bool TimeMatchesRegex(const string &in time)
        {
            string regex = "^(0[0-9]|1[0-9]|2[0-4]):([0-5][0-9]):([0-5][0-9])$";
            return Regex::IsMatch(time, regex);
        }

        string Name() override { return "Mood Changer"; }
        bool Enabled() override { return Setting_MoodChanger_Enabled; }
        bool SupportsPresets() override { return true; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_MoodChanger_Enabled = UI::Checkbox("Enabled", Setting_MoodChanger_Enabled);
            UI::BeginDisabled(!Setting_MoodChanger_Enabled);
            UI::TextWrapped("This provides an interface to modify the game time of a map down to the second for a 24 hour period.");
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("MoodChanger::CurrentTime");
                EditorHelpers::SetHighlightId("MoodChanger::Presets");
                EditorHelpers::SetHighlightId("MoodChanger::SetTime");
            }

            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled()) return;

            if (Editor is null)
            {
                m_settingChanged = false;
                m_selectedPresetIndex = -1;
                @m_presets = null;
            }
        }


        void Update(float dt) override
        {
            if (!Enabled() || Editor is null) return;

            if (Signal_EnteredEditor())
            {
                @m_presets = Compatibility::GetMoodChangerPresets(Editor);
            }

            if (m_settingChanged)
            {
                m_settingChanged = false;
                Editor.MoodTimeOfDayStr = m_setTime;
            }

            if (m_presets !is null)
            {
                m_selectedPresetIndex = -1;
                for (uint i = 0; i < m_presets.Length; ++i)
                {
                    if (m_presets[i].Time == Editor.MoodTimeOfDayStr)
                    {
                        m_selectedPresetIndex = int(i);
                        break;
                    }
                }
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled() || Editor is null) return;

            UI::TextDisabled("\tMood");

            EditorHelpers::BeginHighlight("MoodChanger::CurrentTime");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the mood to a specific time of the day");
                UI::SameLine();
            }
            UI::Text("Current map time: " + Editor.MoodTimeOfDayStr);
            EditorHelpers::EndHighlight();

            EditorHelpers::BeginHighlight("MoodChanger::Presets");
            if (m_presets !is null)
            {
                if (UI::BeginCombo("Mood Presets",
                    m_selectedPresetIndex >= 0 && m_selectedPresetIndex < int(m_presets.Length)
                        ? m_presets[m_selectedPresetIndex].Name
                        : ""))
                {
                    for (uint i = 0; i < m_presets.Length; ++i)
                    {
                        if (UI::Selectable(m_presets[i].Name, m_selectedPresetIndex == int(i)))
                        {
                            m_setTime = m_presets[i].Time;
                            m_settingChanged = true;
                        }
                    }
                    UI::EndCombo();
                }
            }
            else
            {
                UI::BeginDisabled(true);
                if (UI::BeginCombo("Mood Presets", "N/A"))
                {
                    UI::EndCombo();
                }
                UI::EndDisabled();
            }
            EditorHelpers::EndHighlight();

            EditorHelpers::BeginHighlight("MoodChanger::SetTime");
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
            EditorHelpers::EndHighlight();
        }

        void SerializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            json["time"] = Editor.MoodTimeOfDayStr;
        }

        void DeserializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_time", Json::Value(true))))
            {
                m_setTime = string(json.Get("time", Json::Value("12:06:00")));
                m_settingChanged = true;
            }
        }

        void RenderPresetValues(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_time", Json::Value(true))))
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Time");
                UI::TableNextColumn();
                UI::Text(string(json.Get("time", Json::Value("12:06:00"))));
            }
        }

        bool RenderPresetEnables(Json::Value@ json, bool defaultValue, bool forceValue) override
        {
            bool changed = false;
            if (!Enabled()) { return changed; }
            if (JsonCheckboxChanged(json, "enable_time", "Time", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("MoodChanger::CurrentTime");
            }
            return changed;
        }
    }
}