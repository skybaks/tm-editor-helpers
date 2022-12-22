
#if TMNEXT

namespace EditorHelpers
{
    namespace Compatibility
    {
        bool FreeblockPlacementShouldBeActive(CGameCtnEditorFree@ editor)
        {
            return editor.Cursor.UseFreePos || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item;
        }
    }

    namespace HotkeyInterface
    {
        void ToggleFreeblockApplyCustomGrid()
        {
            if (Settings_FreeblockPlacement_Enabled)
            {
                Settings_FreeblockPlacement_ApplyGrid = !Settings_FreeblockPlacement_ApplyGrid;
            }
        }
    }

    [Setting category="Functions" name="FreeblockPlacement: Enabled" hidden]
    bool Settings_FreeblockPlacement_Enabled = true;
    [Setting category="Functions" hidden]
    bool Settings_FreeblockPlacement_ApplyGrid = false;

    class FreeblockPlacement : EditorHelpers::EditorFunction
    {
        private float m_HStep;
        private float m_VStep;

        string Name() override { return "Freeblock Placement"; }
        bool Enabled() override { return Settings_FreeblockPlacement_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Settings_FreeblockPlacement_Enabled = UI::Checkbox("Enabled", Settings_FreeblockPlacement_Enabled);
            UI::BeginDisabled(!Settings_FreeblockPlacement_Enabled);
            UI::TextWrapped("Allows you to force blocks or macroblocks to a specific grid when placing free mode.");
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (Editor is null || !Enabled() || FirstPass)
            {
                m_HStep = 32.0f;
                m_VStep = 8.0f;
            }
        }

        void RenderInterface_Build() override
        {
            if (!Enabled()) return;

            UI::PushID("FreeblockPlacement::RenderInterface");

            UI::TextDisabled("\tFree Block Placement");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the placement grid of blocks in free mode");
                UI::SameLine();
            }
            Settings_FreeblockPlacement_ApplyGrid = UI::Checkbox("Apply Grid to Freeblocks", Settings_FreeblockPlacement_ApplyGrid);
            m_HStep = Math::Max(UI::InputFloat("Horizontal Grid", m_HStep), 0.0f);
            m_VStep = Math::Max(UI::InputFloat("Vertical Grid", m_VStep), 0.0f);

            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Compatibility::FreeblockPlacementShouldBeActive(Editor) && Settings_FreeblockPlacement_ApplyGrid)
            {
                if(m_HStep > 0.0f)
                {
                    Editor.Cursor.FreePosInMap.x = Math::Round(Editor.Cursor.FreePosInMap.x / m_HStep) * m_HStep;
                    Editor.Cursor.FreePosInMap.z = Math::Round(Editor.Cursor.FreePosInMap.z / m_HStep) * m_HStep;
                }
                if (m_VStep > 0.0f)
                {
                    Editor.Cursor.FreePosInMap.y = Math::Round(Editor.Cursor.FreePosInMap.y / m_VStep) * m_VStep;
                }
            }
        }
    }
}

#endif
