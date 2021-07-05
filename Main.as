
// TODO: Features to investigate/add
// - Custom pivot points for blocks
// - more precise placement for blocks in free mode
// - remember erase mode
// - validate menu
// - set medal times
// - change map bases dynamically

bool hasPermission = true;

[Setting category="General" name="Window Visible In Editor"]
bool settingWindowVisible = true;
[Setting category="General" name="Tooltips Enabled"]
bool settingToolTipsEnabled = true;

[Setting category="Quicksave" name="Enabled"]
bool settingQuicksaveEnabled = true;
class Quicksave : EditorHelpers::EditorFunction
{
    private EditorHelpers::CountdownTimer timerQuicksave;

    bool Enabled() override { return settingQuicksaveEnabled; }

    void Init() override
    {
        if (!Enabled() || Editor is null)
        {
            timerQuicksave.MaxTime = 2.0f;
        }
    }

    void RenderInterface() override
    {
        if (!Enabled()) return;
        if (UI::CollapsingHeader("Quicksave"))
        {
            string currentFileName = Editor.PluginMapType.MapFileName;
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Save map in one click");
                UI::SameLine();
            }
            if (UI::Button("Save Map"))
            {
                if (timerQuicksave.Complete())
                {
                    if (currentFileName != "")
                    {
                        string[] mapPath = currentFileName.Split("\\");
                        string saveName = "";
                        for (uint i = 0; i < (mapPath.Length - 1); i++)
                        {
                            saveName += mapPath[i] + "\\";
                        }
                        saveName += Editor.PluginMapType.MapName + ".Map.Gbx";
                        Editor.PluginMapType.SaveMap(saveName);
                    }
                    else
                    {
                        Editor.ButtonSaveOnClick();
                    }
                    timerQuicksave.StartNew();
                }
            }
            UI::SameLine();
            UI::Text(currentFileName);
        }
    }

    void Update(float dt) override
    {
        if (!Enabled() || Editor is null) return;
        float dtSeconds = dt / 1000.0f;
        timerQuicksave.Update(dtSeconds);
    }
}

[Setting category="BlockHelpers" name="Enabled"]
bool settingBlockHelpers = true;
[Setting category="BlockHelpers" name="Block Helpers Off"]
bool settingBlockHelpersBlockHelpersOff = false;
class BlockHelpers : EditorHelpers::EditorFunction
{
    private bool lastBlockHelpersOff;

    bool Enabled() override { return settingBlockHelpers; }

    void Init() override 
    {
        if (!Enabled() || Editor is null)
        {
            lastBlockHelpersOff = false;
        }
    }

    void RenderInterface() override
    {
        if (!Enabled()) return;
        if (UI::CollapsingHeader("Block Helpers"))
        {
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Hide/Show block clip helpers");
                UI::SameLine();
            }
            settingBlockHelpersBlockHelpersOff = UI::Checkbox("Block Helpers Off", settingBlockHelpersBlockHelpersOff);
        }
    }

    void Update(float) override
    {
        if (!Enabled() || Editor is null) return;
        if (settingBlockHelpersBlockHelpersOff)
        {
            Editor.HideBlockHelpers = true;
        }
        else if (lastBlockHelpersOff && !settingBlockHelpersBlockHelpersOff)
        {
            Editor.HideBlockHelpers = false;
        }
        lastBlockHelpersOff = settingBlockHelpersBlockHelpersOff;
    }
}

[Setting category="PlacementGrid" name="Enabled"]
bool settingPlacementGridEnabled = true;
[Setting category="PlacementGrid" name="Placement Grid On"]
bool settingPlacementGridPlacementGridOn = false;
[Setting category="PlacementGrid" name="Placement Grid Transparent"]
bool settingPlacementGridPlacementGridTransparent = true;
class PlacementGrid : EditorHelpers::EditorFunction
{
    bool Enabled() override { return settingPlacementGridEnabled; }

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
            settingPlacementGridPlacementGridOn = UI::Checkbox("Placement Grid On", settingPlacementGridPlacementGridOn);
            UI::SameLine();
            settingPlacementGridPlacementGridTransparent = UI::Checkbox("Transparent", settingPlacementGridPlacementGridTransparent);
        }
    }

    void Update(float) override
    {
        if (!Enabled() || Editor is null) return;
        if (settingPlacementGridPlacementGridOn != Editor.PluginMapType.ShowPlacementGrid)
        {
            Editor.ButtonHelper1OnClick();
        }
        if (settingPlacementGridPlacementGridTransparent)
        {
            Editor.GridColorAlpha = 0.0;
        }
        else
        {
            Editor.GridColorAlpha = 0.2;
        }
    }
}

[Setting category="DefaultBlockMode" name="Enabled"]
bool settingDefaultBlockModeEnabled = true;
[Setting category="DefaultBlockMode" name="Default Block Mode"]
string settingDefaultBlockMode = "Normal";
[Setting category="DefaultBlockMode" name="Default Item Mode"]
string settingDefaultItemMode = "Normal";
[Setting category="DefaultBlockMode" name="Default Macroblock Mode"]
string settingDefaultMacroblockMode = "Normal";
class DefaultBlockMode : EditorHelpers::EditorFunction
{
    private string lastPlaceModeCategory;

    bool Enabled() override { return settingDefaultBlockModeEnabled; }

    void Init() override 
    {
        if (!Enabled() || Editor is null)
        {
            lastPlaceModeCategory = "";
        }
    }

    void RenderInterface() override
    {
        if (!Enabled()) return;
        if (UI::CollapsingHeader("Default Block Modes"))
        {
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Default when switching into block mode");
                UI::SameLine();
            }
            if (UI::BeginCombo("Block Mode", settingDefaultBlockMode))
            {
                if (UI::Selectable("Normal", false))
                {
                    settingDefaultBlockMode = "Normal";
                }
                else if (UI::Selectable("Ghost", false))
                {
                    settingDefaultBlockMode = "Ghost";
                }
                else if (UI::Selectable("Free", false))
                {
                    settingDefaultBlockMode = "Free";
                }
                UI::EndCombo();
            }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Default when switching into item mode");
                UI::SameLine();
            }
            if (UI::BeginCombo("Item Mode", settingDefaultItemMode))
            {
                if (UI::Selectable("Normal", false))
                {
                    settingDefaultItemMode = "Normal";
                }
                else if (UI::Selectable("Free Ground", false))
                {
                    settingDefaultItemMode = "Free Ground";
                }
                else if (UI::Selectable("Free", false))
                {
                    settingDefaultItemMode = "Free";
                }
                UI::EndCombo();
            }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Default when switching into macroblock mode");
                UI::SameLine();
            }
            if (UI::BeginCombo("Macroblock Mode", settingDefaultMacroblockMode))
            {
                if (UI::Selectable("Normal", false))
                {
                    settingDefaultMacroblockMode = "Normal";
                }
                else if (UI::Selectable("Free", false))
                {
                    settingDefaultMacroblockMode = "Free";
                }
                UI::EndCombo();
            }
        }
    }

    void Update(float) override
    {
        if (!Enabled() || Editor is null) return;
        string currentPlaceModeCategory = "Undefined";
        if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block
        || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::GhostBlock
        || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Unknown)
        {
            currentPlaceModeCategory = "Block";
        }
        else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
        {
            currentPlaceModeCategory = "Item";
        }
        else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock)
        {
            currentPlaceModeCategory = "Macroblock";
        }

        if (lastPlaceModeCategory != currentPlaceModeCategory)
        {

            if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block)
            {
                if (settingDefaultBlockMode == "Normal")
                {
                    Editor.ButtonNormalBlockModeOnClick();
                }
                else if (settingDefaultBlockMode == "Ghost")
                {
                    Editor.ButtonGhostBlockModeOnClick();
                }
                else if (settingDefaultBlockMode == "Free")
                {
                    Editor.ButtonFreeBlockModeOnClick();
                }
            }
            else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
            {
                if (settingDefaultItemMode == "Normal")
                {
                    Editor.ButtonNormalItemModeOnClick();
                }
                else if (settingDefaultItemMode == "Free Ground")
                {
                    Editor.ButtonFreeGroundItemModeOnClick();
                }
                else if (settingDefaultItemMode == "Free")
                {
                    Editor.ButtonFreeItemModeOnClick();
                }
            }
            else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock)
            {
                if (settingDefaultMacroblockMode == "Normal")
                {
                    Editor.ButtonNormalMacroblockModeOnClick();
                }
                else if (settingDefaultMacroblockMode == "Free")
                {
                    Editor.ButtonFreeMacroblockModeOnClick();
                }
            }
        }
        lastPlaceModeCategory = currentPlaceModeCategory;
    }
}

[Setting category="RememberPlacementModes" name="Enabled"]
bool settingRememberPlacementModesEnabled = true;
[Setting category="RememberPlacementModes" name="Maintain Block/Item Mode After Test"]
bool settingRememberPlacementModesMaintainBlockModeAfterTest = true;
[Setting category="RememberPlacementModes" name="Maintain Selection Mode"]
bool settingRememberPlacementModesMaintainSelectionMode = true;
class RememberPlacementModes : EditorHelpers::EditorFunction
{
    private string lastPlaceModeCategory;
    private CGameEditorPluginMap::EditMode lastSelectionEditMode;
    private bool lastSelectionModeAddSub;
    private string lastPlaceModeCategoryBeforeTest;

    bool Enabled() override { return settingRememberPlacementModesEnabled; }

    void Init() override 
    {
        if (!Enabled() || Editor is null)
        {
            lastPlaceModeCategory = "";
            lastSelectionEditMode = CGameEditorPluginMap::EditMode::Unknown;
            lastSelectionModeAddSub = false;
            lastPlaceModeCategoryBeforeTest = "";
        }
    }

    void RenderInterface() override
    {
        if (!Enabled()) return;
        if (UI::CollapsingHeader("Remember Placement Modes"))
        {
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Remember Block, Item, or Macroblock mode after 'Esc' from Test mode");
                UI::SameLine();
            }
            settingRememberPlacementModesMaintainBlockModeAfterTest = UI::Checkbox("Maintain Block Mode After Test", settingRememberPlacementModesMaintainBlockModeAfterTest);
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Remember selection add or remove mode while using camera");
                UI::SameLine();
            }
            settingRememberPlacementModesMaintainSelectionMode = UI::Checkbox("Maintain Copy Tool Selection Mode", settingRememberPlacementModesMaintainSelectionMode);
        }
    }

    void Update(float) override
    {
        if (!Enabled() || Editor is null) return;
        string currentPlaceModeCategory = "Undefined";
        if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Block
        || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::GhostBlock
        || Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Unknown)
        {
            currentPlaceModeCategory = "Block";
        }
        else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Item)
        {
            currentPlaceModeCategory = "Item";
        }
        else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Macroblock)
        {
            currentPlaceModeCategory = "Macroblock";
        }
        else if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Test)
        {
            currentPlaceModeCategory = "Test";
        }

        if (lastPlaceModeCategory != currentPlaceModeCategory)
        {
            if (settingRememberPlacementModesMaintainBlockModeAfterTest
            && lastPlaceModeCategory == "Test")
            {
                if (lastPlaceModeCategoryBeforeTest == "Block")
                {
                    Editor.ButtonNormalBlockModeOnClick();
                }
                else if (lastPlaceModeCategoryBeforeTest == "Item")
                {
                    Editor.ButtonNormalItemModeOnClick();
                }
                else if (lastPlaceModeCategoryBeforeTest == "Macroblock")
                {
                    Editor.ButtonNormalMacroblockModeOnClick();
                }
            }
            if (Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::Test)
            {
                lastPlaceModeCategoryBeforeTest = lastPlaceModeCategory;
            }
        }

        if (settingRememberPlacementModesMaintainSelectionMode
        && Editor.PluginMapType.PlaceMode == CGameEditorPluginMap::EPlaceMode::CopyPaste)
        {
            if (Editor.PluginMapType.EditMode == CGameEditorPluginMap::EditMode::SelectionAdd
            || Editor.PluginMapType.EditMode == CGameEditorPluginMap::EditMode::SelectionRemove)
            {
                if (!lastSelectionModeAddSub)
                {
                    if (lastSelectionEditMode == CGameEditorPluginMap::EditMode::SelectionAdd)
                    {
                        Editor.ButtonSelectionBoxAddModeOnClick();
                    }
                    else if (lastSelectionEditMode == CGameEditorPluginMap::EditMode::SelectionRemove)
                    {
                        Editor.ButtonSelectionBoxSubModeOnClick();
                    }
                }
                lastSelectionModeAddSub = true;
                lastSelectionEditMode = Editor.PluginMapType.EditMode;
            }
            else
            {
                lastSelectionModeAddSub = false;
            }
        }
        lastPlaceModeCategory = currentPlaceModeCategory;
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
                    if (!prevItemPlacementDef.HasPivotPosition && currentItemModel.DefaultPlacementParam_Head.PivotPositions.Length > 0)
                    {
                        currentItemModel.DefaultPlacementParam_Head.RemoveLastPivotPosition();
                    }
                    ResetCurrentItemPlacement();
                }

                auto currentItemPlacementDef = GetDefaultPlacement(Editor.CurrentItemModel.IdName);
                if (!currentItemPlacementDef.Initialized)
                {
                    currentItemPlacementDef.Initialized = true;
                    uint pivotsLength = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions.Length;
                    currentItemPlacementDef.HasPivotPosition = pivotsLength > 0;
                    if (pivotsLength > 0)
                    {
                        currentItemPlacementDef.PivotX = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].x;
                        currentItemPlacementDef.PivotY = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].y;
                        currentItemPlacementDef.PivotZ = Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].z;
                    }

                    currentItemPlacementDef.GhostMode = Editor.CurrentItemModel.DefaultPlacementParam_Head.GhostMode;
                    currentItemPlacementDef.AutoRotation = Editor.CurrentItemModel.DefaultPlacementParam_Head.AutoRotation;
                    currentItemPlacementDef.FlyStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.FlyStep;
                    currentItemPlacementDef.FlyOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.FlyOffset;
                    currentItemPlacementDef.HStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_HStep;
                    currentItemPlacementDef.VStep = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_VStep;
                    currentItemPlacementDef.HOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset;
                    currentItemPlacementDef.VOffset = Editor.CurrentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset;
                }

                if (Editor.CurrentItemModel.DefaultPlacementParam_Head.PivotPositions.Length == 0)
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
                currentItemModel.DefaultPlacementParam_Head.FlyStep = settingCustomItemPlacementVerticalGridSize;
                currentItemModel.DefaultPlacementParam_Head.FlyOffset = 0.0f;
                currentItemModel.DefaultPlacementParam_Head.GridSnap_HStep = settingCustomItemPlacementHorizontalGridSize;
                currentItemModel.DefaultPlacementParam_Head.GridSnap_VStep = settingCustomItemPlacementVerticalGridSize;
                currentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset = 0.0f;

                uint lastPivotIndex = currentItemModel.DefaultPlacementParam_Head.PivotPositions.Length-1;
                float pivotX = currentItemModel.DefaultPlacementParam_Head.PivotPositions[lastPivotIndex].x;
                float pivotZ = currentItemModel.DefaultPlacementParam_Head.PivotPositions[lastPivotIndex].z;
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
                currentItemModel.DefaultPlacementParam_Head.FlyStep = itemPlacementDef.FlyStep;
                currentItemModel.DefaultPlacementParam_Head.FlyOffset = itemPlacementDef.FlyOffset;
                currentItemModel.DefaultPlacementParam_Head.GridSnap_HStep = itemPlacementDef.HStep;
                currentItemModel.DefaultPlacementParam_Head.GridSnap_VStep = itemPlacementDef.VStep;
                currentItemModel.DefaultPlacementParam_Head.GridSnap_HOffset = itemPlacementDef.HOffset;
                currentItemModel.DefaultPlacementParam_Head.GridSnap_VOffset = itemPlacementDef.VOffset;
                if (itemPlacementDef.HasPivotPosition)
                {
                    uint pivotsLength = currentItemModel.DefaultPlacementParam_Head.PivotPositions.Length;
                    currentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].x = itemPlacementDef.PivotX;
                    currentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].y = itemPlacementDef.PivotY;
                    currentItemModel.DefaultPlacementParam_Head.PivotPositions[pivotsLength - 1].z = itemPlacementDef.PivotZ;
                }
            }
        }
    }
}

[Setting category="FreeblockModePreciseRotation" name="Enabled"]
bool settingsFreeblockModePreciseRotationEnabled = true;
[Setting category="FreeblockModePreciseRotation" name="Step Size"]
string settingsFreeblockModePreciseRotationStepSize = "Default";
class FreeblockModePreciseRotation : EditorHelpers::EditorFunction
{
    float inputPitch = 0.0f;
    float inputRoll = 0.0f;
    float stepSize = 1.0f;
    bool newInputToApply = false;

    bool Enabled() override { return settingsFreeblockModePreciseRotationEnabled; }

    void Init() override
    {
        if (Editor is null || !Enabled() || FirstPass)
        {
            inputPitch = 0.0f;
            inputRoll = 0.0f;
            newInputToApply = false;
            if (settingsFreeblockModePreciseRotationStepSize == "Default")
            {
                stepSize = 1.0f;
            }
            else if (settingsFreeblockModePreciseRotationStepSize == "BiSlope")
            {
                stepSize = Math::ToDeg(Math::Atan(8.0f / 32.0f));
            }
            else if (settingsFreeblockModePreciseRotationStepSize == "Slope2")
            {
                stepSize = Math::ToDeg(Math::Atan(16.0f / 32.0f));
            }
        }
    }

    void RenderInterface() override
    {
        if (!Enabled()) return;
        UI::PushID("FreeblockModePreciseRotation::RenderInterface");
        if (UI::CollapsingHeader("Freeblock Precise Rotation"))
        {
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Sets the rotational step size of the pitch and roll inputs to a game slope.");
                UI::SameLine();
            }
            if (UI::BeginCombo("Step Size", settingsFreeblockModePreciseRotationStepSize))
            {
                if (UI::Selectable("Default", false))
                {
                    stepSize = 1.0f;
                    settingsFreeblockModePreciseRotationStepSize = "Default";
                }
                else if (UI::Selectable("BiSlope", false))
                {
                    stepSize = Math::ToDeg(Math::Atan(8.0f / 32.0f));
                    settingsFreeblockModePreciseRotationStepSize = "BiSlope";
                }
                else if (UI::Selectable("Slope2", false))
                {
                    stepSize = Math::ToDeg(Math::Atan(16.0f / 32.0f));
                    settingsFreeblockModePreciseRotationStepSize = "Slope2";
                }
                UI::EndCombo();
            }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Pitch of the block in degrees. Use the +/- to increment or enter any value.");
                UI::SameLine();
            }
            float inputPitchResult = UI::InputFloat("Pitch (deg)", inputPitch, stepSize);
            if (inputPitchResult != inputPitch)
            {
                inputPitch = inputPitchResult;
                newInputToApply = true;
            }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Roll of the block in degrees. Use the +/- to increment or enter any value.");
                UI::SameLine();
            }
            float inputRollResult = UI::InputFloat("Roll (deg)", inputRoll, stepSize);
            if (inputRollResult != inputRoll)
            {
                inputRoll = inputRollResult;
                newInputToApply = true;
            }
        }
        UI::PopID();
    }

    void Update(float) override
    {
        if (!Enabled() || Editor is null) return;
        if (Editor.Cursor.UseFreePos)
        {
            if (newInputToApply)
            {
                Editor.Cursor.Pitch = Math::ToRad(inputPitch);
                Editor.Cursor.Roll = Math::ToRad(inputRoll);
                newInputToApply = false;
            }
            inputPitch = Math::ToDeg(Editor.Cursor.Pitch);
            inputRoll = Math::ToDeg(Editor.Cursor.Roll);
        }
    }
}

array<EditorHelpers::EditorFunction@> functions = 
{
    Quicksave(),
    BlockHelpers(),
    PlacementGrid(),
    DefaultBlockMode(),
    RememberPlacementModes(),
    CustomItemPlacement(),
    FreeblockModePreciseRotation()
};

void RenderMenu()
{
    if (!hasPermission) return;
    if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff Editor Helpers", selected: settingWindowVisible, enabled: GetApp().Editor !is null))
    {
        settingWindowVisible = !settingWindowVisible;
    }
}

void RenderInterface()
{
    if (!hasPermission) return;
    if (cast<CGameCtnEditorFree>(GetApp().Editor) is null || GetApp().CurrentPlayground !is null || !settingWindowVisible) return;
    UI::SetNextWindowSize(300, 600, UI::Cond::FirstUseEver);
    UI::Begin(Icons::PuzzlePiece + " Editor Helpers", settingWindowVisible);
    for (uint index = 0; index < functions.Length; index++)
    {
        functions[index].RenderInterface();
    }
    UI::End();
}

void Main()
{
    hasPermission = true;
    if (!Permissions::OpenSimpleMapEditor()
        || !Permissions::OpenAdvancedMapEditor()
        || !Permissions::CreateLocalMap())
    {
        error("Invalid permissions to run EditorHelpers plugin.");
        hasPermission = false;
    }

    int dt = 0;
    float dtSeconds = 0.0;
    int prevFrameTime = Time::Now;
    while (hasPermission)
    {
        sleep(10);
        dt = Time::Now - prevFrameTime;
        dtSeconds = dt / 1000.0f;

        EditorHelpers::tipHoverTimer.Update(dtSeconds);
        for (uint index = 0; index < functions.Length; index++)
        {
            functions[index].Init();
            functions[index].Update(dt);
            functions[index].FirstPass = false;
        }
        prevFrameTime = Time::Now;
    }
}
