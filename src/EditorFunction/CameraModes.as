namespace EditorHelpers
{
    class CameraModesPreset : EditorFunctionPresetBase
    {
        bool EnableCamera;
        string Camera;

        CameraModesPreset()
        {
            super("Camera Modes");
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_camera"] = EnableCamera;
            m_json["camera"] = Camera;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableCamera = json.Get("enable_camera", Json::Value(true));
            Camera = json.Get("camera", Json::Value("Orbital"));
        }
    }

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

    class CameraModes : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
    {
        private bool SettingUpdated = false;
        private string Setting_CameraMode_CurrentMode = "Orbital";

        string Name() override { return "Camera Modes"; }
        bool Enabled() override { return Setting_CameraMode_Enabled; }

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

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return CameraModesPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            CameraModesPreset@ preset = cast<CameraModesPreset>(data);
            if (preset is null) { return; }
            preset.Camera = Setting_CameraMode_CurrentMode;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            CameraModesPreset@ preset = cast<CameraModesPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableCamera)
            {
                Setting_CameraMode_CurrentMode = preset.Camera;
                SettingUpdated = true;
            }
        }

        bool CheckPreset(EditorFunctionPresetBase@ data) override
        {
            bool areSame = true;
            if (!Enabled()) { return areSame; }
            CameraModesPreset@ preset = cast<CameraModesPreset>(data);
            if (preset is null) { return areSame; }
            if (preset.EnableCamera)
            {
                if (Setting_CameraMode_CurrentMode != preset.Camera) { areSame = false; }
            }
            return areSame;
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            CameraModesPreset@ preset = cast<CameraModesPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableCamera)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Camera Mode");
                UI::TableNextColumn();
                UI::Text(preset.Camera);
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            CameraModesPreset@ preset = cast<CameraModesPreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableCamera, preset.EnableCamera, "Camera", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CameraModes::CameraMode");
            }
            return changed;
        }
    }
}