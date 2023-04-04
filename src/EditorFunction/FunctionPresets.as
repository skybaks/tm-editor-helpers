
namespace EditorHelpers
{
    [Setting category="Functions" name="Function Presets: Enabled" hidden]
    bool Setting_FunctionPresets_Enabled = true;
    [Setting category="Functions" name="Function Presets: Window Visible" hidden]
    bool Setting_FunctionPresets_WindowVisible = true;

    class FunctionPresets : EditorHelpers::EditorFunction
    {
        string Name() override { return "Presets"; }
        bool Enabled() override { return Setting_FunctionPresets_Enabled; }

        void Init() override
        {
            if (!Enabled()) { return; }
        }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_FunctionPresets_Enabled = UI::Checkbox("Enabled", Setting_FunctionPresets_Enabled);
            UI::BeginDisabled(!Setting_FunctionPresets_Enabled);
            UI::TextWrapped("************************************** TODO **************************************");

            Setting_FunctionPresets_WindowVisible = UI::Checkbox("Show Additional Window", Setting_FunctionPresets_WindowVisible);
            UI::EndDisabled();
            UI::PopID();
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) { return; }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Show or hide the window for managing presets");
                UI::SameLine();
            }
            Setting_FunctionPresets_WindowVisible = UI::Checkbox("Show Presets Window", Setting_FunctionPresets_WindowVisible);
        }

        void RenderInterface_ChildWindow() override
        {
            if (!Enabled() || !Setting_FunctionPresets_WindowVisible)
            {
                g_presetConfigMode = false;
                return;
            }

            g_presetConfigMode = true;

            UI::SetNextWindowSize(550, 350, UI::Cond::FirstUseEver);
            UI::Begin(g_windowName + ": " + Name(), Setting_FunctionPresets_WindowVisible);

            UI::Text("Create");

            for (uint index = 0; index < functions.Length; index++)
            {
                EditorFunction@ ef = functions[index];
                if (ef.SupportsPresets())
                {
                    ef.PresetConfigMode = UI::Checkbox(ef.Name() + "##" + tostring(index), ef.PresetConfigMode);
                }
            }

            UI::End();
        }

        void RenderInterface_MenuItem() override
        {
            if (!Enabled()) { return; }

            if (UI::MenuItem(Icons::PuzzlePiece + " " + Name(), selected: Setting_FunctionPresets_WindowVisible))
            {
                Setting_FunctionPresets_WindowVisible = !Setting_FunctionPresets_WindowVisible;
            }
        }

        void Update(float) override
        {
        }

        private void CreateNewPreset()
        {
            auto functionsJson = Json::Array();

            for (uint index = 0; index < functions.Length; index++)
            {
                EditorFunction@ ef = functions[index];
                if (ef.SupportsPresets() && ef.PresetConfigMode)
                {
                    auto functionJson = Json::Object();
                    functionJson[ef.Name()] = ef.SerializePresets();
                    functionsJson.Add(functionJson);
                }
            }
        }

        private void LoadPresets()
        {
            Debug_EnterMethod("LoadPresets");

            auto json = Json::FromFile(IO::FromStorageFolder("EditorFunction_FunctionPresets.json"));

            Debug_LeaveMethod();
        }

        private void SavePresets()
        {
            Debug_EnterMethod("SavePresets");

            auto json = Json::Object();

            Json::ToFile(IO::FromStorageFolder("EditorFunction_FunctionPresets.json"), json);

            Debug_LeaveMethod();
        }
    }
}
