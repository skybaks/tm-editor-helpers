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

    [Setting category="Functions" name="Camera Modes: Enable" description="Enable"]
    bool Setting_CameraMode_Enabled = true;

    class CameraModes : EditorHelpers::EditorFunction
    {
        private bool SettingUpdated = false;
        private string Setting_CameraMode_CurrentMode = "Orbital";

        bool Enabled() override { return Setting_CameraMode_Enabled; }

        void Update(float dt) override
        {
            if (!Enabled()) return;

            if (SettingUpdated)
            {
                Compatibility::SetCamMode(Editor, Setting_CameraMode_CurrentMode);
                SettingUpdated = false;
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
        }
    }
}