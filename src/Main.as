
[Setting category="General" name="Window Visible In Editor"]
bool settingWindowVisible = true;
[Setting category="General" name="Tooltips Enabled"]
bool settingToolTipsEnabled = true;

array<EditorHelpers::EditorFunction@> functions =
{
      EditorHelpers::Quicksave()
    , EditorHelpers::BlockHelpers()
    , EditorHelpers::BlockCursor()
    , EditorHelpers::PlacementGrid()
    , EditorHelpers::DefaultBlockMode()
    , EditorHelpers::RememberPlacementModes()
    , EditorHelpers::CustomItemPlacement()
    , EditorHelpers::FreeblockModePreciseRotation()
    , EditorHelpers::Hotkeys()
    , EditorHelpers::RotationRandomizer()
#if TMNEXT
    , EditorHelpers::FreeblockModePreciseTranslation()
#endif
    , EditorHelpers::MoodChanger()
    , EditorHelpers::CameraModes()
    , EditorHelpers::LocatorCheck()
    , EditorHelpers::RouteDebug()
};

namespace Compatibility
{
    bool EditorIsNull()
    {
        return cast<CGameCtnEditorFree>(GetApp().Editor) is null;
    }

    bool IsMapTesting()
    {
#if TMNEXT
        return GetApp().CurrentPlayground !is null;
#else
        CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return editor !is null && editor.PluginMapType.IsSwitchedToPlayground;
#endif
    }
}

void RenderMenu()
{
    if (!EditorHelpers::HasPermission()) return;
    if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff Editor Helpers", selected: settingWindowVisible, enabled: GetApp().Editor !is null))
    {
        settingWindowVisible = !settingWindowVisible;
    }
}

void RenderInterface()
{
    if (!EditorHelpers::HasPermission()) return;
    if (Compatibility::EditorIsNull() || Compatibility::IsMapTesting() || !settingWindowVisible) return;
    UI::SetNextWindowSize(300, 600, UI::Cond::FirstUseEver);
    UI::Begin(Icons::PuzzlePiece + " Editor Helpers", settingWindowVisible);

    if (UI::CollapsingHeader("Action"))
    {
        for (uint index = 0; index < functions.Length; index++)
        {
            functions[index].RenderInterface_Action();
        }
    }

    if (UI::CollapsingHeader("Display"))
    {
        for (uint index = 0; index < functions.Length; index++)
        {
            functions[index].RenderInterface_Display();
        }
    }

    if (UI::CollapsingHeader("Build"))
    {
        for (uint index = 0; index < functions.Length; index++)
        {
            functions[index].RenderInterface_Build();
        }
    }

    if (UI::CollapsingHeader("Info"))
    {
        for (uint index = 0; index < functions.Length; index++)
        {
            functions[index].RenderInterface_Info();
        }
    }
    UI::End();
}

void Render()
{
    if (!EditorHelpers::HasPermission()) return;
    if (Compatibility::EditorIsNull() || Compatibility::IsMapTesting() || !settingWindowVisible) return;

    for (uint index = 0; index < functions.Length; index++)
    {
        functions[index].RenderDrawing();
    }
}

void OnKeyPress(bool down, VirtualKey key)
{
    if (!EditorHelpers::HasPermission()) return;
    if (Compatibility::EditorIsNull() || Compatibility::IsMapTesting() || !settingWindowVisible) return;
    for (uint index = 0; index < functions.Length; index++)
    {
        functions[index].OnKeyPress(down, key);
    }
}

void Main()
{
    int dt = 0;
    float dtSeconds = 0.0;
    int prevFrameTime = Time::Now;
    while (true)
    {
        sleep(10);
        dt = Time::Now - prevFrameTime;
        dtSeconds = dt / 1000.0f;

        EditorHelpers::tipHoverTimer.Update(dtSeconds);
        if (EditorHelpers::HasPermission())
        {
            for (uint index = 0; index < functions.Length; index++)
            {
                functions[index].Init();
                functions[index].Update(dt);
                functions[index].FirstPass = false;
            }
        }
        prevFrameTime = Time::Now;
    }
}
