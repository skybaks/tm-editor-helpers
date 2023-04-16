
namespace EditorHelpers
{
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

    class PlacementGrid : EditorHelpers::EditorFunction
    {
        string Name() override { return "Placement Grid"; }
        bool Enabled() override { return Setting_PlacementGrid_Enabled; }
        bool SupportsPresets() override { return true; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_PlacementGrid_Enabled = UI::Checkbox("Enabled", Setting_PlacementGrid_Enabled);
            UI::BeginDisabled(!Setting_PlacementGrid_Enabled);
            UI::TextWrapped("Enables forcing on the editor's placement grid, also know as 'helpers'. Normally you would need to turn this on each time you enter the editor but with this function the plugin can do that for you. Additionally, there is an option to make the grid a transparent wireframe which can be quite helpful for building in free block mode and off grid.");
            Setting_PlacementGrid_PlacementGridOn = UI::Checkbox("Force the placement grid on", Setting_PlacementGrid_PlacementGridOn);
            Setting_PlacementGrid_PlacementGridTransparent = UI::Checkbox("Make the placement grid transparent", Setting_PlacementGrid_PlacementGridTransparent);
            UI::EndDisabled();
            UI::PopID();
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Display the horizontal block grid");
                UI::SameLine();
            }
            Setting_PlacementGrid_PlacementGridOn = UI::Checkbox("Placement Grid On", Setting_PlacementGrid_PlacementGridOn);
            UI::SameLine();
            Setting_PlacementGrid_PlacementGridTransparent = UI::Checkbox("Transparent", Setting_PlacementGrid_PlacementGridTransparent);
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
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

        void SerializePresets(Json::Value@ json) override
        {
            json["grid_on"] = Setting_PlacementGrid_PlacementGridOn;
            json["transparent"] = Setting_PlacementGrid_PlacementGridTransparent;
        }

        void DeserializePresets(Json::Value@ json) override
        {
            if (bool(json.Get("enable_grid_on", Json::Value(true))))
            {
                Setting_PlacementGrid_PlacementGridOn = bool(json.Get("grid_on", Json::Value(false)));
            }
            if (bool(json.Get("enable_grid_transparent", Json::Value(true))))
            {
                Setting_PlacementGrid_PlacementGridTransparent = bool(json.Get("transparent", Json::Value(false)));
            }
        }

        void RenderPresetValues(Json::Value@ json) override
        {
            if (bool(json.Get("enable_grid_on", Json::Value(true))))
            {
                UI::Text("Placement Grid On: " + bool(json.Get("grid_on", Json::Value(false))));
            }
            if (bool(json.Get("enable_grid_transparent", Json::Value(true))))
            {
                UI::Text("Placement Grid Transparent: " + bool(json.Get("transparent", Json::Value(false))));
            }
        }

        bool RenderPresetEnables(Json::Value@ json) override
        {
            //json["enable_grid_on"] = UI::Checkbox("Grid On", bool(json.Get("enable_grid_on", Json::Value(true))));
            //json["enable_grid_transparent"] = UI::Checkbox("Grid Transparent", bool(json.Get("enable_grid_transparent", Json::Value(true))));
            bool changed = false;
            if (JsonCheckboxChanged(json, "enable_grid_on", "Grid On")) { changed = true; }
            if (JsonCheckboxChanged(json, "enable_grid_transparent", "Grid Transparent")) { changed = true; }
            return changed;
        }
    }
}