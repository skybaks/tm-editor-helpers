
namespace EditorHelpers
{
    [Setting category="Functions" name="PlacementGrid: Enabled" description="Uncheck to disable plugin function for helpers grid"]
    bool Setting_PlacementGrid_Enabled = true;
    [Setting category="Functions" name="PlacementGrid: Placement Grid On"]
    bool Setting_PlacementGrid_PlacementGridOn = false;
    [Setting category="Functions" name="PlacementGrid: Placement Grid Transparent"]
    bool Setting_PlacementGrid_PlacementGridTransparent = true;
    class PlacementGrid : EditorHelpers::EditorFunction
    {
        bool Enabled() override { return Setting_PlacementGrid_Enabled; }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            if (UI::CollapsingHeader("Placement Grid"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Display the horizontal block grid");
                    UI::SameLine();
                }
                Setting_PlacementGrid_PlacementGridOn = UI::Checkbox("Placement Grid On", Setting_PlacementGrid_PlacementGridOn);
                UI::SameLine();
                Setting_PlacementGrid_PlacementGridTransparent = UI::Checkbox("Transparent", Setting_PlacementGrid_PlacementGridTransparent);
            }
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
    }
}