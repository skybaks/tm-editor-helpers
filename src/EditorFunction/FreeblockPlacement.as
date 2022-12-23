

namespace EditorHelpers
{
    namespace Compatibility
    {
        bool FreeblockPlacementShouldBeActive(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            return editor.Cursor.UseFreePos || editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item;
#else
            return false;
#endif
        }

        void GetFreemodePos(CGameCtnEditorFree@ editor, const vec3&out pos)
        {
#if TMNEXT
            pos = editor.Cursor.FreePosInMap;
#endif
        }

        void SetFreemodePos(CGameCtnEditorFree@ editor, const vec3&in pos)
        {
#if TMNEXT
            editor.Cursor.FreePosInMap = pos;
#endif
        }

        bool EnableFreeblockPlacementFunction()
        {
#if TMNEXT
#else
            Settings_FreeblockPlacement_Enabled = false;
#endif
            return Settings_FreeblockPlacement_Enabled;
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
        private vec3 m_pos;

        string Name() override { return "Freeblock Placement"; }
        bool Enabled() override { return Compatibility::EnableFreeblockPlacementFunction(); }

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
                Compatibility::GetFreemodePos(Editor, m_pos);
                if(m_HStep > 0.0f)
                {
                    m_pos.x = Math::Round(m_pos.x / m_HStep) * m_HStep;
                    m_pos.z = Math::Round(m_pos.z / m_HStep) * m_HStep;
                }
                if (m_VStep > 0.0f)
                {
                    m_pos.y = Math::Round(m_pos.y / m_VStep) * m_VStep;
                }
                Compatibility::SetFreemodePos(Editor, m_pos);
            }
        }
    }
}
