
namespace EditorHelpers
{
    namespace Setting
    {
        [Setting category="General" name="Window Visible In Editor"]
        bool WindowVisible = true;
        [Setting category="General" name="Tooltips Enabled"]
        bool ToolTipsEnabled = true;
    }

    bool hasPermission = true;

    array<EditorFunction@> functions =
    {
        Quicksave(),
        BlockHelpers()/*,
        PlacementGrid(),
        DefaultBlockMode(),
        RememberPlacementModes(),
        CustomItemPlacement(),
        FreeblockModePreciseRotation()*/
    };
}

void RenderMenu()
{
    if (!EditorHelpers::hasPermission) return;
    if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff Editor Helpers", selected: EditorHelpers::Setting::WindowVisible, enabled: GetApp().Editor !is null))
    {
        EditorHelpers::Setting::WindowVisible = !EditorHelpers::Setting::WindowVisible;
    }
}

void RenderInterface()
{
    if (!EditorHelpers::hasPermission) return;
    if (cast<CGameCtnEditorFree>(GetApp().Editor) is null || GetApp().CurrentPlayground !is null || !EditorHelpers::Setting::WindowVisible) return;
    UI::SetNextWindowSize(300, 600, UI::Cond::FirstUseEver);
    UI::Begin(Icons::PuzzlePiece + " Editor Helpers", EditorHelpers::Setting::WindowVisible);
    for (uint index = 0; index < EditorHelpers::functions.Length; index++)
    {
        EditorHelpers::functions[index].RenderInterface();
    }
    UI::End();
}

void Main()
{
    EditorHelpers::hasPermission = true;
    if (!Permissions::OpenSimpleMapEditor()
        || !Permissions::OpenAdvancedMapEditor()
        || !Permissions::CreateLocalMap())
    {
        error("Invalid permissions to run EditorHelpers plugin.");
        EditorHelpers::hasPermission = false;
    }

    int dt = 0;
    float dtSeconds = 0.0;
    int prevFrameTime = Time::Now;
    while (EditorHelpers::hasPermission)
    {
        sleep(10);
        dt = Time::Now - prevFrameTime;
        dtSeconds = dt / 1000.0f;

        EditorHelpers::tipHoverTimer.Update(dtSeconds);
        for (uint index = 0; index < EditorHelpers::functions.Length; index++)
        {
            EditorHelpers::functions[index].Init();
            EditorHelpers::functions[index].Update(dt);
            EditorHelpers::functions[index].FirstPass = false;
        }
        prevFrameTime = Time::Now;
    }
}
