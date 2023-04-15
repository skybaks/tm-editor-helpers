
namespace EditorHelpers
{
    namespace Compatibility
    {
        bool FreeblockModePreciseRotationShouldBeActive(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            return editor.Cursor.UseFreePos || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item;
#else
            return editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item;
#endif
        }

        string FreeblockModePreciseRotationName()
        {
#if TMNEXT
            return "";
#else
            return "Item ";
#endif
        }
    }

    [Setting category="Functions" name="FreeblockModePreciseRotation: Enabled" hidden]
    bool Settings_FreeblockModePreciseRotation_Enabled = true;
    [Setting category="Functions" name="FreeblockModePreciseRotation: Persist Step Size" hidden]
    bool Setting_FreeblockModePreciseRotation_PersistStep = false;

    [Setting category="Functions" hidden]
    string Setting_FreeblockModePreciseRotation_StepSizeName = "Default";

    class FreeblockModePreciseRotation : EditorHelpers::EditorFunction
    {
        float inputPitch = 0.0f;
        float inputRoll = 0.0f;
        float stepSize = 15.0f;
        bool newInputToApply = false;

        string Name() override { return Compatibility::FreeblockModePreciseRotationName() + "Precise Rotation"; }
        bool Enabled() override { return Settings_FreeblockModePreciseRotation_Enabled; }
        bool SupportsPresets() override { return true; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Settings_FreeblockModePreciseRotation_Enabled = UI::Checkbox("Enabled", Settings_FreeblockModePreciseRotation_Enabled);
            UI::BeginDisabled(!Settings_FreeblockModePreciseRotation_Enabled);
            UI::TextWrapped("Provides an interface to set any rotation angle in degrees. Also includes step presets for Nadeo slope angles.");
            Setting_FreeblockModePreciseRotation_PersistStep = UI::Checkbox("Persist angle step size selection between editor sessions", Setting_FreeblockModePreciseRotation_PersistStep);
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (Editor is null || !Enabled() || FirstPass)
            {
                inputPitch = 0.0f;
                inputRoll = 0.0f;
                newInputToApply = false;

                if (!Setting_FreeblockModePreciseRotation_PersistStep)
                {
                    Setting_FreeblockModePreciseRotation_StepSizeName = "Default";
                }

                if (Setting_FreeblockModePreciseRotation_StepSizeName == "Default")
                {
                    stepSize = 15.0f;
                }
                else if (Setting_FreeblockModePreciseRotation_StepSizeName == "Half-BiSlope")
                {
                    stepSize = Math::ToDeg(Math::Atan(4.0f / 32.0f));
                }
                else if (Setting_FreeblockModePreciseRotation_StepSizeName == "BiSlope")
                {
                    stepSize = Math::ToDeg(Math::Atan(8.0f / 32.0f));
                }
                else if (Setting_FreeblockModePreciseRotation_StepSizeName == "Slope2")
                {
                    stepSize = Math::ToDeg(Math::Atan(16.0f / 32.0f));
                }
                else if (Setting_FreeblockModePreciseRotation_StepSizeName == "Slope3")
                {
                    stepSize = Math::ToDeg(Math::Atan(24.0f / 32.0f));
                }
                else if (Setting_FreeblockModePreciseRotation_StepSizeName == "Slope4")
                {
                    stepSize = Math::ToDeg(Math::Atan(32.0f / 32.0f));
                }
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled()) return;

            UI::PushID("FreeblockModePreciseRotation::RenderInterface");

            UI::TextDisabled("\tRotation");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the rotational step size of the pitch and roll inputs to a game slope.");
                UI::SameLine();
            }
            if (UI::BeginCombo("Step Size", Setting_FreeblockModePreciseRotation_StepSizeName))
            {
                if (UI::Selectable("Default", false))
                {
                    stepSize = 15.0f;
                    Setting_FreeblockModePreciseRotation_StepSizeName = "Default";
                }
                else if (UI::Selectable("Half-BiSlope", false))
                {
                    stepSize = Math::ToDeg(Math::Atan(4.0f / 32.0f));
                    Setting_FreeblockModePreciseRotation_StepSizeName = "Half-BiSlope";
                }
                else if (UI::Selectable("BiSlope", false))
                {
                    stepSize = Math::ToDeg(Math::Atan(8.0f / 32.0f));
                    Setting_FreeblockModePreciseRotation_StepSizeName = "BiSlope";
                }
                else if (UI::Selectable("Slope2", false))
                {
                    stepSize = Math::ToDeg(Math::Atan(16.0f / 32.0f));
                    Setting_FreeblockModePreciseRotation_StepSizeName = "Slope2";
                }
                else if (UI::Selectable("Slope3", false))
                {
                    stepSize = Math::ToDeg(Math::Atan(24.0f / 32.0f));
                    Setting_FreeblockModePreciseRotation_StepSizeName = "Slope3";
                }
                else if (UI::Selectable("Slope4", false))
                {
                    stepSize = Math::ToDeg(Math::Atan(32.0f / 32.0f));
                    Setting_FreeblockModePreciseRotation_StepSizeName = "Slope4";
                }
                UI::EndCombo();
            }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Use the +/- below to step this exact amount.");
                UI::SameLine();
            }
            UI::Text("Current Step: " + tostring(stepSize) + " deg");

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Pitch of the block in degrees. Use the +/- to increment or enter any value.");
                UI::SameLine();
            }
            float inputPitchResult = UI::InputFloat("Pitch (deg)", inputPitch, stepSize);
            if (inputPitchResult != inputPitch)
            {
                inputPitch = inputPitchResult;
                newInputToApply = true;
            }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Roll of the block in degrees. Use the +/- to increment or enter any value.");
                UI::SameLine();
            }
            float inputRollResult = UI::InputFloat("Roll (deg)", inputRoll, stepSize);
            if (inputRollResult != inputRoll)
            {
                inputRoll = inputRollResult;
                newInputToApply = true;
            }
            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Compatibility::FreeblockModePreciseRotationShouldBeActive(Editor))
            {
                if (newInputToApply)
                {
                    Editor.Cursor.Pitch = Math::ToRad(inputPitch);
                    Editor.Cursor.Roll = Math::ToRad(inputRoll);
                    newInputToApply = false;
                }
                inputPitch = Math::ToDeg(Editor.Cursor.Pitch);
                inputRoll = Math::ToDeg(Editor.Cursor.Roll);
            }
        }

        void SerializePresets(Json::Value@ json) override
        {
            json["step_size"] = Setting_FreeblockModePreciseRotation_StepSizeName;
            json["pitch"] = inputPitch;
            json["roll"] = inputRoll;
        }

        void DeserializePresets(Json::Value@ json) override
        {
            Setting_FreeblockModePreciseRotation_StepSizeName = string(json.Get("step_size", Json::Value("Default")));
            inputPitch = float(json.Get("pitch", Json::Value(0.0f)));
            inputRoll = float(json.Get("roll", Json::Value(0.0f)));
            newInputToApply = true;
        }

        void RenderPresetValues(Json::Value@ json) override
        {
            UI::Text("Step Size: " + string(json.Get("step_size", Json::Value("Default"))));
            UI::Text("Pitch: " + float(json.Get("pitch", Json::Value(0.0f))));
            UI::Text("Roll: " + float(json.Get("roll", Json::Value(0.0f))));
        }
    }
}
