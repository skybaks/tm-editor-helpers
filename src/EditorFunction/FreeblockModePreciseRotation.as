
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

    [Setting category="Functions" name="FreeblockModePreciseRotation: Enabled" description="Uncheck to disable all plugin functions related to Block/Item Precise Rotation"]
    bool Settings_FreeblockModePreciseRotation_Enabled = true;
    class FreeblockModePreciseRotation : EditorHelpers::EditorFunction
    {
        float inputPitch = 0.0f;
        float inputRoll = 0.0f;
        float stepSize = 1.0f;
        string stepSizeName = "Default";
        bool newInputToApply = false;

        bool Enabled() override { return Settings_FreeblockModePreciseRotation_Enabled; }

        void Init() override
        {
            if (Editor is null || !Enabled() || FirstPass)
            {
                inputPitch = 0.0f;
                inputRoll = 0.0f;
                newInputToApply = false;
                if (stepSizeName == "Default")
                {
                    stepSize = 1.0f;
                }
                else if (stepSizeName == "BiBiSlope")
                {
                    stepSize = Math::ToDeg(Math::Atan(4.0f / 32.0f));
                }
                else if (stepSizeName == "BiSlope")
                {
                    stepSize = Math::ToDeg(Math::Atan(8.0f / 32.0f));
                }
                else if (stepSizeName == "Slope2")
                {
                    stepSize = Math::ToDeg(Math::Atan(16.0f / 32.0f));
                }
            }
        }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            UI::PushID("FreeblockModePreciseRotation::RenderInterface");
            if (UI::CollapsingHeader(Compatibility::FreeblockModePreciseRotationName() + "Precise Rotation"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Sets the rotational step size of the pitch and roll inputs to a game slope.");
                    UI::SameLine();
                }
                if (UI::BeginCombo("Step Size", stepSizeName))
                {
                    if (UI::Selectable("Default", false))
                    {
                        stepSize = 1.0f;
                        stepSizeName = "Default";
                    }
                    else if (UI::Selectable("BiBiSlope", false))
                    {
                        stepSize = Math::ToDeg(Math::Atan(4.0f / 32.0f));
                        stepSizeName = "BiBiSlope";
                    }
                    else if (UI::Selectable("BiSlope", false))
                    {
                        stepSize = Math::ToDeg(Math::Atan(8.0f / 32.0f));
                        stepSizeName = "BiSlope";
                    }
                    else if (UI::Selectable("Slope2", false))
                    {
                        stepSize = Math::ToDeg(Math::Atan(16.0f / 32.0f));
                        stepSizeName = "Slope2";
                    }
                    UI::EndCombo();
                }

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
    }
}
