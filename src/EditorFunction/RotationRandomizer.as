
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
    }

    [Setting category="function" name="RotationRandomizer: Enabled" description="Uncheck to disable all plugin functions related to the Rotation Randomizer"]
    bool Setting_RotationRandomizer_Enabled = true;

    class RotationRandomizer : EditorHelpers::EditorFunction
    {
        private bool randomizerEnabled = false;
        private bool axisX = false;
        private bool axisY = false;
        private bool axisZ = false;
        private vec2 limitsX = vec2(-180.0, 180.0);
        private vec2 limitsZ = vec2(-180.0, 180.0);

        private uint prevClassicBlockCount = 0;
        private uint prevGhostBlockCount = 0;
        private uint prevAnchoredObjectCount = 0;

        bool Enabled() override { return Setting_RotationRandomizer_Enabled; }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                randomizerEnabled = false;
                limitsX = vec2(-180.0, 180.0);
                limitsZ = vec2(-180.0, 180.0);
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled()) return;
            UI::PushID("RotationRandomizer::RenderInterface_Build");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Randomize rotation after click");
                UI::SameLine();
            }
            randomizerEnabled = UI::Checkbox("Enable Rotation Randomizer", randomizerEnabled);

            if (UI::BeginTable("RotationRandomizerAxisTable", 3))
            {
                UI::TableSetupColumn("Axis", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 65.0);
                UI::TableSetupColumn("Min", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 95.0);
                UI::TableSetupColumn("Max", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 95.0);

                UI::TableNextRow();
                UI::TableNextColumn();
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Rotation Randomizer should rotate about the vertical axis (Yaw).");
                    UI::SameLine();
                }
                axisY = UI::Checkbox("Y", axisY);

                UI::TableNextRow();
                UI::TableNextColumn();
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Rotation Randomizer should rotate about the horizontal axis (Pitch).\n"
                        + "Limit the randomized range on this axis using Min/Max");
                    UI::SameLine();
                }
                axisX = UI::Checkbox("X", axisX);
                UI::TableNextColumn();
                float newMinLimitX = UI::InputFloat("Min##X", limitsX.x, 0.0);
                limitsX.x = Math::Clamp(newMinLimitX, -180.0, Math::Min(limitsX.y, 180.0));
                UI::TableNextColumn();
                float newMaxLimitX = UI::InputFloat("Max##X", limitsX.y, 0.0);
                limitsX.y = Math::Clamp(newMaxLimitX, Math::Max(limitsX.x, -180.0), 180.0);

                UI::TableNextRow();
                UI::TableNextColumn();
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Rotation Randomizer should rotate about the horizontal axis (Roll)."
                        + "\nLimit the randomized range on this axis using Min/Max");
                    UI::SameLine();
                }
                axisZ = UI::Checkbox("Z", axisZ);
                UI::TableNextColumn();
                float newMinLimitZ = UI::InputFloat("Min##Z", limitsZ.x, 0.0);
                limitsZ.x = Math::Clamp(newMinLimitZ, -180.0, Math::Min(limitsZ.y, 180.0));
                UI::TableNextColumn();
                float newMaxLimitZ = UI::InputFloat("Max##Z", limitsZ.y, 0.0);
                limitsZ.y = Math::Clamp(newMaxLimitZ, Math::Max(limitsZ.x, -180.0), 180.0);

                UI::EndTable();
            }

            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;

            if (prevClassicBlockCount < Editor.PluginMapType.ClassicBlocks.Length
                || prevGhostBlockCount < Editor.PluginMapType.GhostBlocks.Length
                || prevAnchoredObjectCount < Editor.Challenge.AnchoredObjects.Length)
            {
                if (randomizerEnabled)
                {
                    if (axisX && Compatibility::RotationRandomizerCanBeUsed(Editor))
                    {
                        Editor.Cursor.Pitch = Math::ToRad(Math::Rand(limitsX.x, limitsX.y));
                    }

                    if (axisY)
                    {
                        Editor.Cursor.Dir = CGameCursorBlock::ECardinalDirEnum(Math::Rand(0, 4));

                        if (Compatibility::RotationRandomizerCanBeUsed(Editor))
                        {
                            Editor.Cursor.AdditionalDir = CGameCursorBlock::EAdditionalDirEnum(Math::Rand(0, 6));
                        }
                    }

                    if (axisZ && Compatibility::RotationRandomizerCanBeUsed(Editor))
                    {
                        Editor.Cursor.Roll = Math::ToRad(Math::Rand(limitsZ.x, limitsZ.y));
                    }
                }
            }

            prevClassicBlockCount = Editor.PluginMapType.ClassicBlocks.Length;
            prevGhostBlockCount = Editor.PluginMapType.GhostBlocks.Length;
            prevAnchoredObjectCount = Editor.Challenge.AnchoredObjects.Length;
        }
    }
}
