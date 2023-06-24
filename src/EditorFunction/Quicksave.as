
namespace EditorHelpers
{
    namespace HotkeyInterface
    {
        bool g_Quicksave_Activate = false;

        bool Enabled_Quicksave()
        {
            return Setting_Quicksave_Enabled;
        }

        void ActivateQuicksave()
        {
            if (Setting_Quicksave_Enabled)
            {
                g_Quicksave_Activate = true;
            }
        }
    }

    [Setting category="Functions" name="Quicksave: Enabled" hidden]
    bool Setting_Quicksave_Enabled = true;

    [Setting category="Functions" name="Quicksave: Create Copy" hidden]
    bool Setting_Quicksave_CreateCopy = false;

    class Quicksave : EditorHelpers::EditorFunction
    {
        private EditorHelpers::CountdownTimer timerQuicksave;
        private bool m_triggerSave;
        private bool m_functionalityDisabled;

        string Name() override { return "Quicksave"; }
        bool Enabled() override { return Setting_Quicksave_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_Quicksave_Enabled = UI::Checkbox("Enabled", Setting_Quicksave_Enabled);
            UI::BeginDisabled(!Setting_Quicksave_Enabled);
            UI::TextWrapped("This function creates a \"Quicksave\" button in the Action subsection. Clicking the "
                "quicksave button will save the current map and skip all the popup dialogs from the normal save.");
            UI::TextWrapped("Additionally, you can turn on the following setting to enable the plugin to create a "
                "backup copy of the map everytime you save. The backup copy will be saved to a folder called "
                "\"Maps/Quicksaves_EditorHelpers\"");
            Setting_Quicksave_CreateCopy = UI::Checkbox("Create a backup copy of the map upon saving", Setting_Quicksave_CreateCopy);
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("Quicksave::Display");
            }

            UI::PopID();
        }

        void Init() override
        {
            if (FirstPass)
            {
                timerQuicksave.MaxTime = 2.0f;
            }

            if (!Enabled() || Editor is null)
            {
                m_triggerSave = false;
                HotkeyInterface::g_Quicksave_Activate = false;
            }
        }

        void RenderInterface_MainWindow() override
        {
            if (!Enabled() || Editor is null) return;

            UI::BeginDisabled(m_functionalityDisabled);
            EditorHelpers::BeginHighlight("Quicksave::Display");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Save map in one click");
                UI::SameLine();
            }
            UI::BeginDisabled(!timerQuicksave.Complete());
            if (UI::Button("Save Map"))
            {
                m_triggerSave = true;
            }
            UI::EndDisabled();
            if (Editor.PluginMapType !is null)
            {
                UI::SameLine();
                UI::Text(Editor.PluginMapType.MapFileName);
            }
            EditorHelpers::EndHighlight();
            UI::EndDisabled();
        }

        void Update(float dt) override
        {
            if (!Enabled() || Editor is null || Editor.PluginMapType is null)
            {
                m_functionalityDisabled = true;
                return;
            }
            else
            {
                m_functionalityDisabled = false;
            }

            float dtSeconds = dt / 1000.0f;
            timerQuicksave.Update(dtSeconds);

            if ((m_triggerSave || HotkeyInterface::g_Quicksave_Activate) && timerQuicksave.Complete())
            {
                string currentFileName = Editor.PluginMapType.MapFileName;
                if (currentFileName != "")
                {
                    string saveName = CombinePath(GetFileFolder(currentFileName), Editor.PluginMapType.MapName + ".Map.Gbx");
                    Editor.PluginMapType.SaveMap(saveName);
                }
                else
                {
                    Editor.ButtonSaveOnClick();
                }
                timerQuicksave.StartNew();
            }

            m_triggerSave = false;
            HotkeyInterface::g_Quicksave_Activate = false;

            if (Signal_MapFileUpdated() && !Signal_EnteredEditor() && Setting_Quicksave_CreateCopy)
            {
                SaveMapCopy();
            }
        }

        private void SaveMapCopy()
        {
            string mapsFolderPath = IO::FromUserGameFolder("Maps");
            string currentMapFilePath = CombinePath(mapsFolderPath, Editor.PluginMapType.MapFileName);
            string autosaveFolderPath = CombinePath(mapsFolderPath, "Quicksaves_EditorHelpers");
            string targetCopyName = SplitExtension(Editor.PluginMapType.MapFileName).Replace("\\", "_").Replace("/", "_");
            if (!IO::FolderExists(autosaveFolderPath))
            {
                Debug("Folder does not exist " + autosaveFolderPath);
                IO::CreateFolder(autosaveFolderPath);
            }

            int largestExisting = 0;
            array<string> existingFiles = IO::IndexFolder(autosaveFolderPath, false);
            for (uint i = 0; i < existingFiles.Length; ++i)
            {
                string filename = GetFilename(existingFiles[i]);
                if (filename.StartsWith(targetCopyName))
                {
                    array<string> splitFile = SplitExtension(filename).Split("_");
                    int count = Text::ParseInt(splitFile[splitFile.Length - 1]);
                    largestExisting = Math::Max(largestExisting, count);
                }
            }
            Debug("largestExisting is " + tostring(largestExisting));
            string targetFileName = targetCopyName + "_" + Text::Format("%06d", largestExisting + 1) + ".Map.Gbx";

            IO::File fs(currentMapFilePath, IO::FileMode::Read);
            MemoryBuffer@ data = fs.Read(fs.Size());
            fs.Close();
            IO::File of(CombinePath(autosaveFolderPath, targetFileName), IO::FileMode::Write);
            of.Write(data);
            of.Close();
        }

        // C:\folder\path\file.txt -> file.txt
        private string GetFilename(const string&in filepath)
        {
            array<string> pathParts = filepath.Replace("\\", "/").Split("/");
            string filename = filepath;
            if (pathParts.Length > 0)
            {
                filename = pathParts[pathParts.Length - 1];
            }
            return filename;
        }

        // C:\folder\path\file.txt -> C:\folder\path
        private string GetFileFolder(const string&in filepath)
        {
            array<string> pathParts = filepath.Replace("\\", "/").Split("/");
            if (pathParts.Length > 0)
            {
                pathParts.RemoveAt(pathParts.Length - 1);
            }
            return string::Join(pathParts, "/");
        }

        // file.txt -> file
        private string SplitExtension(const string&in filename)
        {
            array<string> nameParts = filename.Split(".");
            if (nameParts.Length > 2
                && nameParts[nameParts.Length - 1].ToUpper() == "GBX")
            {
                nameParts.RemoveRange(nameParts.Length - 2, 2);
            }
            else if (nameParts.Length > 1)
            {
                nameParts.RemoveAt(nameParts.Length - 1);
            }
            return string::Join(nameParts, ".");
        }

        private string CombinePath(const string&in path1, const string&in path2)
        {
            string path1Norm = path1.Replace("\\", "/");
            if (path1Norm.EndsWith("/"))
            {
                path1Norm = path1Norm.SubStr(0, path1Norm.Length - 1);
            }
            string path2Norm = path2.Replace("\\", "/");
            if (path2Norm.StartsWith("/"))
            {
                path2Norm = path2Norm.SubStr(1);
            }
            return path1Norm + "/" + path2Norm;
        }
    }
}