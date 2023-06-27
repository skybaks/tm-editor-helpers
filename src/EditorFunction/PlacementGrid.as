
namespace EditorHelpers
{
    class PlacementGridPreset : EditorFunctionPresetBase
    {
        bool EnableGridOn;
        bool GridOn;
        bool EnableGridTransparent;
        bool Transparent;

        PlacementGridPreset()
        {
            super("Placement Grid");
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_grid_on"] = EnableGridOn;
            m_json["grid_on"] = GridOn;
            m_json["enable_grid_transparent"] = EnableGridTransparent;
            m_json["transparent"] = Transparent;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableGridOn = json.Get("enable_grid_on", Json::Value(true));
            GridOn = json.Get("grid_on", Json::Value(false));
            EnableGridTransparent = json.Get("enable_grid_transparent", Json::Value(true));
            Transparent = json.Get("transparent", Json::Value(false));
        }
    }

    namespace HotkeyInterface
    {
        bool Enabled_PlacementGrid()
        {
            return Setting_PlacementGrid_Enabled;
        }

        void TogglePlacementGridOn()
        {
            if (Setting_PlacementGrid_Enabled)
            {
                Setting_PlacementGrid_PlacementGridOn = !Setting_PlacementGrid_PlacementGridOn;
            }
        }

        void TogglePlacementGridTransparent()
        {
            if (Setting_PlacementGrid_Enabled)
            {
                Setting_PlacementGrid_PlacementGridTransparent = !Setting_PlacementGrid_PlacementGridTransparent;
            }
        }
    }

    [Setting category="Functions" name="PlacementGrid: Enabled" hidden]
    bool Setting_PlacementGrid_Enabled = true;
    [Setting category="Functions" name="PlacementGrid: Placement Grid On" hidden]
    bool Setting_PlacementGrid_PlacementGridOn = false;
    [Setting category="Functions" name="PlacementGrid: Placement Grid Transparent" hidden]
    bool Setting_PlacementGrid_PlacementGridTransparent = true;

    class PlacementGrid : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
    {
        string Name() override { return "Placement Grid"; }
        bool Enabled() override { return Setting_PlacementGrid_Enabled; }

        private bool m_functionalityDisabled = false;

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_PlacementGrid_Enabled = UI::Checkbox("Enabled", Setting_PlacementGrid_Enabled);
            UI::BeginDisabled(!Setting_PlacementGrid_Enabled);
            UI::TextWrapped("Enables forcing on the editor's placement grid, also know as 'helpers'. Normally you"
                " would need to turn this on each time you enter the editor but with this function the plugin can do"
                " that for you. Additionally, there is an option to make the grid a transparent wireframe which can"
                " be quite helpful for building in free block mode and off grid.");
            Setting_PlacementGrid_PlacementGridOn = UI::Checkbox("Force the placement grid on", Setting_PlacementGrid_PlacementGridOn);
            Setting_PlacementGrid_PlacementGridTransparent = UI::Checkbox("Make the placement grid transparent", Setting_PlacementGrid_PlacementGridTransparent);
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("PlacementGrid::GridOn");
                EditorHelpers::SetHighlightId("PlacementGrid::Transparent");
            }

            UI::PopID();
        }

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            UI::BeginDisabled(m_functionalityDisabled);
            EditorHelpers::BeginHighlight("PlacementGrid::GridOn");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Display the horizontal block grid");
                UI::SameLine();
            }
            Setting_PlacementGrid_PlacementGridOn = UI::Checkbox("Placement Grid On", Setting_PlacementGrid_PlacementGridOn);
            EditorHelpers::EndHighlight();

            UI::SameLine();
            EditorHelpers::BeginHighlight("PlacementGrid::Transparent");
            Setting_PlacementGrid_PlacementGridTransparent = UI::Checkbox("Transparent", Setting_PlacementGrid_PlacementGridTransparent);
            EditorHelpers::EndHighlight();
            UI::EndDisabled();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null || Editor.PluginMapType is null)
            {
                m_functionalityDisabled = true;
                return;
            }
            else
            {
                m_functionalityDisabled = false;
            }

            if (Setting_PlacementGrid_PlacementGridOn != Editor.PluginMapType.ShowPlacementGrid)
            {
                Editor.ButtonHelper1OnClick();
            }
            if (Setting_PlacementGrid_PlacementGridTransparent)
            {
                Editor.GridColorAlpha = 0.0;
            }
            else
            {
                Editor.GridColorAlpha = 0.2;
            }
        }

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return PlacementGridPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            PlacementGridPreset@ preset = cast<PlacementGridPreset>(data);
            if (preset is null) { return; }
            preset.GridOn = Setting_PlacementGrid_PlacementGridOn;
            preset.Transparent = Setting_PlacementGrid_PlacementGridTransparent;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            PlacementGridPreset@ preset = cast<PlacementGridPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableGridOn)
            {
                Setting_PlacementGrid_PlacementGridOn = preset.GridOn;
            }
            if (preset.EnableGridTransparent)
            {
                Setting_PlacementGrid_PlacementGridTransparent = preset.Transparent;
            }
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            PlacementGridPreset@ preset = cast<PlacementGridPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableGridOn)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Placement Grid On");
                UI::TableNextColumn();
                UI::Text(tostring(preset.GridOn));
            }
            if (preset.EnableGridTransparent)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Placement Grid Transparent");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Transparent));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            PlacementGridPreset@ preset = cast<PlacementGridPreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableGridOn, preset.EnableGridOn, "Grid On", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("PlacementGrid::GridOn");
            }
            if (ForcedCheckbox(preset.EnableGridTransparent, preset.EnableGridTransparent, "Grid Transparent", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("PlacementGrid::Transparent");
            }
            return changed;
        }
    }
}