
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
            return IsGameResource || (!IsGameResource && Url != "" && ValidUrl());
        }

        bool ValidUrl()
        {
            bool valid = false;
            if (g_checkedUrls.Exists(Url))
            {
                valid = bool(g_checkedUrls[Url]);
            }
            return valid;
        }

        string LocatorTooltipErrorText()
        {
            string text = "";
            if (!IsGameResource && Url == "")
            {
                text = "Locator is missing an external URL";
            }
            else if (!IsGameResource && Url != "" && !ValidUrl())
            {
                text = "Locator URL is incorrect or not working";
            }
            return text;
        }

        string UrlTooltipErrorText()
        {
            string text = "";
            if (!ValidUrl())
            {
                text = "Locator URL does not return a valid response";
            }
            return text;
        }
    }

    // Maintain a global collection of checked Urls. This should reduce the
    // number of external requests we send.
    dictionary g_checkedUrls = {};

    [Setting category="Functions" name="LocatorCheck: Enabled" hidden]
    bool Setting_LocatorCheck_Enabled = true;

    class LocatorCheck : EditorHelpers::EditorFunction
    {
        private bool m_initGameResources = true;
        private string[] m_gameResources = {};
        private XmlHeaderDependency[] m_deps = {};
        private string m_headerText = "Locators";

        string Name() override { return "Locator Check"; }
        bool Enabled() override { return Setting_LocatorCheck_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_LocatorCheck_Enabled = UI::Checkbox("Enabled", Setting_LocatorCheck_Enabled);
            UI::BeginDisabled(!Setting_LocatorCheck_Enabled);
            UI::TextWrapped("This function will read the file header information from your map file each time you save"
                " to check the linked media dependencies and the results will be displayed. This should let you know"
                " if your media locators are working or not.");
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("LocatorCheck::Display");
            }

            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled()) return;

            if (Editor !is null)
            {
                if (m_initGameResources)
                {
                    m_initGameResources = false;
                    RecursiveAddDefaultSkinsPath(cast<CSystemFidsFolder>(Fids::GetGameFolder("GameData/Skins")), "Skins\\", m_gameResources);
                    RecursiveAddDefaultSkinsPath(cast<CSystemFidsFolder>(Fids::GetGameFolder("GameData/Media")), "Media\\", m_gameResources);
                }
            }
            else
            {
                if (m_deps.Length != 0)
                {
                    m_deps.RemoveRange(0, m_deps.Length);
                }
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
                startnew(CoroutineFunc(Async_TestLocatorUrls));
            }

            if (m_deps.Length > 0)
            {
                m_headerText = "Locators - Valid \\$0f0" + Icons::Check;
                for (uint i = 0; i < m_deps.Length; ++i)
                {
                    if (!m_deps[i].ValidLocator())
                    {
                        m_headerText = "Locators - Error(s) \\$f00" + Icons::Times;
                        break;
                    }
                }
            }
            else
            {
                m_headerText = "Locators";
            }
        }

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            EditorHelpers::NewMarker(sameLine: false);

            EditorHelpers::BeginHighlight("LocatorCheck::Display");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Check locators embedded in the map");
                UI::SameLine();
            }
            if (UI::TreeNode(m_headerText + "###Locators"))
            {
                if (m_deps.Length > 0 && UI::BeginTable("LocatorInfoTable", 5))
                {
                    UI::TableSetupColumn("##LocValid", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 15.0f);
                    UI::TableSetupColumn("##UrlValid", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 15.0f);
                    UI::TableSetupColumn("File");
                    UI::TableSetupColumn("Url");
                    UI::TableSetupColumn("##UrlButton", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 30.0f);
                    UI::TableHeadersRow();

                    for (uint i = 0; i < m_deps.Length; i++)
                    {
                        UI::TableNextRow();
                        UI::TableNextColumn();
                        if (m_deps[i].ValidLocator())
                        {
                            UI::Text("\\$0f0" + Icons::Check);
                        }
                        else
                        {
                            UI::Text("\\$f00" + Icons::Times);
                            if (UI::IsItemHovered())
                            {
                                UI::BeginTooltip();
                                UI::Text(m_deps[i].LocatorTooltipErrorText());
                                UI::EndTooltip();
                            }
                        }

                        UI::TableNextColumn();
                        if (m_deps[i].Url != "")
                        {
                            if (m_deps[i].ValidUrl())
                            {
                                UI::Text("\\$0f0" + Icons::Link);
                            }
                            else
                            {
                                UI::Text("\\$f00" + Icons::ChainBroken);
                                if (UI::IsItemHovered())
                                {
                                    UI::BeginTooltip();
                                    UI::Text(m_deps[i].UrlTooltipErrorText());
                                    UI::EndTooltip();
                                }
                            }
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
            EditorHelpers::EndHighlight();
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

                // There is something im not understanding about the game files
                // that have a + in their file name. It appears that when you
                // save one of these to a map the name that actually gets used
                // can be any one of the variants in the logic below.
                if (fidsSubfile.FileName.Contains("+"))
                {
                    string tempFilename = fidsSubfile.FileName;
                    string baseFilename = tempFilename.SubStr(0, tempFilename.IndexOf("+"));
                    string plusAddon = tempFilename.SubStr(tempFilename.IndexOf("+"), tempFilename.IndexOf(".") - tempFilename.IndexOf("+"));
                    string fileExtn = tempFilename.SubStr(tempFilename.IndexOf("."), tempFilename.Length - tempFilename.IndexOf("."));

                    string[] plusOptions = { "", "+FreezeRGB", "+111Y", "+111A" };
                    for (uint optionIndex = 0; optionIndex < plusOptions.Length; ++optionIndex)
                    {
                        if (plusAddon != plusOptions[optionIndex])
                        {
                            string newName = baseFilename + plusOptions[optionIndex] + fileExtn;
                            paths.InsertLast(prefix + newName);
                        }
                    }
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

        private bool Async_HttpHeadSuccess(const string&in url)
        {
            bool success = false;
            Net::HttpRequest@ request = Net::HttpHead(url);
            while (!request.Finished())
            {
                yield();
            }
            success = request.ResponseCode() < 400 && request.ResponseCode() >= 200 && request.Error().Length == 0;
            return success;
        }

        private void Async_TestLocatorUrls()
        {
            for (uint i = 0; i < m_deps.Length; ++i)
            {
                if (m_deps[i].Url != "" && !g_checkedUrls.Exists(m_deps[i].Url))
                {
                    g_checkedUrls[m_deps[i].Url] = Async_HttpHeadSuccess(m_deps[i].Url);
                }
            }
        }
    }
}
