namespace EditorHelpers
{
    namespace Compatibility
    {
        void SetCamMode(CGameCtnEditorFree@ editor, const string&in camMode)
        {
#if TMNEXT
            if (camMode == "Free")
            {
                editor.CamMode = CGameCtnEditorCommon::Free;
            }
            else if (camMode == "Orbital")
            {
                editor.CamMode = CGameCtnEditorCommon::Orbital;
            }
#else
            if (camMode == "Free")
            {
                editor.CamMode = CGameCtnEditorCommon::Free;
            }
            else if (camMode == "Orbital")
            {
                editor.CamMode = CGameCtnEditorCommon::Orbital;
            }
#endif
        }
    }

    [Setting category="Functions" name="Camera Modes: Enable" hidden]
    bool Setting_CameraMode_Enabled = true;

    class CameraModes : EditorHelpers::EditorFunction
    {
        private bool SettingUpdated = false;
        private string Setting_CameraMode_CurrentMode = "Orbital";

        string Name() override { return "Camera Modes"; }
        bool Enabled() override { return Setting_CameraMode_Enabled; }
        bool SupportsPresets() override { return true; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_CameraMode_Enabled = UI::Checkbox("Enabled", Setting_CameraMode_Enabled);
            UI::BeginDisabled(!Setting_CameraMode_Enabled);
            UI::TextWrapped("Provides an interface for switching to other cameras in the map editor.");
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CameraModes::CameraMode");
            }

            UI::PopID();
        }

        void Update(float dt) override
        {
            if (!Enabled()) return;

            if (SettingUpdated)
            {
                Compatibility::SetCamMode(Editor, Setting_CameraMode_CurrentMode);
                SettingUpdated = false;
            }
        }

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            EditorHelpers::BeginHighlight("CameraModes::CameraMode");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Switch between Orbital (default) camera and Free camera.");
                UI::SameLine();
            }
            if (UI::BeginCombo("Camera mode", Setting_CameraMode_CurrentMode)) {
                if (UI::Selectable("Orbital (default)", false))
                {
                    Setting_CameraMode_CurrentMode = "Orbital";
                    SettingUpdated = true;
                }
                else if (UI::Selectable("Free", false))
                {
                    Setting_CameraMode_CurrentMode = "Free";
                    SettingUpdated = true;
                }
                UI::EndCombo();
            }
            EditorHelpers::EndHighlight();
        }

        void SerializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            json["camera"] = Setting_CameraMode_CurrentMode;
        }

        void DeserializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_camera", Json::Value(true))))
            {
                Setting_CameraMode_CurrentMode = string(json.Get("camera", Json::Value("Orbital")));
                SettingUpdated = true;
            }
        }

        void RenderPresetValues(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_camera", Json::Value(true))))
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Camera Mode");
                UI::TableNextColumn();
                UI::Text(tostring(string(json.Get("camera", Json::Value("Orbital")))));
            }
        }

        bool RenderPresetEnables(Json::Value@ json, bool defaultValue, bool forceValue) override
        {
            bool changed = false;
            if (!Enabled()) { return changed; }
            if (JsonCheckboxChanged(json, "enable_camera", "Camera", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CameraModes::CameraMode");
            }
            return changed;
        }
    }
}