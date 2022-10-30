
namespace EditorHelpers
{
    class GbxHeaderChunkInfo
    {
        int ChunkId;
        int ChunkSize;
    }

    class XmlHeaderDependency
    {
        string File;
        string Url;

        bool IsGameResource;

        bool ValidLocator()
        {
            return Url != "" || IsGameResource;
        }
    }

    [Setting category="Functions" name="LocatorCheck: Enabled" hidden]
    bool Setting_LocatorCheck_Enabled = true;

    class LocatorCheck : EditorHelpers::EditorFunction
    {
        private bool m_initGameResources = true;
        private string[] m_gameResources = {};
        private XmlHeaderDependency[] m_deps = {};

        string Name() override { return "Locator Check"; }
        bool Enabled() override { return Setting_LocatorCheck_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_LocatorCheck_Enabled = UI::Checkbox("Enabled", Setting_LocatorCheck_Enabled);
            UI::BeginDisabled(!Setting_LocatorCheck_Enabled);
            UI::TextWrapped("This function will read the file header information from your map file each time you save to check the linked media dependencies and the results will be displayed. This should let you know if your media locators are working or not.");
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled()) return;

            if (Editor !is null)
            {
                if (m_initGameResources)
                {
                    auto appFidFile = cast<CSystemFidFile>(GetFidFromNod(GetApp()));
                    if (appFidFile !is null)
                    {
                        m_initGameResources = false;
                        CSystemFidsFolder@ skinsFidFolder = GetTreeFidsFolder(appFidFile.ParentFolder, "Skins");
                        RecursiveAddDefaultSkinsPath(skinsFidFolder, "Skins\\", m_gameResources);
                        CSystemFidsFolder@ mediaFidFolder = GetTreeFidsFolder(appFidFile.ParentFolder, "Media");
                        RecursiveAddDefaultSkinsPath(mediaFidFolder, "Media\\", m_gameResources);
                    }
                }
            }
            else
            {
                if (m_deps.Length != 0)
                {
                    m_deps = {};
                }
                m_initGameResources = true;
            }
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;

            if (Signal_MapFileUpdated())
            {
                string xmlHeaderString = ReadGbxXmlHeader();
                m_deps = {};
                ParseHeaderXml(xmlHeaderString);
                for (uint i = 0; i < m_deps.Length; i++)
                {
                    m_deps[i].IsGameResource = m_gameResources.Find(m_deps[i].File) >= 0;
                }
            }
        }

        void RenderInterface_Info() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Check locators embedded in the map");
                UI::SameLine();
            }
            if (UI::TreeNode("Locators"))
            {
                if (m_deps.Length > 0 && UI::BeginTable("LocatorInfoTable", 4))
                {
                    UI::TableSetupColumn("", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 15.0f);
                    UI::TableSetupColumn("File");
                    UI::TableSetupColumn("Url");
                    UI::TableSetupColumn("", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 30.0f);
                    UI::TableHeadersRow();

                    for (uint i = 0; i < m_deps.Length; i++)
                    {
                        UI::TableNextRow();
                        UI::TableNextColumn();
                        if (m_deps[i].ValidLocator())
                        {
                            UI::Text("\\$0f0");
                        }
                        else
                        {
                            UI::Text("\\$f00");
                        }

                        UI::TableNextColumn();
                        UI::Text(m_deps[i].File);
                        if (UI::IsItemHovered())
                        {
                            UI::BeginTooltip();
                            UI::Text(m_deps[i].File);
                            UI::EndTooltip();
                        }

                        UI::TableNextColumn();
                        if (m_deps[i].IsGameResource)
                        {
                            UI::Text("\\$777<ingame resource>");
                        }
                        else
                        {
                            UI::Text(m_deps[i].Url);
                            if (UI::IsItemHovered())
                            {
                                UI::BeginTooltip();
                                UI::Text(m_deps[i].Url);
                                UI::EndTooltip();
                            }
                        }

                        UI::TableNextColumn();
                        if (m_deps[i].Url == "")
                        {
                            UI::Text("");
                        }
                        else
                        {
                            UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(1.0f, 1.0f));
                            if (UI::Button("##" + tostring(i)))
                            {
                                OpenBrowserURL(m_deps[i].Url);
                            }
                            UI::PopStyleVar();
                        }
                    }

                    UI::EndTable();
                }
                else
                {
                    UI::Text("No dependencies found");
                }

                UI::TreePop();
            }
        }

        private CSystemFidsFolder@ GetTreeFidsFolder(CSystemFids@ fids, const string&in dirName)
        {
            for (uint i = 0; i < fids.Trees.Length; i++)
            {
                auto treeAsFidsFolder = cast<CSystemFidsFolder>(fids.Trees[i]);
                if (treeAsFidsFolder !is null && treeAsFidsFolder.DirName == dirName)
                {
                    return treeAsFidsFolder;
                }
            }
            return null;
        }

        private void RecursiveAddDefaultSkinsPath(CSystemFidsFolder@ fidsFolder, const string&in prefix, string[]& paths)
        {
            for (uint i = 0; i < fidsFolder.Trees.Length; i++)
            {
                auto fidsSubfolder = cast<CSystemFidsFolder>(fidsFolder.Trees[i]);
                RecursiveAddDefaultSkinsPath(fidsSubfolder, prefix + fidsSubfolder.DirName + "\\", paths);
            }

            for (uint i = 0; i < fidsFolder.Leaves.Length; i++)
            {
                auto fidsSubfile = cast<CSystemFidFile>(fidsFolder.Leaves[i]);
                paths.InsertLast(prefix + fidsSubfile.FileName);

                // Some weirdness with the arrows. Add these other file paths
                if (fidsSubfile.FileName.Contains("+FreezeRGB"))
                {
                    string tempFilename = fidsSubfile.FileName;
                    tempFilename = tempFilename.Replace("+FreezeRGB", "");
                    paths.InsertLast(prefix + tempFilename);
                }
            }
        }

        private string ReadGbxXmlHeader()
        {
            // refs
            // https://github.com/BigBang1112/gbx-net/blob/master/Src/GBX.NET/Engines/Game/CGameCtnChallenge.md
            // https://github.com/PyPlanet/PyPlanet/blob/master/pyplanet/utils/gbxparser.py
            string xmlString = "";
            auto fidFile = cast<CSystemFidFile>(GetFidFromNod(Editor.Challenge));
            if (fidFile !is null)
            {
                try
                {
                    IO::File mapFile(fidFile.FullFileName);
                    mapFile.Open(IO::FileMode::Read);

                    mapFile.SetPos(17);
                    int headerChunkCount = mapFile.Read(4).ReadInt32();

                    GbxHeaderChunkInfo[] chunks = {};
                    for (int i = 0; i < headerChunkCount; i++)
                    {
                        GbxHeaderChunkInfo newChunk;
                        newChunk.ChunkId = mapFile.Read(4).ReadInt32();
                        newChunk.ChunkSize = mapFile.Read(4).ReadInt32() & 0x7FFFFFFF;
                        chunks.InsertLast(newChunk);
                    }

                    for (uint i = 0; i < chunks.Length; i++)
                    {
                        MemoryBuffer chunkBuffer = mapFile.Read(chunks[i].ChunkSize);
                        if (chunks[i].ChunkId == 50606085)
                        {
                            int stringLength = chunkBuffer.ReadInt32();
                            xmlString = chunkBuffer.ReadString(stringLength);
                            break;
                        }
                    }

                    mapFile.Close();
                }
                catch
                {
                    error("Error while reading GBX XML Header");
                }
            }
            return xmlString;
        }

        private void ParseHeaderXml(const string&in xmlString)
        {
            try
            {
                XML::Document doc;
                doc.LoadString(xmlString);
                XML::Node headerNode = doc.Root().FirstChild();
                XML::Node depsHeaderNode = headerNode.Child("deps");
                XML::Node depsNode = depsHeaderNode.FirstChild();
                while (depsNode)
                {
                    XmlHeaderDependency newDep;
                    newDep.File = depsNode.Attribute("file");
                    newDep.Url = depsNode.Attribute("url");
                    m_deps.InsertLast(newDep);
                    depsNode = depsNode.NextSibling();
                }

            }
            catch
            {
                error("Error while parsing GBX XML Header");
            }
        }
    }
}
