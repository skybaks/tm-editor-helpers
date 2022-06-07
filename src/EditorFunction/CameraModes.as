namespace EditorHelpers
{
    array<string> CameraModesStr = {
        "Orbital",
        "Free"
    };
    [Setting category="Functions" name="Camera Modes: Enable" description="Enable"]
    bool Setting_CameraMode_Enabled = true;
    string Setting_CameraMode_CurrentMode = CameraModesStr[0];

    class CameraModes : EditorHelpers::EditorFunction
    {

        bool SettingUpdated = false;

        bool Enabled() override { return Setting_CameraMode_Enabled; }

        void Update(float dt) override
        {
            if (!Enabled()) return;

            if (SettingUpdated)
            {
                if (Setting_CameraMode_CurrentMode == CameraModesStr[1]) {
                    Editor.CamMode = CGameCtnEditorCommon::_EUnnamedEnum::Free;
                } else {
                    Editor.CamMode = CGameCtnEditorCommon::_EUnnamedEnum::Orbital;
                }
                SettingUpdated = false;
                return;
            }
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Switch between Orbital (default) camera and Free camera.");
                UI::SameLine();
            }
            if (UI::BeginCombo("Camera mode", Setting_CameraMode_CurrentMode)) {
                if (UI::Selectable("Orbital (default)", false))
                {
                    Setting_CameraMode_CurrentMode = CameraModesStr[0];
                    SettingUpdated = true;
                }
                else if (UI::Selectable("Free", false))
                {
                    Setting_CameraMode_CurrentMode = CameraModesStr[1];
                    SettingUpdated = true;
                }
                UI::EndCombo();
            }
        }
    }
}