
namespace EditorHelpers
{
    [Setting category="Functions" name="Quicksave: Enabled" description="Uncheck to disable plugin function for quicksave"]
    bool Setting_Quicksave_Enabled = true;
    class Quicksave : EditorHelpers::EditorFunction
    {
        private EditorHelpers::CountdownTimer timerQuicksave;

        bool Enabled() override { return Setting_Quicksave_Enabled; }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                timerQuicksave.MaxTime = 2.0f;
            }
        }

        void RenderInterface_Action() override
        {
            if (!Enabled()) return;

            string currentFileName = Editor.PluginMapType.MapFileName;
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Save map in one click");
                UI::SameLine();
            }
            if (UI::Button("Save Map"))
            {
                if (timerQuicksave.Complete())
                {
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
            }
            UI::SameLine();
            UI::Text(currentFileName);
        }

        void Update(float dt) override
        {
            if (!Enabled() || Editor is null) return;
            float dtSeconds = dt / 1000.0f;
            timerQuicksave.Update(dtSeconds);
        }
    }
}