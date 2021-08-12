namespace EditorHelpers
{
    class CustomItemPlacementSettings
    {
        bool Initialized = false;
        bool HasPivotPosition = false;
        float PivotX = 0.0f;
        float PivotY = 0.0f;
        float PivotZ = 0.0f;

        bool GhostMode = false;
        bool AutoRotation = false;
        float FlyStep = 0.0f;
        float FlyOffset = 0.0f;
        float HStep = 0.0f;
        float VStep = 0.0f;
        float HOffset = 0.0f;
        float VOffset = 0.0f;
    }

    [Setting category="CustomItemPlacement" name="Enabled"]
    bool settingCustomItemPlacementEnabled = true;
    [Setting category="CustomItemPlacement" name="Ghost Mode"]
    bool settingCustomItemPlacementGhostMode = false;
    [Setting category="CustomItemPlacement" name="Apply Grid"]
    bool settingCustomItemPlacementApplyGrid = false;
    [Setting category="CustomItemPlacement" name="Horizontal Grid Size"]
    float settingCustomItemPlacementHorizontalGridSize = 32.0f;
    [Setting category="CustomItemPlacement" name="Vertical Grid Size"]
    float settingCustomItemPlacementVerticalGridSize = 8.0f;
    class CustomItemPlacement : EditorHelpers::EditorFunction
    {
        private CGameItemModel@ currentItemModel = null;
        private dictionary defaultPlacement;
        private bool lastGhostMode = false;
        private bool lastApplyGrid = false;

        bool Enabled() override { return settingCustomItemPlacementEnabled; }

        void Init() override
        {
            if (Editor is null || !Enabled())
            {
                if (currentItemModel !is null)
                {
                    ResetCurrentItemPlacement();
                    @currentItemModel = null;
                }
                if (!defaultPlacement.IsEmpty())
                {
                    defaultPlacement.DeleteAll();
                }
            }
        }

        void RenderInterface() override
        {
            if (!Enabled()) return;
            UI::PushID("CustomItemPlacement::RenderInterface");
            if (UI::CollapsingHeader("Custom Item Placement"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Forces Ghost Mode on all items");
                    UI::SameLine();
                }
                settingCustomItemPlacementGhostMode = UI::Checkbox("Ghost Item Mode", settingCustomItemPlacementGhostMode);
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Forces the following placement grid on all items");
                    UI::SameLine();
                }
                settingCustomItemPlacementApplyGrid = UI::Checkbox("Apply Grid to Items", settingCustomItemPlacementApplyGrid);
                settingCustomItemPlacementHorizontalGridSize = UI::InputFloat("Horizontal Grid", settingCustomItemPlacementHorizontalGridSize);
                settingCustomItemPlacementVerticalGridSize = UI::InputFloat("Vertical Grid", settingCustomItemPlacementVerticalGridSize);
            }
            UI::PopID();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Editor.CurrentItemModel !is null)
            {
                if (Editor.CurrentItemModel !is currentItemModel)
                {
                    if (currentItemModel !is null)
                    {
                        auto prevItemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                        if (!prevItemPlacementDef.HasPivotPosition
#if TMNEXT
                            && currentItemModel.DefaultPlacementParam_Head.PivotPositions.Length > 0)
#else
                            && currentItemModel.DefaultPlacementParam_Head.Pivots_Positions.Length > 0)
#endif
                        {
                            currentItemModel.DefaultPlacementParam_Head.RemoveLastPivotPosition();
                        }
                        ResetCurrentItemPlacement();
                    }

                    auto currentItemPlacementDef = GetDefaultPlacement(Editor.CurrentItemModel.IdName);
                    if (!currentItemPlacementDef.Initialized)
                    {
                        currentItemPlacementDef.Initialized = true;
#if TMNEXT
                        uint pivotsLength = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions.Length;
#else
                        uint pivotsLength = Editor.CurrentItemModel.DefaultPlacementParam_Head.Pivots_Positions.Length;
#endif
                        currentItemPlacementDef.HasPivotPosition = pivotsLength > 0;
                        if (pivotsLength > 0)
                        {
#if TMNEXT
                            currentItemPlacementDef.PivotX = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].x;
                            currentItemPlacementDef.PivotY = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].y;
                            currentItemPlacementDef.PivotZ = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].z;
#else
                            currentItemPlacementDef.PivotX = Editor.CurrentItemModel.DefaultPlacementParam_Head.Pivots_Positions[pivotsLength - 1].x;
                            currentItemPlacementDef.PivotY = Editor.CurrentItemModel.DefaultPlacementParam_Head.Pivots_Positions[pivotsLength - 1].y;
                            currentItemPlacementDef.PivotZ = Editor.CurrentItemModel.DefaultPlacementParam_Head.Pivots_Positions[pivotsLength - 1].z;
#endif
                        }

                        currentItemPlacementDef.GhostMode = Editor.CurrentItemModel.DefaultPlacementParam_Head.GhostMode;
                        currentItemPlacementDef.AutoRotation = Editor.CurrentItemModel.DefaultPlacementParam_Head.AutoRotation;
#if TMNEXT
                        currentItemPlacementDef.FlyStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.FlyStep;
                        currentItemPlacementDef.FlyOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.FlyOffset;
#else
                        currentItemPlacementDef.FlyStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.FlyVStep;
                        currentItemPlacementDef.FlyOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.FlyVOffset;
#endif
                        currentItemPlacementDef.HStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_HStep;
                        currentItemPlacementDef.VStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_VStep;
                        currentItemPlacementDef.HOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset;
                        currentItemPlacementDef.VOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset;
                    }

#if TMNEXT
                    if (Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions.Length == 0)
#else
                    if (Editor.CurrentItemModel.DefaultPlacementParam_Head.Pivots_Positions.Length == 0)
#endif
                    {
                        Editor.CurrentItemModel.DefaultPlacementParam_Head.AddPivotPosition();
                    }
                }

                @currentItemModel = Editor.CurrentItemModel;
            }

            if (currentItemModel !is null)
            {
                if (settingCustomItemPlacementGhostMode)
                {
                    currentItemModel.DefaultPlacementParam_Head.GhostMode = true;
                }
                else if (!settingCustomItemPlacementGhostMode && lastGhostMode)
                {
                    auto currentItemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                    currentItemModel.DefaultPlacementParam_Head.GhostMode = currentItemPlacementDef.GhostMode;
                }
                lastGhostMode = settingCustomItemPlacementGhostMode;

                if (settingCustomItemPlacementApplyGrid)
                {
#if TMNEXT
                    currentItemModel.DefaultPlacementParam_Head.FlyStep = settingCustomItemPlacementVerticalGridSize;
                    currentItemModel.DefaultPlacementParam_Head.FlyOffset = 0.0f;
#else
                    currentItemModel.DefaultPlacementParam_Head.FlyVStep = settingCustomItemPlacementVerticalGridSize;
                    currentItemModel.DefaultPlacementParam_Head.FlyVOffset = 0.0f;
#endif
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HStep = settingCustomItemPlacementHorizontalGridSize;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VStep = settingCustomItemPlacementVerticalGridSize;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset = 0.0f;

#if TMNEXT
                    uint lastPivotIndex = currentItemModel.DefaultPlacementParam_Head.PivotPositions.Length-1;
                    float pivotX = currentItemModel.DefaultPlacementParam_Head.PivotPositions[lastPivotIndex].x;
                    float pivotZ = currentItemModel.DefaultPlacementParam_Head.PivotPositions[lastPivotIndex].z;
#else
                    uint lastPivotIndex = currentItemModel.DefaultPlacementParam_Head.Pivots_Positions.Length-1;
                    float pivotX = currentItemModel.DefaultPlacementParam_Head.Pivots_Positions[lastPivotIndex].x;
                    float pivotZ = currentItemModel.DefaultPlacementParam_Head.Pivots_Positions[lastPivotIndex].z;
#endif
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset = settingCustomItemPlacementHorizontalGridSize - pivotX;
                }
                else if (!settingCustomItemPlacementApplyGrid && lastApplyGrid)
                {
                    ResetCurrentItemPlacement();
                }
                lastApplyGrid = settingCustomItemPlacementApplyGrid;
            }
        }

        private CustomItemPlacementSettings@ GetDefaultPlacement(string idName)
        {
            if (!defaultPlacement.Exists(idName))
            {
                defaultPlacement[idName] = CustomItemPlacementSettings();
            }
            return cast<CustomItemPlacementSettings>(defaultPlacement[idName]);
        }

        private void ResetCurrentItemPlacement()
        {
            if (currentItemModel !is null)
            {
                auto itemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                if (itemPlacementDef.Initialized)
                {
                    currentItemModel.DefaultPlacementParam_Head.GhostMode = itemPlacementDef.GhostMode;
                    currentItemModel.DefaultPlacementParam_Head.AutoRotation = itemPlacementDef.AutoRotation;
#if TMNEXT
                    currentItemModel.DefaultPlacementParam_Head.FlyStep = itemPlacementDef.FlyStep;
                    currentItemModel.DefaultPlacementParam_Head.FlyOffset = itemPlacementDef.FlyOffset;
#else
                    currentItemModel.DefaultPlacementParam_Head.FlyVStep = itemPlacementDef.FlyStep;
                    currentItemModel.DefaultPlacementParam_Head.FlyVOffset = itemPlacementDef.FlyOffset;
#endif
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HStep = itemPlacementDef.HStep;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VStep = itemPlacementDef.VStep;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset = itemPlacementDef.HOffset;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset = itemPlacementDef.VOffset;
                    if (itemPlacementDef.HasPivotPosition)
                    {
#if TMNEXT
                        uint pivotsLength = currentItemModel.DefaultPlacementParam_Head.PivotPositions.Length;
                        currentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].x = itemPlacementDef.PivotX;
                        currentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].y = itemPlacementDef.PivotY;
                        currentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].z = itemPlacementDef.PivotZ;
#else
                        uint pivotsLength = currentItemModel.DefaultPlacementParam_Head.Pivots_Positions.Length;
                        currentItemModel.DefaultPlacementParam_Head.Pivots_Positions[pivotsLength - 1].x = itemPlacementDef.PivotX;
                        currentItemModel.DefaultPlacementParam_Head.Pivots_Positions[pivotsLength - 1].y = itemPlacementDef.PivotY;
                        currentItemModel.DefaultPlacementParam_Head.Pivots_Positions[pivotsLength - 1].z = itemPlacementDef.PivotZ;
#endif
                    }
                }
            }
        }
    }

}