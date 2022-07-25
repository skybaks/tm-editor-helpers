
namespace EditorHelpers
{
    namespace Compatibility
    {
        bool RotationRandomizerCanBeUsed(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            return editor.Cursor.UseFreePos || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item;
#else
            return editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item;
#endif
        }

        uint GetGhostBlocksCount(CGameCtnEditorFree@ editor)
        {
            uint count = 0;
#if TMNEXT
            count = editor.PluginMapType.GhostBlocks.Length;
#endif
            return count;
        }
    }

    enum RotationRandomizerMode
    {
        OFF = 0,
        RANDOM = 1,
        FIXED_STEP = 2
    }

    [Setting category="Functions" name="RotationRandomizer: Enabled" hidden]
    bool Setting_RotationRandomizer_Enabled = true;

    class RotationRandomizer : EditorHelpers::EditorFunction
    {
        private RotationRandomizerMode selectedMode = RotationRandomizerMode::OFF;
        private bool axisX = false;
        private bool axisY = false;
        private bool axisZ = false;
        private vec2 limitsY = vec2(-180.0, 180.0);
        private vec2 limitsX = vec2(-180.0, 180.0);
        private vec2 limitsZ = vec2(-180.0, 180.0);
        private float stepY = 15.0;
        private float stepX = 10.0;
        private float stepZ = 10.0;

        private uint prevClassicBlockCount = 0;
        private uint prevGhostBlockCount = 0;
        private uint prevAnchoredObjectCount = 0;

        string Name() override { return "Rotation Randomizer"; }
        bool Enabled() override { return Setting_RotationRandomizer_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_RotationRandomizer_Enabled = UI::Checkbox("Enabled", Setting_RotationRandomizer_Enabled);
            UI::BeginDisabled(!Setting_RotationRandomizer_Enabled);
            UI::TextWrapped("Provides an interface which allows you to activate and customize the limits of the rotation randomizer. When the randomizer is turned on a random rotation within the defined limits will be chosen for each selected axis after you place a block or item.");
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                selectedMode = RotationRandomizerMode::OFF;
                axisX = false;
                axisY = false;
                axisZ = false;
                limitsY = vec2(-180.0, 180.0);
                limitsX = vec2(-180.0, 180.0);
                limitsZ = vec2(-180.0, 180.0);
                stepY = 15.0;
                stepX = 10.0;
                stepZ = 10.0;
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled()) return;

            UI::PushID("RotationRandomizer::RenderInterface_Build");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Randomize rotation after click\n\nRANDOM - Randomize selected axis's within defined limits\nFIXED_STEP - Increment selected axis's by fixed step");
                UI::SameLine();
            }
            if (UI::BeginCombo("Randomizer", tostring(selectedMode)))
            {
                if (UI::Selectable(tostring(RotationRandomizerMode::OFF), false))
                {
                    selectedMode = RotationRandomizerMode::OFF;
                }
                else if (UI::Selectable(tostring(RotationRandomizerMode::RANDOM), false))
                {
                    selectedMode = RotationRandomizerMode::RANDOM;
                }
                else if (UI::Selectable(tostring(RotationRandomizerMode::FIXED_STEP), false))
                {
                    selectedMode = RotationRandomizerMode::FIXED_STEP;
                }
                UI::EndCombo();
            }

            int columnCount = 3;
            if (selectedMode == RotationRandomizerMode::FIXED_STEP)
            {
                columnCount = 2;
            }
            if (UI::BeginTable("RotationRandomizerAxisTable", columnCount))
            {
                UI::TableSetupColumn("Col1", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 65.0);
                if (selectedMode == RotationRandomizerMode::FIXED_STEP)
                {
                    UI::TableSetupColumn("Col2", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 190.0);
                }
                else
                {
                    UI::TableSetupColumn("Col2", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 95.0);
                    UI::TableSetupColumn("Col3", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 95.0);
                }

                UI::TableNextRow();
                UI::TableNextColumn();
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Rotation Randomizer should rotate about the vertical axis (Yaw)");
                    UI::SameLine();
                }
                axisY = UI::Checkbox("Y", axisY);
                if (selectedMode == RotationRandomizerMode::FIXED_STEP)
                {
                    UI::TableNextColumn();
                    float newStepY = UI::InputFloat("Step##Y", stepY, 0.0);
                    stepY = Math::Clamp(ClosestValidYawAngle(newStepY), -180.0, 180.0);
                }
                else
                {
                    UI::TableNextColumn();
                    float newMinLimitY = UI::InputFloat("Min##Y", limitsY.x, 0.0);
                    limitsY.x = Math::Clamp(ClosestValidYawAngle(newMinLimitY), -180.0, Math::Min(limitsY.y, 180.0));
                    UI::TableNextColumn();
                    float newMaxLimitY = UI::InputFloat("Max##Y", limitsY.y, 0.0);
                    limitsY.y = Math::Clamp(ClosestValidYawAngle(newMaxLimitY), Math::Max(limitsY.x, -180.0), 180.0);
                }

                UI::TableNextRow();
                UI::TableNextColumn();
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Rotation Randomizer should rotate about the horizontal axis (Pitch)");
                    UI::SameLine();
                }
                axisX = UI::Checkbox("X", axisX);
                if (selectedMode == RotationRandomizerMode::FIXED_STEP)
                {
                    UI::TableNextColumn();
                    stepX = Math::Clamp(UI::InputFloat("Step##X", stepX, 0.0), -180.0, 180.0);
                }
                else
                {
                    UI::TableNextColumn();
                    float newMinLimitX = UI::InputFloat("Min##X", limitsX.x, 0.0);
                    limitsX.x = Math::Clamp(newMinLimitX, -180.0, Math::Min(limitsX.y, 180.0));
                    UI::TableNextColumn();
                    float newMaxLimitX = UI::InputFloat("Max##X", limitsX.y, 0.0);
                    limitsX.y = Math::Clamp(newMaxLimitX, Math::Max(limitsX.x, -180.0), 180.0);
                }

                UI::TableNextRow();
                UI::TableNextColumn();
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Rotation Randomizer should rotate about the horizontal axis (Roll)");
                    UI::SameLine();
                }
                axisZ = UI::Checkbox("Z", axisZ);
                if (selectedMode == RotationRandomizerMode::FIXED_STEP)
                {
                    UI::TableNextColumn();
                    stepZ = Math::Clamp(UI::InputFloat("Step##Z", stepZ, 0.0), -180.0, 180.0);
                }
                else
                {
                    UI::TableNextColumn();
                    float newMinLimitZ = UI::InputFloat("Min##Z", limitsZ.x, 0.0);
                    limitsZ.x = Math::Clamp(newMinLimitZ, -180.0, Math::Min(limitsZ.y, 180.0));
                    UI::TableNextColumn();
                    float newMaxLimitZ = UI::InputFloat("Max##Z", limitsZ.y, 0.0);
                    limitsZ.y = Math::Clamp(newMaxLimitZ, Math::Max(limitsZ.x, -180.0), 180.0);
                }

                UI::EndTable();
            }

            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;

            if (prevClassicBlockCount < Editor.PluginMapType.ClassicBlocks.Length
                || prevGhostBlockCount < Compatibility::GetGhostBlocksCount(Editor)
                || prevAnchoredObjectCount < Editor.Challenge.AnchoredObjects.Length)
            {
                if (selectedMode == RotationRandomizerMode::RANDOM)
                {
                    if (axisX && Compatibility::RotationRandomizerCanBeUsed(Editor))
                    {
                        Editor.Cursor.Pitch = Math::ToRad(Math::Rand(limitsX.x, limitsX.y));
                    }

                    if (axisY)
                    {
                        float newYaw = Math::Round(Math::Rand(limitsY.x, limitsY.y) / 15.0) * 15.0;
                        CGameCursorBlock::ECardinalDirEnum newDir = GetCardinalDir(newYaw);
                        CGameCursorBlock::EAdditionalDirEnum newAddlDir = GetAdditionalDir(newYaw);
                        if (Compatibility::RotationRandomizerCanBeUsed(Editor))
                        {
                            Editor.Cursor.Dir = newDir;
                            Editor.Cursor.AdditionalDir = newAddlDir;
                        }
                        else
                        {
                            // If not using the AdditionalDir then negative CardinalDirs could exceed the min limit
                            if (newYaw < 0.0 && limitsY.x > GetMajorYawAngle(newDir))
                            {
                                newDir = GetCardinalDir(newYaw + 90.0);
                            }
                            Editor.Cursor.Dir = newDir;
                            Editor.Cursor.AdditionalDir = CGameCursorBlock::EAdditionalDirEnum::P0deg;
                        }
                    }

                    if (axisZ && Compatibility::RotationRandomizerCanBeUsed(Editor))
                    {
                        Editor.Cursor.Roll = Math::ToRad(Math::Rand(limitsZ.x, limitsZ.y));
                    }
                }
                else if (selectedMode == RotationRandomizerMode::FIXED_STEP)
                {
                    if (axisX && Compatibility::RotationRandomizerCanBeUsed(Editor))
                    {
                        float newPitchDeg = Math::ToDeg(Editor.Cursor.Pitch) + stepX;
                        if (newPitchDeg >= 180.0)
                        {
                            newPitchDeg -= 360.0;
                        }
                        else if (newPitchDeg < -180.0)
                        {
                            newPitchDeg += 360.0;
                        }
                        Editor.Cursor.Pitch = Math::ToRad(newPitchDeg);
                    }

                    if (axisY)
                    {
                        float majorYaw = GetMajorYawAngle(Editor.Cursor.Dir);
                        float minorYaw = 0.0;
                        if (Compatibility::RotationRandomizerCanBeUsed(Editor))
                        {
                            minorYaw = GetMinorYawAngle(Editor.Cursor.AdditionalDir);
                        }
                        float newYaw = majorYaw + minorYaw + stepY;
                        if (newYaw >= 180.0)
                        {
                            newYaw -= 360.0;
                        }
                        else if (newYaw < -180.0)
                        {
                            newYaw += 360.0;
                        }
                        Editor.Cursor.Dir = GetCardinalDir(newYaw);
                        if (Compatibility::RotationRandomizerCanBeUsed(Editor))
                        {
                            Editor.Cursor.AdditionalDir = GetAdditionalDir(newYaw);
                        }
                    }

                    if (axisZ && Compatibility::RotationRandomizerCanBeUsed(Editor))
                    {
                        float newRollDeg = Math::ToDeg(Editor.Cursor.Roll) + stepZ;
                        if (newRollDeg >= 180.0)
                        {
                            newRollDeg -= 360.0;
                        }
                        else if (newRollDeg < -180.0)
                        {
                            newRollDeg += 360.0;
                        }
                        Editor.Cursor.Roll = Math::ToRad(newRollDeg);
                    }
                }
            }

            prevClassicBlockCount = Editor.PluginMapType.ClassicBlocks.Length;
            prevGhostBlockCount = Compatibility::GetGhostBlocksCount(Editor);
            prevAnchoredObjectCount = Editor.Challenge.AnchoredObjects.Length;
        }

        private float ClosestValidYawAngle(float inputYaw)
        {
            return Math::Round(inputYaw / 15.0) * 15.0;
        }

        private float GetMajorYawAngle(CGameCursorBlock::ECardinalDirEnum dir)
        {
            float yawAngle = 0.0;
            if (dir == CGameCursorBlock::ECardinalDirEnum::North)
            {
                yawAngle = 0.0;
            }
            else if (dir == CGameCursorBlock::ECardinalDirEnum::East)
            {
                yawAngle = -90.0;
            }
            else if (dir == CGameCursorBlock::ECardinalDirEnum::South)
            {
                yawAngle = -180.0;
            }
            else /*if (dir == CGameCursorBlock::ECardinalDirEnum::West)*/
            {
                yawAngle = 90.0;
            }
            return yawAngle;
        }

        private float GetMinorYawAngle(CGameCursorBlock::EAdditionalDirEnum addlDir)
        {
            float yawAngle = 0.0;
            if (addlDir == CGameCursorBlock::EAdditionalDirEnum::P0deg)
            {
                yawAngle = 0.0;
            }
            else if (addlDir == CGameCursorBlock::EAdditionalDirEnum::P15deg)
            {
                yawAngle = 15.0;
            }
            else if (addlDir == CGameCursorBlock::EAdditionalDirEnum::P30deg)
            {
                yawAngle = 30.0;
            }
            else if (addlDir == CGameCursorBlock::EAdditionalDirEnum::P45deg)
            {
                yawAngle = 45.0;
            }
            else if (addlDir == CGameCursorBlock::EAdditionalDirEnum::P60deg)
            {
                yawAngle = 60.0;
            }
            else /*if (addlDir == CGameCursorBlock::EAdditionalDirEnum::P75deg)*/
            {
                yawAngle = 75.0;
            }
            return yawAngle;
        }

        private CGameCursorBlock::ECardinalDirEnum GetCardinalDir(float yawAngle)
        {
            float normalizedYawAngle = yawAngle;
            if (normalizedYawAngle >= 180.0)
            {
                normalizedYawAngle -= 360.0;
            }
            else if (normalizedYawAngle < -180.0)
            {
                normalizedYawAngle += 360.0;
            }

            CGameCursorBlock::ECardinalDirEnum dir = CGameCursorBlock::ECardinalDirEnum::North;
            if (normalizedYawAngle >= 90.0)
            {
                dir = CGameCursorBlock::ECardinalDirEnum::West;
            }
            else if (normalizedYawAngle >= 0.0)
            {
                dir = CGameCursorBlock::ECardinalDirEnum::North;
            }
            else if (normalizedYawAngle >= -90.0)
            {
                dir  = CGameCursorBlock::ECardinalDirEnum::East;
            }
            else /*if (normalizedYawAngle >= -180.0)*/
            {
                dir = CGameCursorBlock::ECardinalDirEnum::South;
            }
            return dir;
        }

        private CGameCursorBlock::EAdditionalDirEnum GetAdditionalDir(float yawAngle)
        {
            float addlYawComponent = yawAngle - GetMajorYawAngle(GetCardinalDir(yawAngle));
            CGameCursorBlock::EAdditionalDirEnum addlDir = CGameCursorBlock::EAdditionalDirEnum::P0deg;
            if (addlYawComponent <= 0.0)
            {
                addlDir = CGameCursorBlock::EAdditionalDirEnum::P0deg;
            }
            else if (addlYawComponent <= 15.0)
            {
                addlDir = CGameCursorBlock::EAdditionalDirEnum::P15deg;
            }
            else if (addlYawComponent <= 30.0)
            {
                addlDir = CGameCursorBlock::EAdditionalDirEnum::P30deg;
            }
            else if (addlYawComponent <= 45.0)
            {
                addlDir = CGameCursorBlock::EAdditionalDirEnum::P45deg;
            }
            else if (addlYawComponent <= 60.0)
            {
                addlDir = CGameCursorBlock::EAdditionalDirEnum::P60deg;
            }
            else /*if (addlYawComponent <= 75.0)*/
            {
                addlDir = CGameCursorBlock::EAdditionalDirEnum::P75deg;
            }
            return addlDir;
        }
    }
}
