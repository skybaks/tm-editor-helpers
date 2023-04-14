
[Setting category="General" name="Window Visible" hidden]
bool settingWindowVisible = true;
[Setting category="General" name="Tooltips Enabled" hidden]
bool settingToolTipsEnabled = true;
[Setting category="General" name="Debug Logging Enabled" hidden]
bool Setting_DebugLoggingEnabled = false;

const string g_windowName = Icons::PuzzlePiece + " Editor Helpers";

array<EditorHelpers::EditorFunction@> functions =
{
      EditorHelpers::EventSignals()
    , EditorHelpers::Quicksave()
    , EditorHelpers::BlockHelpers()
    , EditorHelpers::BlockCursor()
    , EditorHelpers::PlacementGrid()
    , EditorHelpers::RememberPlacementModes()
    , EditorHelpers::CustomItemPlacement()
    , EditorHelpers::FreeblockModePreciseRotation()
    , EditorHelpers::Hotkeys()
    , EditorHelpers::RotationRandomizer()
    , EditorHelpers::FreeblockPlacement()
    , EditorHelpers::DefaultBlockMode()
    , EditorHelpers::MoodChanger()
    , EditorHelpers::CameraModes()
    , EditorHelpers::CustomPalette()
    , EditorHelpers::LocatorCheck()
    , EditorHelpers::PodiumReminder()
    , EditorHelpers::CursorPosition()
    , EditorHelpers::Links()
    , EditorHelpers::FunctionPresets()
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
    if (UI::BeginMenu("\\$2f9" + Icons::PuzzlePiece + "\\$fff Editor Helpers", enabled: !Compatibility::EditorIsNull()))
    {
        if (UI::MenuItem(Icons::PuzzlePiece + " Main Window", selected: settingWindowVisible))
        {
            settingWindowVisible = !settingWindowVisible;
        }

        for (uint index = 0; index < functions.Length; index++)
        {
            functions[index].RenderInterface_MenuItem();
        }
        UI::EndMenu();
    }
}

void RenderInterface()
{
    if (!EditorHelpers::HasPermission()) return;
    if (Compatibility::EditorIsNull() || Compatibility::IsMapTesting()) return;

    if (settingWindowVisible)
    {
        UI::SetNextWindowSize(300, 600, UI::Cond::FirstUseEver);
        UI::Begin(g_windowName, settingWindowVisible);
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

    for (uint index = 0; index < functions.Length; index++)
    {
        functions[index].RenderInterface_ChildWindow();
    }
}

[SettingsTab name="Settings"]
void RenderSettingsPage()
{
    UI::PushID("GeneralSettingsPage");
    UI::Markdown("# Editor Helpers");
    settingToolTipsEnabled = UI::Checkbox("Show tooltips in the editor helpers window", settingToolTipsEnabled);
    Setting_DebugLoggingEnabled = UI::Checkbox("Enable EXTREMELY VERBOSE logging to Openplanet.log", Setting_DebugLoggingEnabled);
    UI::TextWrapped("Listed in these settings are each individual function of the editor helpers plugin. You can enable or disable each plugin individually. Disabling a function will remove any UI associated with it and stop it from operating. Turn on and off the things you want to customize your experience with this plugin.");
    UI::Dummy(vec2(20.0f, 20.0f));
    UI::PopID();

    UI::Separator();
    for (uint index = 0; index < functions.Length; index++)
    {
        if (functions[index].HasSettingsEntry())
        {
            functions[index].RenderInterface_Settings();
            UI::Dummy(vec2(10.0f, 10.0f));
            UI::Separator();
        }
    }
}

void OnKeyPress(bool down, VirtualKey key)
{
    if (!EditorHelpers::HasPermission()) return;
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
        EditorHelpers::permissionReduceSpamTimer.Update(dtSeconds);
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
