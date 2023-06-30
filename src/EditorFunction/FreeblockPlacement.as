

namespace EditorHelpers
{
    class FreeblockPlacementPreset : EditorFunctionPresetBase
    {
        bool EnableGrid;
        bool ApplyGrid;
        float HorizontalGrid;
        float VerticalGrid;
        bool EnableTranslate;
        bool ApplyTranslation;
        float X_Translation;
        float Y_Translation;
        float Z_Translation;

        FreeblockPlacementPreset()
        {
            super("Freeblock Placement");
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_grid"] = EnableGrid;
            m_json["apply_grid"] = ApplyGrid;
            m_json["horizontal_grid"] = HorizontalGrid;
            m_json["vertical_grid"] = VerticalGrid;
            m_json["enable_translate"] = EnableTranslate;
            m_json["apply_translation"] = ApplyTranslation;
            m_json["x_translation"] = X_Translation;
            m_json["y_translation"] = Y_Translation;
            m_json["z_translation"] = Z_Translation;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableGrid = json.Get("enable_grid", Json::Value(true));
            ApplyGrid = json.Get("apply_grid", Json::Value(false));
            HorizontalGrid = json.Get("horizontal_grid", Json::Value(0.0f));
            VerticalGrid = json.Get("vertical_grid", Json::Value(0.0f));
            EnableTranslate = json.Get("enable_translate", Json::Value(true));
            ApplyTranslation = json.Get("apply_translation", Json::Value(false));
            X_Translation = json.Get("x_translation", Json::Value(0.0f));
            Y_Translation = json.Get("y_translation", Json::Value(0.0f));
            Z_Translation = json.Get("z_translation", Json::Value(0.0f));
        }
    }

    namespace Compatibility
    {
        bool FreeblockPlacementShouldBeActive(CGameCtnEditorFree@ editor)
        {
#if TMNEXT
            return editor.Cursor.UseFreePos
                || (
                    editor.PluginMapType !is null
                    && editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item
                );
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

    class FreeblockPlacement : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
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

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_FreeblockPlacement_Enabled = UI::Checkbox("Enabled", Setting_FreeblockPlacement_Enabled);
            UI::BeginDisabled(!Setting_FreeblockPlacement_Enabled);
            UI::TextWrapped("Allows you to force blocks or macroblocks to a specific grid when placing free mode.");
            Setting_FreeblockPlacement_PersistGrid = UI::Checkbox("Persist Force Freeblock Grid selection between editor sessions", Setting_FreeblockPlacement_PersistGrid);
            Setting_FreeblockPlacement_PersistTranslate = UI::Checkbox("Persist Force Freeblock Translate selection between editor sessions", Setting_FreeblockPlacement_PersistTranslate);
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("FreeblockPlacement::Grid");
                EditorHelpers::SetHighlightId("FreeblockPlacement::Translate");
            }

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

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            UI::PushID("FreeblockPlacement::RenderInterface");

            UI::TextDisabled("\tFree Block Placement");
            EditorHelpers::BeginHighlight("FreeblockPlacement::Grid");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the placement grid of blocks in free mode. Does not work for numbers < 1.0");
                UI::SameLine();
            }
            Setting_FreeblockPlacement_ApplyGrid = UI::Checkbox("Apply Grid to Freeblocks", Setting_FreeblockPlacement_ApplyGrid);
            m_HStep = Math::Max(UI::InputFloat("Horizontal Grid", m_HStep), 0.0f);
            m_VStep = Math::Max(UI::InputFloat("Vertical Grid", m_VStep), 0.0f);
            EditorHelpers::EndHighlight();

            EditorHelpers::BeginHighlight("FreeblockPlacement::Translate");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Apply a placement offset to blocks in free mode. Use this place freeblocks between the 1m grid");
                UI::SameLine();
            }
            Setting_FreeblockPlacement_ApplyTranslate = UI::Checkbox("Apply Translation to Freeblocks", Setting_FreeblockPlacement_ApplyTranslate);
            m_XTranslate = UI::InputFloat("X Translation", m_XTranslate);
            m_YTranslate = UI::InputFloat("Y Translation", m_YTranslate);
            m_ZTranslate = UI::InputFloat("Z Translation", m_ZTranslate);
            EditorHelpers::EndHighlight();

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

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return FreeblockPlacementPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            FreeblockPlacementPreset@ preset = cast<FreeblockPlacementPreset>(data);
            if (preset is null) { return; }
            preset.ApplyGrid = Setting_FreeblockPlacement_ApplyGrid;
            preset.HorizontalGrid = m_HStep;
            preset.VerticalGrid = m_VStep;
            preset.ApplyTranslation = Setting_FreeblockPlacement_ApplyTranslate;
            preset.X_Translation = m_XTranslate;
            preset.Y_Translation = m_YTranslate;
            preset.Z_Translation = m_ZTranslate;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            FreeblockPlacementPreset@ preset = cast<FreeblockPlacementPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableGrid)
            {
                Setting_FreeblockPlacement_ApplyGrid = preset.ApplyGrid;
                m_HStep = preset.HorizontalGrid;
                m_VStep = preset.VerticalGrid;
            }
            if (preset.EnableTranslate)
            {
                Setting_FreeblockPlacement_ApplyTranslate = preset.ApplyTranslation;
                m_XTranslate = preset.X_Translation;
                m_YTranslate = preset.Y_Translation;
                m_ZTranslate = preset.Z_Translation;
            }
        }

        bool CheckPreset(EditorFunctionPresetBase@ data) override
        {
            bool areSame = true;
            if (!Enabled()) { return areSame; }
            FreeblockPlacementPreset@ preset = cast<FreeblockPlacementPreset>(data);
            if (preset is null) { return areSame; }
            if (preset.EnableGrid)
            {
                if (Setting_FreeblockPlacement_ApplyGrid != preset.ApplyGrid
                    || m_HStep != preset.HorizontalGrid
                    || m_VStep != preset.VerticalGrid) { areSame = false; }
            }
            if (preset.EnableTranslate)
            {
                if (Setting_FreeblockPlacement_ApplyTranslate != preset.ApplyTranslation
                    || m_XTranslate != preset.X_Translation
                    || m_YTranslate != preset.Y_Translation
                    || m_ZTranslate != preset.Z_Translation) { areSame = false; }
            }
            return areSame;
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            FreeblockPlacementPreset@ preset = cast<FreeblockPlacementPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableGrid)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Apply Freeblock Grid");
                UI::TableNextColumn();
                UI::Text(tostring(preset.ApplyGrid));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Horizontal Grid");
                UI::TableNextColumn();
                UI::Text(tostring(preset.HorizontalGrid));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Vertical Grid");
                UI::TableNextColumn();
                UI::Text(tostring(preset.VerticalGrid));
            }
            if (preset.EnableTranslate)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Apply Freeblock Translation");
                UI::TableNextColumn();
                UI::Text(tostring(preset.ApplyTranslation));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("X Translation");
                UI::TableNextColumn();
                UI::Text(tostring(preset.X_Translation));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Y Translation");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Y_Translation));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Z Translation");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Z_Translation));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            FreeblockPlacementPreset@ preset = cast<FreeblockPlacementPreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableGrid, preset.EnableGrid, "Freeblock Grid", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("FreeblockPlacement::Grid");
            }
            if (ForcedCheckbox(preset.EnableTranslate, preset.EnableTranslate, "Freeblock Translation", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("FreeblockPlacement::Translate");
            }
            return changed;
        }
    }
}
