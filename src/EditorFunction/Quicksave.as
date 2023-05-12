
namespace EditorHelpers
{
    namespace HotkeyInterface
    {
        bool g_Quicksave_Activate = false;

        bool Enabled_Quicksave()
        {
            return Setting_Quicksave_Enabled;
        }

        void ActivateQuicksave()
        {
            if (Setting_Quicksave_Enabled)
            {
                g_Quicksave_Activate = true;
            }
        }
    }

    [Setting category="Functions" name="Quicksave: Enabled" hidden]
    bool Setting_Quicksave_Enabled = true;

    class Quicksave : EditorHelpers::EditorFunction
    {
        private EditorHelpers::CountdownTimer timerQuicksave;
        private bool m_triggerSave;

        string Name() override { return "Quicksave"; }
        bool Enabled() override { return Setting_Quicksave_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_Quicksave_Enabled = UI::Checkbox("Enabled", Setting_Quicksave_Enabled);
            UI::BeginDisabled(!Setting_Quicksave_Enabled);
            UI::TextWrapped("Provides an interface to be able to save your map in one click without popup dialogs.");
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("Quicksave::Display");
            }

            UI::PopID();
        }

        void Init() override
        {
            if (FirstPass)
            {
                timerQuicksave.MaxTime = 2.0f;
            }

            if (!Enabled() || Editor is null)
            {
                m_triggerSave = false;
                HotkeyInterface::g_Quicksave_Activate = false;
            }
        }

        void RenderInterface_MainWindow() override
        {
            if (!Enabled() || Editor is null) return;

            EditorHelpers::BeginHighlight("Quicksave::Display");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Save map in one click");
                UI::SameLine();
            }
            UI::BeginDisabled(!timerQuicksave.Complete());
            if (UI::Button("Save Map"))
            {
                m_triggerSave = true;
            }
            UI::EndDisabled();
            UI::SameLine();
            UI::Text(Editor.PluginMapType.MapFileName);
            EditorHelpers::EndHighlight();
        }

        void Update(float dt) override
        {
            if (!Enabled() || Editor is null) return;
            float dtSeconds = dt / 1000.0f;
            timerQuicksave.Update(dtSeconds);

            if ((m_triggerSave || HotkeyInterface::g_Quicksave_Activate) && timerQuicksave.Complete())
            {
                string currentFileName = Editor.PluginMapType.MapFileName;
                if (currentFileName != "")
                {
                    string[] mapPath = currentFileName.Split("\\");
                    string saveName = "";
                    for (uint i = 0; i < (mapPath.Length - 1); i++)
                    {
                        saveName += mapPath[i] + "\\";
                    }
                    saveName += Editor.PluginMapType.MapName + ".Map.Gbx";
                    Editor.PluginMapType.SaveMap(saveName);
                }
                else
                {
                    Editor.ButtonSaveOnClick();
                }
                timerQuicksave.StartNew();
            }

            m_triggerSave = false;
            HotkeyInterface::g_Quicksave_Activate = false;
        }
    }
}