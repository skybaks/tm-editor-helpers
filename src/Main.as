
[Setting category="General" name="Window Visible" hidden]
bool Setting_WindowVisible = true;
[Setting category="General" name="Tooltips Enabled" hidden]
bool settingToolTipsEnabled = true;
[Setting category="General" name="Debug Logging Enabled" hidden]
bool Setting_DebugLoggingEnabled = false;

const string g_windowName = Icons::PuzzlePiece + " Editor Helpers";

array<EditorHelpers::EditorFunction@> g_functionsNone =
{
      EditorHelpers::EventSignals()
    , EditorHelpers::RememberPlacementModes()
    , EditorHelpers::EditorInventory()
};
array<EditorHelpers::EditorFunction@> g_functionsAction =
{
      EditorHelpers::Quicksave()
    , EditorHelpers::Hotkeys()
    , EditorHelpers::FunctionPresets()
};
array<EditorHelpers::EditorFunction@> g_functionsDisplay =
{
      EditorHelpers::BlockHelpers()
    , EditorHelpers::BlockCursor()
    , EditorHelpers::PlacementGrid()
    , EditorHelpers::CameraModes()
};
array<EditorHelpers::EditorFunction@> g_functionsBuild =
{
      EditorHelpers::CustomItemPlacement()
    , EditorHelpers::FreeblockModePreciseRotation()
    , EditorHelpers::RotationRandomizer()
    , EditorHelpers::FreeblockPlacement()
    , EditorHelpers::DefaultBlockMode()
    , EditorHelpers::MoodChanger()
};
array<EditorHelpers::EditorFunction@> g_functionsInfo =
{
      EditorHelpers::LocatorCheck()
    , EditorHelpers::PodiumReminder()
    , EditorHelpers::CursorPosition()
};
array<EditorHelpers::EditorFunction@> g_functions;

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
        EditorHelpers::WindowMenuBar::RenderWindowsMenuItems();
        UI::EndMenu();
    }
}

void RenderMainWindowSubsection(const string&in name, array<EditorHelpers::EditorFunction@>@ collection)
{
    if (UI::CollapsingHeader(name))
    {
        for (uint index = 0; index < collection.Length; index++)
        {
            if (collection[index].Enabled())
            {
                collection[index].RenderInterface_MainWindow();
                UI::Separator();
            }
        }
    }
}

void RenderInterface()
{
    if (!EditorHelpers::HasPermission()) return;
    if (Compatibility::EditorIsNull() || Compatibility::IsMapTesting()) return;

    if (Setting_WindowVisible)
    {
        UI::SetNextWindowSize(300, 600, UI::Cond::FirstUseEver);
        int windowFlags = UI::WindowFlags::NoCollapse | UI::WindowFlags::MenuBar;
        UI::Begin(g_windowName, Setting_WindowVisible, windowFlags);

        EditorHelpers::WindowMenuBar::RenderDefaultMenus();

        RenderMainWindowSubsection("Action", g_functionsAction);
        RenderMainWindowSubsection("Display", g_functionsDisplay);
        RenderMainWindowSubsection("Build", g_functionsBuild);
        RenderMainWindowSubsection("Info", g_functionsInfo);

        UI::End();
    }

    for (uint index = 0; index < g_functions.Length; index++)
    {
        g_functions[index].RenderInterface_ChildWindow();
    }

    EditorHelpers::About::RenderAboutWindow();
}

void RenderSettingsSubsection(const string&in name, array<EditorHelpers::EditorFunction@>@ collection)
{
    UI::Markdown("# " + name);
    for (uint index = 0; index < collection.Length; index++)
    {
        if (collection[index].HasSettingsEntry())
        {
            collection[index].RenderInterface_Settings();
            UI::Dummy(vec2(10.0f, 10.0f));
            UI::Separator();
        }
    }
    UI::Dummy(vec2(20.0f, 20.0f));
}

[SettingsTab name="Settings"]
void RenderSettingsPage()
{
    UI::PushID("GeneralSettingsPage");
    UI::Markdown("# Editor Helpers");
    settingToolTipsEnabled = UI::Checkbox("Show tooltips in the editor helpers window", settingToolTipsEnabled);
    Setting_DebugLoggingEnabled = UI::Checkbox("Enable EXTREMELY VERBOSE logging to Openplanet.log", Setting_DebugLoggingEnabled);
    UI::TextWrapped("Listed in these settings are each individual function of the editor helpers plugin. You can"
        " enable or disable each plugin individually. Disabling a function will remove any UI associated with it and"
        " stop it from operating. Turn on and off the things you want to customize your experience with this plugin.");
    UI::Dummy(vec2(20.0f, 20.0f));
    UI::PopID();

    RenderSettingsSubsection("Action", g_functionsAction);
    RenderSettingsSubsection("Display", g_functionsDisplay);
    RenderSettingsSubsection("Build", g_functionsBuild);
    RenderSettingsSubsection("Info", g_functionsInfo);
    RenderSettingsSubsection("Other", g_functionsNone);
}

void OnKeyPress(bool down, VirtualKey key)
{
    if (!EditorHelpers::HasPermission()) return;
    for (uint index = 0; index < g_functions.Length; index++)
    {
        g_functions[index].OnKeyPress(down, key);
    }
}

void Main()
{
    for (uint i = 0; i < g_functionsNone.Length; ++i) { g_functions.InsertLast(g_functionsNone[i]); }
    for (uint i = 0; i < g_functionsAction.Length; ++i) { g_functions.InsertLast(g_functionsAction[i]); }
    for (uint i = 0; i < g_functionsDisplay.Length; ++i) { g_functions.InsertLast(g_functionsDisplay[i]); }
    for (uint i = 0; i < g_functionsBuild.Length; ++i) { g_functions.InsertLast(g_functionsBuild[i]); }
    for (uint i = 0; i < g_functionsInfo.Length; ++i) { g_functions.InsertLast(g_functionsInfo[i]); }

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
            for (uint index = 0; index < g_functions.Length; index++)
            {
                g_functions[index].Init();
                g_functions[index].Update(dt);
                g_functions[index].FirstPass = false;
            }
        }
        prevFrameTime = Time::Now;
    }
}
