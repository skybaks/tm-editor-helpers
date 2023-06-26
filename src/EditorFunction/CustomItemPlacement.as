namespace EditorHelpers
{
    class CustomItemPlacementPreset : EditorFunctionPresetBase
    {
        bool EnableGhostMode;
        bool GhostMode;
        bool EnableAutorotation;
        bool Autorotation;
        bool EnableItemGrid;
        bool ApplyGrid;
        float GridHorizontal;
        float GridVertical;
        bool EnableItemPivot;
        bool ApplyPivot;
        float PivotX;
        float PivotY;
        float PivotZ;

        CustomItemPlacementPreset()
        {
            super("Custom Item Placement");
        }

        Json::Value@ ToJson() const override
        {
            m_json["enable_ghost_mode"] = EnableGhostMode;
            m_json["ghost_mode"] = GhostMode;
            m_json["enable_autorotation"] = EnableAutorotation;
            m_json["autorotation"] = Autorotation;
            m_json["enable_item_grid"] = EnableItemGrid;
            m_json["apply_grid"] = ApplyGrid;
            m_json["grid_horiz"] = GridHorizontal;
            m_json["grid_verti"] = GridVertical;
            m_json["enable_item_pivot"] = EnableItemPivot;
            m_json["apply_pivot"] = ApplyPivot;
            m_json["pivot_x"] = PivotX;
            m_json["pivot_y"] = PivotY;
            m_json["pivot_z"] = PivotZ;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableGhostMode = json.Get("enable_ghost_mode", Json::Value(true));
            GhostMode = json.Get("ghost_mode", Json::Value(false));
            EnableAutorotation = json.Get("enable_autorotation", Json::Value(true));
            Autorotation = json.Get("autorotation", Json::Value(false));
            EnableItemGrid = json.Get("enable_item_grid", Json::Value(true));
            ApplyGrid = json.Get("apply_grid", Json::Value(false));
            GridHorizontal = json.Get("grid_horiz", Json::Value(0.0f));
            GridVertical = json.Get("grid_verti", Json::Value(0.0f));
            EnableItemPivot = json.Get("enable_item_pivot", Json::Value(true));
            ApplyPivot = json.Get("apply_pivot", Json::Value(false));
            PivotX = json.Get("pivot_x", Json::Value(0.0f));
            PivotY = json.Get("pivot_y", Json::Value(0.0f));
            PivotZ = json.Get("pivot_z", Json::Value(0.0f));
        }
    }

    namespace Compatibility
    {
        uint GetPivotPositionsLength(CGameItemPlacementParam@ placementParams)
        {
#if TMNEXT
            return placementParams.PivotPositions.Length;
#else
            return placementParams.Pivots_Positions.Length;
#endif
        }

        float GetPivotPositionsX(CGameItemPlacementParam@ placementParams, uint index)
        {
#if TMNEXT
            return placementParams.PivotPositions[index].x;
#else
            return placementParams.Pivots_Positions[index].x;
#endif
        }

        float GetPivotPositionsY(CGameItemPlacementParam@ placementParams, uint index)
        {
#if TMNEXT
            return placementParams.PivotPositions[index].y;
#else
            return placementParams.Pivots_Positions[index].y;
#endif
        }

        float GetPivotPositionsZ(CGameItemPlacementParam@ placementParams, uint index)
        {
#if TMNEXT
            return placementParams.PivotPositions[index].z;
#else
            return placementParams.Pivots_Positions[index].z;
#endif
        }

        float GetFlyStep(CGameItemPlacementParam@ placementParams)
        {
#if TMNEXT
            return placementParams.FlyStep;
#else
            return placementParams.FlyVStep;
#endif
        }

        float GetFlyOffset(CGameItemPlacementParam@ placementParams)
        {
#if TMNEXT
            return placementParams.FlyOffset;
#else
            return placementParams.FlyVOffset;
#endif
        }

        void SetPivotPositionsX(CGameItemPlacementParam@ placementParams, uint index, float setValue)
        {
#if TMNEXT
            placementParams.PivotPositions[index].x = setValue;
#else
            placementParams.Pivots_Positions[index].x = setValue;
#endif
        }

        void SetPivotPositionsY(CGameItemPlacementParam@ placementParams, uint index, float setValue)
        {
#if TMNEXT
            placementParams.PivotPositions[index].y = setValue;
#else
            placementParams.Pivots_Positions[index].y = setValue;
#endif
        }

        void SetPivotPositionsZ(CGameItemPlacementParam@ placementParams, uint index, float setValue)
        {
#if TMNEXT
            placementParams.PivotPositions[index].z = setValue;
#else
            placementParams.Pivots_Positions[index].z = setValue;
#endif
        }

        void SetFlyStep(CGameItemPlacementParam@ placementParams, float setValue)
        {
#if TMNEXT
            placementParams.FlyStep = setValue;
#else
            placementParams.FlyVStep = setValue;
#endif
        }

        void SetFlyOffset(CGameItemPlacementParam@ placementParams, float setValue)
        {
#if TMNEXT
            placementParams.FlyOffset = setValue;
#else
            placementParams.FlyVOffset = setValue;
#endif
        }
    }

    namespace HotkeyInterface
    {
        bool Enabled_CustomItemPlacement()
        {
            return Setting_CustomItemPlacement_Enabled;
        }

        void ToggleCustomItemApplyGhost()
        {
            if (Setting_CustomItemPlacement_Enabled)
            {
                Setting_CustomItemPlacement_ApplyGhost = !Setting_CustomItemPlacement_ApplyGhost;
            }
        }

        void ToggleCustomItemApplyAutoRotation()
        {
            if (Setting_CustomItemPlacement_Enabled)
            {
                Setting_CustomItemPlacement_ApplyAutoRotation = !Setting_CustomItemPlacement_ApplyAutoRotation;
            }
        }

        void ToggleCustomItemApplyGrid()
        {
            if (Setting_CustomItemPlacement_Enabled)
            {
                Setting_CustomItemPlacement_ApplyGrid = !Setting_CustomItemPlacement_ApplyGrid;
            }
        }

        void ToggleCustomItemApplyPivot()
        {
            if (Setting_CustomItemPlacement_Enabled)
            {
                Setting_CustomItemPlacement_ApplyPivot = !Setting_CustomItemPlacement_ApplyPivot;
            }
        }
    }

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

    [Setting category="Functions" name="CustomItemPlacement: Enabled" hidden]
    bool Setting_CustomItemPlacement_Enabled = true;
    [Setting category="Functions" name="CustomItemPlacement: Persist Ghost Mode" hidden]
    bool Setting_CustomItemPlacement_PersistGhost = false;
    [Setting category="Functions" name="CustomItemPlacement: Persist Item Grid" hidden]
    bool Setting_CustomItemPlacement_PersistGrid = false;
    [Setting category="Functions" name="CustomItemPlacement: Persist Item Pivot" hidden]
    bool Setting_CustomItemPlacement_PersistPivot = false;

    [Setting category="Functions" hidden]
    bool Setting_CustomItemPlacement_ApplyGhost = false;
    [Setting category="Functions" hidden]
    bool Setting_CustomItemPlacement_ApplyAutoRotation = false;
    [Setting category="Functions" hidden]
    bool Setting_CustomItemPlacement_ApplyGrid = false;
    [Setting category="Functions" hidden]
    float Setting_CustomItemPlacement_GridSizeHoriz = 32.0f;
    [Setting category="Functions" hidden]
    float Setting_CustomItemPlacement_GridSizeVerti = 8.0f;
    [Setting category="Functions" hidden]
    bool Setting_CustomItemPlacement_ApplyPivot = false;
    [Setting category="Functions" hidden]
    vec3 Setting_CustomItemPlacement_ItemPivot = vec3(0,0,0);

    class CustomItemPlacement : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
    {
        private CGameItemModel@ currentItemModel = null;
        private dictionary defaultPlacement;
        private bool lastGhostMode = false;
        private bool lastAutoRotation = false;
        private bool lastApplyGrid = false;
        private bool lastApplyPivot = false;

        string Name() override { return "Custom Item Placement"; }
        bool Enabled() override { return Setting_CustomItemPlacement_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_CustomItemPlacement_Enabled = UI::Checkbox("Enabled", Setting_CustomItemPlacement_Enabled);
            UI::BeginDisabled(!Setting_CustomItemPlacement_Enabled);
            UI::TextWrapped("Provides the ability to modify aspects of item placement on the fly. This includes"
                " changing an item's placement grid, changing an item's primary pivot point, and/or forcing ghost"
                " mode on the item.");
            Setting_CustomItemPlacement_PersistGhost = UI::Checkbox("Persist Force Item Ghost Mode selection between editor sessions", Setting_CustomItemPlacement_PersistGhost);
            Setting_CustomItemPlacement_PersistGrid = UI::Checkbox("Persist Force Item Grid selection between editor sessions", Setting_CustomItemPlacement_PersistGrid);
            Setting_CustomItemPlacement_PersistPivot = UI::Checkbox("Persist Force Item Pivot selection between editor sessions", Setting_CustomItemPlacement_PersistPivot);
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CustomItemPlacement::GhostMode");
                EditorHelpers::SetHighlightId("CustomItemPlacement::Autorotation");
                EditorHelpers::SetHighlightId("CustomItemPlacement::ItemGrid");
                EditorHelpers::SetHighlightId("CustomItemPlacement::ItemPivot");
            }

            UI::PopID();
        }

        void Init() override
        {
            if (Editor is null || !Enabled())
            {
                lastGhostMode = false;
                lastAutoRotation = false;
                lastApplyGrid = false;
                lastApplyPivot = false;

                if (!Setting_CustomItemPlacement_PersistGhost)
                {
                    Setting_CustomItemPlacement_ApplyGhost = false;
                }

                Setting_CustomItemPlacement_ApplyAutoRotation = false;

                if (!Setting_CustomItemPlacement_PersistGrid)
                {
                    Setting_CustomItemPlacement_ApplyGrid = false;
                    Setting_CustomItemPlacement_GridSizeHoriz = 32.0f;
                    Setting_CustomItemPlacement_GridSizeVerti = 8.0f;
                }

                if (!Setting_CustomItemPlacement_PersistPivot)
                {
                    Setting_CustomItemPlacement_ApplyPivot = false;
                    Setting_CustomItemPlacement_ItemPivot = vec3(0,0,0);
                }

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

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            UI::PushID("CustomItemPlacement::RenderInterface");

            EditorHelpers::BeginHighlight("CustomItemPlacement::GhostMode");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Forces Ghost Mode on all items");
                UI::SameLine();
            }
            Setting_CustomItemPlacement_ApplyGhost = UI::Checkbox("Ghost Item Mode", Setting_CustomItemPlacement_ApplyGhost);
            EditorHelpers::EndHighlight();

            EditorHelpers::BeginHighlight("CustomItemPlacement::Autorotation");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Activate AutoRotation for the current item. Also forces placement grid to <0, 0> so autorotation can operate.");
                UI::SameLine();
            }
            Setting_CustomItemPlacement_ApplyAutoRotation = UI::Checkbox("Item AutoRotation", Setting_CustomItemPlacement_ApplyAutoRotation);
            EditorHelpers::EndHighlight();

            UI::TextDisabled("\tItem Placement");
            EditorHelpers::BeginHighlight("CustomItemPlacement::ItemGrid");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Forces the following placement grid on all items");
                UI::SameLine();
            }
            Setting_CustomItemPlacement_ApplyGrid = UI::Checkbox("Apply Grid to Items", Setting_CustomItemPlacement_ApplyGrid);
            Setting_CustomItemPlacement_GridSizeHoriz = UI::InputFloat("Horizontal Grid", Setting_CustomItemPlacement_GridSizeHoriz);
            Setting_CustomItemPlacement_GridSizeVerti = UI::InputFloat("Vertical Grid", Setting_CustomItemPlacement_GridSizeVerti);
            EditorHelpers::EndHighlight();

            UI::TextDisabled("\tItem Pivot");
            EditorHelpers::BeginHighlight("CustomItemPlacement::ItemPivot");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Advanced manipulation of item pivot");
                UI::SameLine();
            }
            Setting_CustomItemPlacement_ApplyPivot = UI::Checkbox("Apply Custom Pivot", Setting_CustomItemPlacement_ApplyPivot);
            Setting_CustomItemPlacement_ItemPivot.x = UI::InputFloat("Pivot X", Setting_CustomItemPlacement_ItemPivot.x);
            Setting_CustomItemPlacement_ItemPivot.y = UI::InputFloat("Pivot Y", Setting_CustomItemPlacement_ItemPivot.y);
            Setting_CustomItemPlacement_ItemPivot.z = UI::InputFloat("Pivot Z", Setting_CustomItemPlacement_ItemPivot.z);
            EditorHelpers::EndHighlight();

            UI::PopID();
        }

        void Update(float) override
        {
            Debug_EnterMethod("Update");

            if (!Enabled() || Editor is null)
            {
                Debug_LeaveMethod();
                return;
            }

            if (Editor.CurrentItemModel !is null)
            {
                if (Editor.CurrentItemModel !is currentItemModel)
                {
                    Debug("New item model is selected");

                    if (currentItemModel !is null)
                    {
                        Debug("Performing cleanup on previous item model");

                        ResetCurrentItemPivot();

                        auto prevItemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                        if (prevItemPlacementDef.Initialized
                            && !prevItemPlacementDef.HasPivotPosition
                            && Compatibility::GetPivotPositionsLength(currentItemModel.DefaultPlacementParam_Head) > 0)
                        {
                            Debug("Removing pivot position since item didnt have it originally");

                            currentItemModel.DefaultPlacementParam_Head.RemoveLastPivotPosition();
                        }
                        ResetCurrentItemPlacement();
                    }

                    auto currentItemPlacementDef = GetDefaultPlacement(Editor.CurrentItemModel.IdName);
                    if (!currentItemPlacementDef.Initialized)
                    {
                        Debug("Placement not initialized for id = " + tostring(Editor.CurrentItemModel.IdName));

                        currentItemPlacementDef.Initialized = true;
                        uint pivotsLength = Compatibility::GetPivotPositionsLength(Editor.CurrentItemModel.DefaultPlacementParam_Head);
                        currentItemPlacementDef.HasPivotPosition = pivotsLength > 0;
                        if (pivotsLength > 0)
                        {
                            currentItemPlacementDef.PivotX = Compatibility::GetPivotPositionsX(Editor.CurrentItemModel.DefaultPlacementParam_Head, pivotsLength - 1);
                            currentItemPlacementDef.PivotY = Compatibility::GetPivotPositionsY(Editor.CurrentItemModel.DefaultPlacementParam_Head, pivotsLength - 1);
                            currentItemPlacementDef.PivotZ = Compatibility::GetPivotPositionsZ(Editor.CurrentItemModel.DefaultPlacementParam_Head, pivotsLength - 1);
                        }

                        currentItemPlacementDef.GhostMode = Editor.CurrentItemModel.DefaultPlacementParam_Head.GhostMode;
                        currentItemPlacementDef.AutoRotation = Editor.CurrentItemModel.DefaultPlacementParam_Head.AutoRotation;
                        currentItemPlacementDef.FlyStep = Compatibility::GetFlyStep(Editor.CurrentItemModel.DefaultPlacementParam_Head);
                        currentItemPlacementDef.FlyOffset = Compatibility::GetFlyOffset(Editor.CurrentItemModel.DefaultPlacementParam_Head);
                        currentItemPlacementDef.HStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_HStep;
                        currentItemPlacementDef.VStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_VStep;
                        currentItemPlacementDef.HOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset;
                        currentItemPlacementDef.VOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset;
                    }

                    if (Compatibility::GetPivotPositionsLength(Editor.CurrentItemModel.DefaultPlacementParam_Head) == 0)
                    {
                        Debug("No pivot positions, adding one so we can change it if desired");
                        Editor.CurrentItemModel.DefaultPlacementParam_Head.AddPivotPosition();
                    }

                    if (!Setting_CustomItemPlacement_ApplyPivot)
                    {
                        Debug("Putting pivot back to item defaults due to setting not enabled");
                        Setting_CustomItemPlacement_ItemPivot.x = currentItemPlacementDef.PivotX;
                        Setting_CustomItemPlacement_ItemPivot.y = currentItemPlacementDef.PivotY;
                        Setting_CustomItemPlacement_ItemPivot.z = currentItemPlacementDef.PivotZ;
                    }
                }

                @currentItemModel = Editor.CurrentItemModel;
            }

            if (currentItemModel !is null)
            {
                if (Setting_CustomItemPlacement_ApplyGhost)
                {
                    currentItemModel.DefaultPlacementParam_Head.GhostMode = true;
                }
                else if (!Setting_CustomItemPlacement_ApplyGhost && lastGhostMode)
                {
                    auto currentItemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                    currentItemModel.DefaultPlacementParam_Head.GhostMode = currentItemPlacementDef.GhostMode;
                }
                lastGhostMode = Setting_CustomItemPlacement_ApplyGhost;

                if (Setting_CustomItemPlacement_ApplyAutoRotation && !lastAutoRotation)
                {
                    currentItemModel.DefaultPlacementParam_Head.AutoRotation = true;
                    Setting_CustomItemPlacement_ApplyGrid = true;
                    Setting_CustomItemPlacement_GridSizeHoriz = 0.0f;
                    Setting_CustomItemPlacement_GridSizeVerti = 0.0f;
                }
                else if (!Setting_CustomItemPlacement_ApplyAutoRotation && lastAutoRotation)
                {
                    auto currentItemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                    currentItemModel.DefaultPlacementParam_Head.AutoRotation = currentItemPlacementDef.AutoRotation;
                }
                lastAutoRotation = Setting_CustomItemPlacement_ApplyAutoRotation;

                if (Setting_CustomItemPlacement_ApplyGrid)
                {
                    Compatibility::SetFlyStep(currentItemModel.DefaultPlacementParam_Head, Setting_CustomItemPlacement_GridSizeVerti);
                    Compatibility::SetFlyOffset(currentItemModel.DefaultPlacementParam_Head, 0.0f);
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HStep = Setting_CustomItemPlacement_GridSizeHoriz;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VStep = Setting_CustomItemPlacement_GridSizeVerti;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset = 0.0f;

                    uint lastPivotIndex = Compatibility::GetPivotPositionsLength(currentItemModel.DefaultPlacementParam_Head)-1;
                    float pivotX = Compatibility::GetPivotPositionsX(currentItemModel.DefaultPlacementParam_Head, lastPivotIndex);
                    float pivotZ = Compatibility::GetPivotPositionsZ(currentItemModel.DefaultPlacementParam_Head, lastPivotIndex);
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset = Setting_CustomItemPlacement_GridSizeHoriz - pivotX;
                }
                else if (!Setting_CustomItemPlacement_ApplyGrid && lastApplyGrid)
                {
                    ResetCurrentItemPlacement();
                }
                lastApplyGrid = Setting_CustomItemPlacement_ApplyGrid;

                if (Setting_CustomItemPlacement_ApplyPivot)
                {
                    uint lastPivotIndex = Compatibility::GetPivotPositionsLength(currentItemModel.DefaultPlacementParam_Head)-1;
                    Compatibility::SetPivotPositionsX(currentItemModel.DefaultPlacementParam_Head, lastPivotIndex, Setting_CustomItemPlacement_ItemPivot.x);
                    Compatibility::SetPivotPositionsY(currentItemModel.DefaultPlacementParam_Head, lastPivotIndex, Setting_CustomItemPlacement_ItemPivot.y);
                    Compatibility::SetPivotPositionsZ(currentItemModel.DefaultPlacementParam_Head, lastPivotIndex, Setting_CustomItemPlacement_ItemPivot.z);
                }
                else if (!Setting_CustomItemPlacement_ApplyPivot && lastApplyPivot)
                {
                    ResetCurrentItemPivot();
                }
                lastApplyPivot = Setting_CustomItemPlacement_ApplyPivot;
            }

            Debug_LeaveMethod();
        }

        private CustomItemPlacementSettings@ GetDefaultPlacement(const string &in idName)
        {
            Debug_EnterMethod("GetDefaultPlacement");

            Debug("Accessing default placement for id name = " + tostring(idName));

            if (!defaultPlacement.Exists(idName))
            {
                Debug("Placement settings do not exist, creating...");
                defaultPlacement[idName] = CustomItemPlacementSettings();
            }

            Debug_LeaveMethod();

            return cast<CustomItemPlacementSettings>(defaultPlacement[idName]);
        }

        private void ResetCurrentItemPlacement()
        {
            Debug_EnterMethod("ResetCurrentItemPlacement");

            if (currentItemModel !is null)
            {
                Debug("currentItemModel is not null");

                auto itemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                if (itemPlacementDef.Initialized)
                {
                    Debug("itemPlacementDef is Initialized");

                    currentItemModel.DefaultPlacementParam_Head.GhostMode = itemPlacementDef.GhostMode;
                    currentItemModel.DefaultPlacementParam_Head.AutoRotation = itemPlacementDef.AutoRotation;
                    Compatibility::SetFlyStep(currentItemModel.DefaultPlacementParam_Head, itemPlacementDef.FlyStep);
                    Compatibility::SetFlyOffset(currentItemModel.DefaultPlacementParam_Head, itemPlacementDef.FlyOffset);
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HStep = itemPlacementDef.HStep;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VStep = itemPlacementDef.VStep;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset = itemPlacementDef.HOffset;
                    currentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset = itemPlacementDef.VOffset;
                }
            }

            Debug_LeaveMethod();
        }

        private void ResetCurrentItemPivot()
        {
            Debug_EnterMethod("ResetCurrentItemPivot");

            if (currentItemModel !is null)
            {
                Debug("currentItemModel is not null");

                auto itemPlacementDef = GetDefaultPlacement(currentItemModel.IdName);
                if (itemPlacementDef.Initialized)
                {
                    Debug("itemPlacementDef is Initialized");

                    uint pivotsLength = Compatibility::GetPivotPositionsLength(currentItemModel.DefaultPlacementParam_Head);
                    Debug("pivotsLength = " + tostring(pivotsLength));
                    if (pivotsLength > 0)
                    {
                        Compatibility::SetPivotPositionsX(currentItemModel.DefaultPlacementParam_Head, pivotsLength - 1, itemPlacementDef.PivotX);
                        Compatibility::SetPivotPositionsY(currentItemModel.DefaultPlacementParam_Head, pivotsLength - 1, itemPlacementDef.PivotY);
                        Compatibility::SetPivotPositionsZ(currentItemModel.DefaultPlacementParam_Head, pivotsLength - 1, itemPlacementDef.PivotZ);
                    }

                    if (!Setting_CustomItemPlacement_ApplyPivot)
                    {
                        Debug("Putting pivot back to item default due to setting not enabled");

                        Setting_CustomItemPlacement_ItemPivot.x = itemPlacementDef.PivotX;
                        Setting_CustomItemPlacement_ItemPivot.y = itemPlacementDef.PivotY;
                        Setting_CustomItemPlacement_ItemPivot.z = itemPlacementDef.PivotZ;
                    }
                }
            }

            Debug_LeaveMethod();
        }

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return CustomItemPlacementPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            CustomItemPlacementPreset@ preset = cast<CustomItemPlacementPreset>(data);
            if (preset is null) { return; }
            preset.GhostMode = Setting_CustomItemPlacement_ApplyGhost;
            preset.Autorotation = Setting_CustomItemPlacement_ApplyAutoRotation;
            preset.ApplyGrid = Setting_CustomItemPlacement_ApplyGrid;
            preset.GridHorizontal = Setting_CustomItemPlacement_GridSizeHoriz;
            preset.GridVertical = Setting_CustomItemPlacement_GridSizeVerti;
            preset.ApplyPivot = Setting_CustomItemPlacement_ApplyPivot;
            preset.PivotX = Setting_CustomItemPlacement_ItemPivot.x;
            preset.PivotY = Setting_CustomItemPlacement_ItemPivot.y;
            preset.PivotZ = Setting_CustomItemPlacement_ItemPivot.z;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            CustomItemPlacementPreset@ preset = cast<CustomItemPlacementPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableGhostMode)
            {
                Setting_CustomItemPlacement_ApplyGhost = preset.GhostMode;
            }
            if (preset.EnableAutorotation)
            {
                Setting_CustomItemPlacement_ApplyAutoRotation = preset.Autorotation;
            }
            if (preset.EnableItemGrid)
            {
                Setting_CustomItemPlacement_ApplyGrid = preset.ApplyGrid;
                Setting_CustomItemPlacement_GridSizeHoriz = preset.GridHorizontal;
                Setting_CustomItemPlacement_GridSizeVerti = preset.GridVertical;
            }
            if (preset.EnableItemPivot)
            {
                Setting_CustomItemPlacement_ApplyPivot = preset.ApplyPivot;
                Setting_CustomItemPlacement_ItemPivot.x = preset.PivotX;
                Setting_CustomItemPlacement_ItemPivot.y = preset.PivotY;
                Setting_CustomItemPlacement_ItemPivot.z = preset.PivotZ;
            }
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            CustomItemPlacementPreset@ preset = cast<CustomItemPlacementPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableGhostMode)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Apply Ghost Mode");
                UI::TableNextColumn();
                UI::Text(tostring(preset.GhostMode));
            }
            if (preset.EnableAutorotation)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Apply Autorotation");
                UI::TableNextColumn();
                UI::Text(tostring(preset.Autorotation));
            }
            if (preset.EnableItemGrid)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Apply Item Grid");
                UI::TableNextColumn();
                UI::Text(tostring(preset.ApplyGrid));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Grid Horizontal");
                UI::TableNextColumn();
                UI::Text(tostring(preset.GridHorizontal));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Grid Vertical");
                UI::TableNextColumn();
                UI::Text(tostring(preset.GridVertical));
            }
            if (preset.EnableItemPivot)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Apply Item Pivot");
                UI::TableNextColumn();
                UI::Text(tostring(preset.ApplyPivot));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Pivot X");
                UI::TableNextColumn();
                UI::Text(tostring(preset.PivotX));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Pivot Y");
                UI::TableNextColumn();
                UI::Text(tostring(preset.PivotY));

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Pivot Z");
                UI::TableNextColumn();
                UI::Text(tostring(preset.PivotZ));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue)
        {
            if (!Enabled()) { return false; }
            CustomItemPlacementPreset@ preset = cast<CustomItemPlacementPreset>(data);
            if (preset is null) { return false; }
            bool changed = false;
            if (ForcedCheckbox(preset.EnableGhostMode, preset.EnableGhostMode, "Ghost Mode", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CustomItemPlacement::GhostMode");
            }
            if (ForcedCheckbox(preset.EnableAutorotation, preset.EnableAutorotation, "Autorotation", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CustomItemPlacement::Autorotation");
            }
            if (ForcedCheckbox(preset.EnableItemGrid, preset.EnableItemGrid, "Item Grid", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CustomItemPlacement::ItemGrid");
            }
            if (ForcedCheckbox(preset.EnableItemPivot, preset.EnableItemPivot, "Item Pivot", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("CustomItemPlacement::ItemPivot");
            }
            return changed;
        }
    }
}