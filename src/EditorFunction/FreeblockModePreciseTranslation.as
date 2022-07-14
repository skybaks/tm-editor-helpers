
#if TMNEXT
namespace EditorHelpers
{
    namespace Compatibility
    {
        bool FreeblockModePreciseTranslationShouldBeActive(CGameCtnEditorFree@ editor)
        {
            return editor.Cursor.UseFreePos || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item;
        }
    }

    [Setting category="Functions" name="FreeblockModePreciseTranslation: Enabled" description="Uncheck to disable all plugin functions related to Block Precise Rotation"]
    bool Settings_FreeblockModePreciseTranslation_Enabled = true;
    [Setting category="Functions" hidden]
    bool Settings_FreeblockModePreciseTranslation_ApplyTranslation = false;

    class FreeblockModePreciseTranslation : EditorHelpers::EditorFunction
    {
        vec3 translation;
        vec3 prevPosInMap;


        bool Enabled() override { return Settings_FreeblockModePreciseTranslation_Enabled; }

        void Init() override
        {
            if (Editor is null || !Enabled() || FirstPass)
            {
                translation.x = 0.0f;
                translation.y = 0.0f;
                translation.z = 0.0f;
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled()) return;

            UI::PushID("FreeblockModePreciseTranslation::RenderInterface");

            UI::TextDisabled("\tTranslation");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the translation offset when in free block mode.");
                UI::SameLine();
            }
            Settings_FreeblockModePreciseTranslation_ApplyTranslation = UI::Checkbox("Apply Custom Translation", Settings_FreeblockModePreciseTranslation_ApplyTranslation);
            translation.x = UI::InputFloat("Translation x", translation.x,0.1);
            translation.y = UI::InputFloat("Translation y", translation.y,0.1);
            translation.z = UI::InputFloat("Translation z", translation.z,0.1);

            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Compatibility::FreeblockModePreciseTranslationShouldBeActive(Editor) && Settings_FreeblockModePreciseTranslation_ApplyTranslation)
            {
                if(Math::Distance2(Editor.Cursor.FreePosInMap,prevPosInMap) > 0.0001)
                {
                    Editor.Cursor.FreePosInMap += translation;
                    prevPosInMap = Editor.Cursor.FreePosInMap;  
                }
            }
        }
    }
}
#endif