
namespace EditorHelpers
{
    class FreeblockModePreciseRotationPreset : EditorFunctionPresetBase
    {
        bool EnableStepSize = true;
        string StepSize = "Default";
        bool EnablePitchRoll = true;
        float Pitch = 0.0f;
        float Roll = 0.0f;

        FreeblockModePreciseRotationPreset()
        {
            super(Compatibility::FreeblockModePreciseRotationName());
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_step_size"] = EnableStepSize;
            m_json["step_size"] = StepSize;
            m_json["enable_pitch_roll"] = EnablePitchRoll;
            m_json["pitch"] = Pitch;
            m_json["roll"] = Roll;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableStepSize = json.Get("enable_step_size", Json::Value(true));
            StepSize = json.Get("step_size", Json::Value("Default"));
            EnablePitchRoll = json.Get("enable_pitch_roll", Json::Value(true));
            Pitch = json.Get("pitch", Json::Value(0.0f));
            Roll = json.Get("roll", Json::Value(0.0f));
        }

    }

    namespace Compatibility
    {
        bool FreeblockModePreciseRotationShouldBeActive(CGameCtnEditorFree@ editor)
        {
            bool allowed = false;
#if TMNEXT
            allowed =
                editor.Cursor.UseFreePos
                || (
                    editor.PluginMapType !is null /* Allow rotations even when PluginMapType is null */
                    || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item
                );
#else
            allowed =
                editor !is null
                && (
                    editor.PluginMapType is null /* Allow rotations even when PluginMapType is null */
                    || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item
                );
#endif
            return allowed;
        }

        string FreeblockModePreciseRotationName()
        {
#if TMNEXT
            return "Precise Rotation";
#else
            return "Item Precise Rotation";
#endif
        }
    }

    [Setting category="Functions" name="FreeblockModePreciseRotation: Enabled" hidden]
    bool Settings_FreeblockModePreciseRotation_Enabled = true;
    [Setting category="Functions" name="FreeblockModePreciseRotation: Persist Step Size" hidden]
    bool Setting_FreeblockModePreciseRotation_PersistStep = false;

    [Setting category="Functions" hidden]
    string Setting_FreeblockModePreciseRotation_StepSizeName = "Default";

    class FreeblockModePreciseRotation : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
    {
        float inputPitch = 0.0f;
        float inputRoll = 0.0f;
        float stepSize = 15.0f;
        bool newInputToApply = false;

        string Name() override { return Compatibility::FreeblockModePreciseRotationName(); }
        bool Enabled() override { return Settings_FreeblockModePreciseRotation_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Settings_FreeblockModePreciseRotation_Enabled = UI::Checkbox("Enabled", Settings_FreeblockModePreciseRotation_Enabled);
            UI::BeginDisabled(!Settings_FreeblockModePreciseRotation_Enabled);
            UI::TextWrapped("Provides an interface to set any rotation angle in degrees. Also includes step presets"
                " for Nadeo slope angles.");
            Setting_FreeblockModePreciseRotation_PersistStep = UI::Checkbox("Persist angle step size selection between editor sessions", Setting_FreeblockModePreciseRotation_PersistStep);
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("FreeblockModePreciseRotation::StepSize");
                EditorHelpers::SetHighlightId("FreeblockModePreciseRotation::PitchRoll");
            }

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

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            UI::PushID("FreeblockModePreciseRotation::RenderInterface");

            UI::TextDisabled("\tRotation");
            EditorHelpers::BeginHighlight("FreeblockModePreciseRotation::StepSize");
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
            EditorHelpers::EndHighlight();

            EditorHelpers::BeginHighlight("FreeblockModePreciseRotation::PitchRoll");
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
            EditorHelpers::EndHighlight();
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

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return FreeblockModePreciseRotationPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            FreeblockModePreciseRotationPreset@ preset = cast<FreeblockModePreciseRotationPreset>(data);
            if (preset is null) { return; }
            preset.StepSize = Setting_FreeblockModePreciseRotation_StepSizeName;
            preset.Pitch = inputPitch;
            preset.Roll = inputRoll;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            FreeblockModePreciseRotationPreset@ preset = cast<FreeblockModePreciseRotationPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableStepSize)
            {
                Setting_FreeblockModePreciseRotation_StepSizeName = preset.StepSize;
            }
            if (preset.EnablePitchRoll)
            {
                inputPitch = preset.Pitch;
                inputRoll = preset.Roll;
                newInputToApply = true;
            }
        }

        bool CheckPreset(EditorFunctionPresetBase@ data) override
        {
            bool areSame = true;
            if (!Enabled()) { return areSame; }
            FreeblockModePreciseRotationPreset@ preset = cast<FreeblockModePreciseRotationPreset>(data);
            if (preset is null) { return areSame; }
            if (preset.EnableStepSize)
            {
                if (Setting_FreeblockModePreciseRotation_StepSizeName != preset.StepSize) { areSame = false; }
            }
            if (preset.EnablePitchRoll)
            {
                if (inputPitch != preset.Pitch
                    || inputRoll != preset.Roll) { areSame = false; }
            }
            return areSame;
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            FreeblockModePreciseRotationPreset@ preset = cast<FreeblockModePreciseRotationPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableStepSize)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Step Size");
                UI::TableNextColumn();
                UI::Text(preset.StepSize);
            }
            if (preset.EnablePitchRoll)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Pitch");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Pitch));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Roll");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Roll));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            FreeblockModePreciseRotationPreset@ preset = cast<FreeblockModePreciseRotationPreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableStepSize, preset.EnableStepSize, "Step Size", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("FreeblockModePreciseRotation::StepSize");
            }
            if (ForcedCheckbox(preset.EnablePitchRoll, preset.EnablePitchRoll, "Pitch/Roll", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("FreeblockModePreciseRotation::PitchRoll");
            }
            return changed;
        }
    }
}
