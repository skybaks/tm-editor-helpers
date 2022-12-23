

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

        void GetFreemodePos(CGameCtnEditorFree@ editor, vec3&out pos)
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
            Setting_FreeblockPlacement_Enabled = false;
#endif
            return Setting_FreeblockPlacement_Enabled;
        }
    }

    namespace HotkeyInterface
    {
        void ToggleFreeblockApplyCustomGrid()
        {
            if (Setting_FreeblockPlacement_Enabled)
            {
                Setting_FreeblockPlacement_ApplyGrid = !Setting_FreeblockPlacement_ApplyGrid;
            }
        }
    }

    [Setting category="Functions" name="FreeblockPlacement: Enabled" hidden]
    bool Setting_FreeblockPlacement_Enabled = true;
    [Setting category="Functions" name="FreeblockPlacement: Persist Grid" hidden]
    bool Setting_FreeblockPlacement_PersistGrid = false;
    [Setting category="Functions" name="FreeblockPlacement: Persist Translate" hidden]
    bool Setting_FreeblockPlacement_PersistTranslate = false;

    [Setting category="Functions" hidden]
    bool Setting_FreeblockPlacement_ApplyGrid = false;
    [Setting category="Functions" hidden]
    bool Setting_FreeblockPlacement_ApplyTranslate = false;

    class FreeblockPlacement : EditorHelpers::EditorFunction
    {
        private float m_HStep;
        private float m_VStep;
        private float m_XTranslate;
        private float m_YTranslate;
        private float m_ZTranslate;
        private vec3 m_pos;
        private vec3 m_posPrev;

        string Name() override { return "Freeblock Placement"; }
        bool Enabled() override { return Compatibility::EnableFreeblockPlacementFunction(); }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_FreeblockPlacement_Enabled = UI::Checkbox("Enabled", Setting_FreeblockPlacement_Enabled);
            UI::BeginDisabled(!Setting_FreeblockPlacement_Enabled);
            UI::TextWrapped("Allows you to force blocks or macroblocks to a specific grid when placing free mode.");
            Setting_FreeblockPlacement_PersistGrid = UI::Checkbox("Persist Force Freeblock Grid selection between editor sessions", Setting_FreeblockPlacement_PersistGrid);
            Setting_FreeblockPlacement_PersistTranslate = UI::Checkbox("Persist Force Freeblock Translate selection between editor sessions", Setting_FreeblockPlacement_PersistTranslate);
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (Editor is null || !Enabled() || FirstPass)
            {
                if (!Setting_FreeblockPlacement_PersistGrid)
                {
                    Setting_FreeblockPlacement_ApplyGrid = false;
                    m_HStep = 32.0f;
                    m_VStep = 8.0f;
                }

                if (!Setting_FreeblockPlacement_PersistTranslate)
                {
                    Setting_FreeblockPlacement_ApplyTranslate = false;
                    m_XTranslate = 0.0f;
                    m_YTranslate = 0.0f;
                    m_ZTranslate = 0.0f;
                }
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
            Setting_FreeblockPlacement_ApplyGrid = UI::Checkbox("Apply Grid to Freeblocks", Setting_FreeblockPlacement_ApplyGrid);
            m_HStep = Math::Max(UI::InputFloat("Horizontal Grid", m_HStep), 0.0f);
            m_VStep = Math::Max(UI::InputFloat("Vertical Grid", m_VStep), 0.0f);

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Apply a placement offset to blocks in free mode");
                UI::SameLine();
            }
            Setting_FreeblockPlacement_ApplyTranslate = UI::Checkbox("Apply Translation to Freeblocks", Setting_FreeblockPlacement_ApplyTranslate);
            m_XTranslate = UI::InputFloat("X Translation", m_XTranslate);
            m_YTranslate = UI::InputFloat("Y Translation", m_YTranslate);
            m_ZTranslate = UI::InputFloat("Z Translation", m_ZTranslate);

            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Compatibility::FreeblockPlacementShouldBeActive(Editor))
            {
                Compatibility::GetFreemodePos(Editor, m_pos);
                if (Setting_FreeblockPlacement_ApplyGrid)
                {
                    if(m_HStep > 0.0f)
                    {
                        m_pos.x = Math::Round(m_pos.x / m_HStep) * m_HStep;
                        m_pos.z = Math::Round(m_pos.z / m_HStep) * m_HStep;
                    }
                    if (m_VStep > 0.0f)
                    {
                        m_pos.y = Math::Round(m_pos.y / m_VStep) * m_VStep;
                    }
                }

                if (Setting_FreeblockPlacement_ApplyTranslate && Math::Distance2(m_pos, m_posPrev) > 0.0001f)
                {
                    m_pos.x += m_XTranslate;
                    m_pos.y += m_YTranslate;
                    m_pos.z += m_ZTranslate;
                }
                Compatibility::SetFreemodePos(Editor, m_pos);
                m_posPrev = m_pos;
            }
        }
    }
}
