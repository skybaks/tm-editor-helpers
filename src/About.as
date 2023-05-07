
[Setting hidden]
bool Setting_About_WindowVisible = false;
[Setting hidden]
string Setting_About_LastVersionDisplayedFor = "";

namespace EditorHelpers
{
    namespace About
    {
        string g_changelogMarkdownText = "";
        bool g_changelogMarkdownInitialized = false;
        string g_pluginVersion = "";
        string g_pluginSource = "";
        string g_pluginSourcePath = "";
        bool g_pluginInfoInitialized = false;

        void RenderAboutWindow()
        {
            if (!g_pluginInfoInitialized)
            {
                g_pluginInfoInitialized = true;
                InitializePluginInfo();
            }

            // Show the about window whenever there is a new plugin version
            if (Setting_About_LastVersionDisplayedFor != g_pluginVersion)
            {
                Setting_About_WindowVisible = true;
                Setting_About_LastVersionDisplayedFor = g_pluginVersion;
            }

            if (Setting_About_WindowVisible)
            {
                UI::SetNextWindowSize(500, 500, UI::Cond::FirstUseEver);
                UI::Begin(g_windowName + ": About", Setting_About_WindowVisible);

                UI::Markdown("# Editor Helpers");

                UI::Text("Version");
                UI::SameLine();
                UI::TextDisabled(g_pluginVersion);

                UI::Text("Source");
                UI::SameLine();
                UI::TextDisabled(g_pluginSource);

                UI::Text("Source Path");
                UI::SameLine();
                UI::TextDisabled(g_pluginSourcePath);

                UI::Markdown("# Changelog");

                vec2 cursorPos = UI::GetCursorPos();
                vec2 windowSiz = UI::GetWindowSize();
                vec2 childSize = vec2(0, windowSiz.y - cursorPos.y - 40);
                if (childSize.y > 0.0)
                {
                    if (UI::BeginChild("AboutWindowChangelogChild", childSize))
                    {
                        if (!g_changelogMarkdownInitialized)
                        {
                            g_changelogMarkdownInitialized = true;
                            InitializeChangelogText();
                        }
                        UI::Markdown(g_changelogMarkdownText);
                    }
                    UI::EndChild();
                }

                if (UI::Button(Icons::Github + " Github"))
                {
                    OpenBrowserURL("https://github.com/skybaks/tm-editor-helpers");
                }

                UI::SameLine();
                if (UI::Button(Icons::Heartbeat + " Openplanet"))
                {
                    OpenBrowserURL("https://openplanet.dev/plugin/editorhelpers");
                }

                UI::End();
            }
        }

        void InitializeChangelogText()
        {
            try
            {
                auto fs = IO::FileSource("changelog.md");
                g_changelogMarkdownText = fs.ReadToEnd();
            }
            catch
            {
                error("Error reading changelog.md");
                g_changelogMarkdownText = "Error while reading changelog file :(";
            }
        }

        void InitializePluginInfo()
        {
            auto@ self = Meta::ExecutingPlugin();
            g_pluginVersion = self.Version;
            g_pluginSource = tostring(self.Source);
            g_pluginSourcePath = self.SourcePath;
        }
    }
}
