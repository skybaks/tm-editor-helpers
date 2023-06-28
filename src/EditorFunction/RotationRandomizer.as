
namespace EditorHelpers
{
    class RotationRandomizerPreset : EditorFunctionPresetBase
    {
        bool EnableRandomizerMode;
        string RandomizerMode;
        bool EnableAxes;
        bool AxisX;
        bool AxisY;
        bool AxisZ;
        bool EnableAxisLimits;
        float Y_LimitMin;
        float Y_LimitMax;
        float X_LimitMin;
        float X_LimitMax;
        float Z_LimitMin;
        float Z_LimitMax;
        bool EnableAxisSteps;
        float StepY;
        float StepX;
        float StepZ;

        RotationRandomizerPreset()
        {
            super("Rotation Randomizer");
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_randomizer_mode"] = EnableRandomizerMode;
            m_json["randomizer_mode"] = RandomizerMode;
            m_json["enable_axes"] = EnableAxes;
            m_json["axis_x"] = AxisX;
            m_json["axis_y"] = AxisY;
            m_json["axis_z"] = AxisZ;
            m_json["enable_axis_limits"] = EnableAxisLimits;
            m_json["y_lim_min"] = Y_LimitMin;
            m_json["y_lim_max"] = Y_LimitMax;
            m_json["x_lim_min"] = X_LimitMin;
            m_json["x_lim_max"] = X_LimitMax;
            m_json["z_lim_min"] = Z_LimitMin;
            m_json["z_lim_max"] = Z_LimitMax;
            m_json["enable_axis_steps"] = EnableAxisSteps;
            m_json["step_y"] = StepY;
            m_json["step_x"] = StepX;
            m_json["step_z"] = StepZ;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableRandomizerMode = json.Get("enable_randomizer_mode", Json::Value(true));
            RandomizerMode = json.Get("randomizer_mode", Json::Value("OFF"));
            EnableAxes = json.Get("enable_axes", Json::Value(true));
            AxisX = json.Get("axis_x", Json::Value(false));
            AxisY = json.Get("axis_y", Json::Value(false));
            AxisZ = json.Get("axis_z", Json::Value(false));
            EnableAxisLimits = json.Get("enable_axis_limits", Json::Value(true));
            Y_LimitMin = json.Get("y_lim_min", Json::Value(0.0f));
            Y_LimitMax = json.Get("y_lim_max", Json::Value(0.0f));
            X_LimitMin = json.Get("x_lim_min", Json::Value(0.0f));
            X_LimitMax = json.Get("x_lim_max", Json::Value(0.0f));
            Z_LimitMin = json.Get("z_lim_min", Json::Value(0.0f));
            Z_LimitMax = json.Get("z_lim_max", Json::Value(0.0f));
            EnableAxisSteps = json.Get("enable_axis_steps", Json::Value(true));
            StepY = json.Get("step_y", Json::Value(0.0f));
            StepX = json.Get("step_x", Json::Value(0.0f));
            StepZ = json.Get("step_z", Json::Value(0.0f));
        }
    }

    namespace Compatibility
    {
        bool RotationRandomizerCanBeUsed(CGameCtnEditorFree@ editor)
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
    }

    enum RotationRandomizerMode
    {
        OFF = 0,
        RANDOM = 1,
        FIXED_STEP = 2
    }

    [Setting category="Functions" name="RotationRandomizer: Enabled" hidden]
    bool Setting_RotationRandomizer_Enabled = true;

    class RotationRandomizer : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
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

        string Name() override { return "Rotation Randomizer"; }
        bool Enabled() override { return Setting_RotationRandomizer_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_RotationRandomizer_Enabled = UI::Checkbox("Enabled", Setting_RotationRandomizer_Enabled);
            UI::BeginDisabled(!Setting_RotationRandomizer_Enabled);
            UI::TextWrapped("Provides an interface which allows you to activate and customize the limits of the"
                " rotation randomizer. When the randomizer is turned on a random rotation within the defined limits"
                " will be chosen for each selected axis after you place a block or item.");
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("RotationRandomizer::Mode");
                EditorHelpers::SetHighlightId("RotationRandomizer::AxesLimitsSteps");
            }

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

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;
            UI::PushID("RotationRandomizer::RenderInterface_MainWindow");

            EditorHelpers::BeginHighlight("RotationRandomizer::Mode");
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
            EditorHelpers::EndHighlight();

            EditorHelpers::BeginHighlight("RotationRandomizer::AxesLimitsSteps");
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
            EditorHelpers::EndHighlight();

            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;

            if (Signal_BlockItemPlaced())
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

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return RotationRandomizerPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            RotationRandomizerPreset@ preset = cast<RotationRandomizerPreset>(data);
            if (preset is null) { return; }
            preset.RandomizerMode = tostring(selectedMode);
            preset.AxisX = axisX;
            preset.AxisY = axisY;
            preset.AxisZ = axisZ;
            preset.Y_LimitMin = limitsY.x;
            preset.Y_LimitMax = limitsY.y;
            preset.X_LimitMin = limitsX.x;
            preset.X_LimitMax = limitsX.y;
            preset.Z_LimitMin = limitsZ.x;
            preset.Z_LimitMax = limitsZ.y;
            preset.StepY = stepY;
            preset.StepX = stepX;
            preset.StepZ = stepZ;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            RotationRandomizerPreset@ preset = cast<RotationRandomizerPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableRandomizerMode)
            {
                if (preset.RandomizerMode == "RANDOM")
                {
                    selectedMode = RotationRandomizerMode::RANDOM;
                }
                else if (preset.RandomizerMode == "FIXED_STEP")
                {
                    selectedMode = RotationRandomizerMode::FIXED_STEP;
                }
                else
                {
                    selectedMode = RotationRandomizerMode::OFF;
                }
            }
            if (preset.EnableAxes)
            {
                axisX = preset.AxisX;
                axisY = preset.AxisY;
                axisZ = preset.AxisZ;
            }
            if (preset.EnableAxisLimits)
            {
                limitsY.x = preset.Y_LimitMin;
                limitsY.y = preset.Y_LimitMax;
                limitsX.x = preset.X_LimitMin;
                limitsX.y = preset.X_LimitMax;
                limitsZ.x = preset.Z_LimitMin;
                limitsZ.y = preset.Z_LimitMax;
            }
            if (preset.EnableAxisSteps)
            {
                stepY = preset.StepY;
                stepX = preset.StepX;
                stepZ = preset.StepZ;
            }
        }

        bool CheckPreset(EditorFunctionPresetBase@ data) override
        {
            bool areSame = true;
            if (!Enabled()) { return areSame; }
            RotationRandomizerPreset@ preset = cast<RotationRandomizerPreset>(data);
            if (preset is null) { return areSame; }
            if (preset.EnableRandomizerMode)
            {
                if (!((preset.RandomizerMode == "RANDOM" && selectedMode == RotationRandomizerMode::RANDOM)
                    || (preset.RandomizerMode == "FIXED_STEP" && selectedMode == RotationRandomizerMode::FIXED_STEP)
                    || (preset.RandomizerMode == "OFF" && selectedMode == RotationRandomizerMode::OFF)))
                {
                    areSame = false;
                }
            }
            if (preset.EnableAxes)
            {
                if (axisX != preset.AxisX
                    || axisY != preset.AxisY
                    || axisZ != preset.AxisZ) { areSame = false; }
            }
            if (preset.EnableAxisLimits)
            {
                if (limitsY.x != preset.Y_LimitMin
                    || limitsY.y != preset.Y_LimitMax
                    || limitsX.x != preset.X_LimitMin
                    || limitsX.y != preset.X_LimitMax
                    || limitsZ.x != preset.Z_LimitMin
                    || limitsZ.y != preset.Z_LimitMax) { areSame = false; }
            }
            if (preset.EnableAxisSteps)
            {
                if (stepY != preset.StepY
                    || stepX != preset.StepX
                    || stepZ != preset.StepZ) { areSame = false; }
            }
            return areSame;
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            RotationRandomizerPreset@ preset = cast<RotationRandomizerPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableRandomizerMode)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Randomizer Mode");
                UI::TableNextColumn();
                UI::Text(preset.RandomizerMode);
            }
            if (preset.EnableAxes)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Enable X Axis");
                UI::TableNextColumn();
                UI::Text(tostring(preset.AxisX));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Enable Y Axis");
                UI::TableNextColumn();
                UI::Text(tostring(preset.AxisY));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Enable Z Axis");
                UI::TableNextColumn();
                UI::Text(tostring(preset.AxisZ));
            }
            if (preset.EnableAxisLimits)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Y Limit (Min)");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Y_LimitMin));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Y Limit (Max)");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Y_LimitMax));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("X Limit (Min)");
                UI::TableNextColumn();
                UI::Text(tostring(preset.X_LimitMin));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("X Limit (Max)");
                UI::TableNextColumn();
                UI::Text(tostring(preset.X_LimitMax));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Z Limit (Min)");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Z_LimitMin));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Z Limit (Max)");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Z_LimitMax));
            }
            if (preset.EnableAxisSteps)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Step Y");
                UI::TableNextColumn();
                UI::Text(tostring(preset.StepY));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Step X");
                UI::TableNextColumn();
                UI::Text(tostring(preset.StepX));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Step Z");
                UI::TableNextColumn();
                UI::Text(tostring(preset.StepZ));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            RotationRandomizerPreset@ preset = cast<RotationRandomizerPreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableRandomizerMode, preset.EnableRandomizerMode, "Randomizer Mode", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("RotationRandomizer::Mode");
            }
            if (ForcedCheckbox(preset.EnableAxes, preset.EnableAxes, "Enable Axes", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("RotationRandomizer::AxesLimitsSteps");
            }
            if (ForcedCheckbox(preset.EnableAxisLimits, preset.EnableAxisLimits, "Axis Limits", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("RotationRandomizer::AxesLimitsSteps");
            }
            if (ForcedCheckbox(preset.EnableAxisSteps, preset.EnableAxisSteps, "Axis Steps", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("RotationRandomizer::AxesLimitsSteps");
            }
            return changed;
        }
    }
}
