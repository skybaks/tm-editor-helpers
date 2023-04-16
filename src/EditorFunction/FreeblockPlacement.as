

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
        bool Enabled_FreeblockPlacement()
        {
            return Setting_FreeblockPlacement_Enabled;
        }

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
        bool SupportsPresets() override { return true; }

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
                EditorHelpers::HelpMarker("Sets the placement grid of blocks in free mode. Does not work for numbers < 1.0");
                UI::SameLine();
            }
            Setting_FreeblockPlacement_ApplyGrid = UI::Checkbox("Apply Grid to Freeblocks", Setting_FreeblockPlacement_ApplyGrid);
            m_HStep = Math::Max(UI::InputFloat("Horizontal Grid", m_HStep), 0.0f);
            m_VStep = Math::Max(UI::InputFloat("Vertical Grid", m_VStep), 0.0f);

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Apply a placement offset to blocks in free mode. Use this place freeblocks between the 1m grid");
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

        void SerializePresets(Json::Value@ json) override
        {
            json["apply_grid"] = Setting_FreeblockPlacement_ApplyGrid;
            json["horizontal_grid"] = m_HStep;
            json["vertical_grid"] = m_VStep;
            json["apply_translation"] = Setting_FreeblockPlacement_ApplyTranslate;
            json["x_translation"] = m_XTranslate;
            json["y_translation"] = m_YTranslate;
            json["z_translation"] = m_ZTranslate;
        }

        void DeserializePresets(Json::Value@ json) override
        {
            if (bool(json.Get("enable_grid", Json::Value(true))))
            {
                Setting_FreeblockPlacement_ApplyGrid = bool(json.Get("apply_grid", Json::Value(false)));
                m_HStep = float(json.Get("horizontal_grid", Json::Value(0.0f)));
                m_VStep = float(json.Get("vertical_grid", Json::Value(0.0f)));
            }
            if (bool(json.Get("enable_translate", Json::Value(true))))
            {
                Setting_FreeblockPlacement_ApplyTranslate = bool(json.Get("apply_translation", Json::Value(false)));
                m_XTranslate = float(json.Get("x_translation", Json::Value(0.0f)));
                m_YTranslate = float(json.Get("y_translation", Json::Value(0.0f)));
                m_ZTranslate = float(json.Get("z_translation", Json::Value(0.0f)));
            }
        }

        void RenderPresetValues(Json::Value@ json) override
        {
            if (bool(json.Get("enable_grid", Json::Value(true))))
            {
                UI::Text("Apply Freeblock Grid: " + bool(json.Get("apply_grid", Json::Value(false))));
                UI::Text("Horizontal Grid: " + float(json.Get("horizontal_grid", Json::Value(0.0f))));
                UI::Text("Vertical Grid: " + float(json.Get("vertical_grid", Json::Value(0.0f))));
            }
            if (bool(json.Get("enable_translate", Json::Value(true))))
            {
                UI::Text("Apply Freeblock Translation: " + bool(json.Get("apply_translation", Json::Value(false))));
                UI::Text("X Translation: " + float(json.Get("x_translation", Json::Value(0.0f))));
                UI::Text("Y Translation: " + float(json.Get("y_translation", Json::Value(0.0f))));
                UI::Text("Z Translation: " + float(json.Get("z_translation", Json::Value(0.0f))));
            }
        }

        bool RenderPresetEnables(Json::Value@ json) override
        {
            bool changed = false;
            if (JsonCheckboxChanged(json, "enable_grid", "Freeblock Grid")) { changed = true; }
            if (JsonCheckboxChanged(json, "enable_translate", "Freeblock Translation")) { changed = true; }
            return changed;
        }
    }
}
