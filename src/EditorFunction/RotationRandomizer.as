
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

        private uint prevClassicBlockCount = 0;
        private uint prevGhostBlockCount = 0;
        private uint prevAnchoredObjectCount = 0;

        bool Enabled() override { return Setting_RotationRandomizer_Enabled; }

        void Init() override
        {
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

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Axis for randomizer to control\nX=Pitch; Y=Yaw; Z=Roll");
                UI::SameLine();
            }
            UI::Text("Axis:");
            UI::SameLine();
            axisX = UI::Checkbox("X", axisX);
            UI::SameLine();
            axisY = UI::Checkbox("Y", axisY);
            UI::SameLine();
            axisZ = UI::Checkbox("Z", axisZ);
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
                        Editor.Cursor.Pitch = Math::ToRad(Math::Rand(-180.0, 180.0));
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
                        Editor.Cursor.Roll = Math::ToRad(Math::Rand(-180.0, 180.0));
                    }
                }
            }

            prevClassicBlockCount = Editor.PluginMapType.ClassicBlocks.Length;
            prevGhostBlockCount = Editor.PluginMapType.GhostBlocks.Length;
            prevAnchoredObjectCount = Editor.Challenge.AnchoredObjects.Length;
        }
    }
}
