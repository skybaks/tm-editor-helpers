
namespace EditorHelpers
{
    class EditorInventoryArticle
    {
        EditorInventoryArticle()
        {
            DisplayName = "";
            @Article = null;
            PlaceMode = CGameEditorPluginMap::EPlaceMode::Unknown;
        }

        EditorInventoryArticle(const string&in name, CGameCtnArticleNodeArticle@ article, CGameEditorPluginMap::EPlaceMode placeMode)
        {
            DisplayName = name;
            @Article = article;
            PlaceMode = placeMode;
        }

        string DisplayName;
        CGameCtnArticleNodeArticle@ Article;
        CGameEditorPluginMap::EPlaceMode PlaceMode;
    }

    class EditorInventoryPalette
    {
        EditorInventoryPalette()
        {
            Name = "Palette";
            Articles = {};
        }

        string Name;
        EditorInventoryArticle@[] Articles;
    }

    enum PaletteRandomizerMode
    {
        NONE,
        RANDOM,
        CYCLE
    }

    namespace Compatibility
    {
        bool EnableCustomPaletteFunction()
        {
#if TMNEXT
#else
            Setting_CustomPalette_Enabled = false;
#endif
            return Setting_CustomPalette_Enabled;
        }
    }

    namespace HotkeyInterface
    {
        bool g_CustomPalette_QuickswitchPreviousTrigger = false;

        void QuickswitchPreviousArticle()
        {
            if (Setting_CustomPalette_Enabled)
            {
                g_CustomPalette_QuickswitchPreviousTrigger = true;
            }
        }
    }

    [Setting category="Functions" name="CustomPalette: Enabled" hidden]
    bool Setting_CustomPalette_Enabled = true;
    [Setting category="Functions" name="CustomPalette: Window Visible" hidden]
    bool Setting_CustomPalette_WindowVisible = false;
    [Setting category="Functions" name="CustomPalette: Article History Max" hidden]
    uint Setting_CustomPalette_ArticleHistoryMax = 10;

    class CustomPalette : EditorHelpers::EditorFunction
    {
        private EditorInventoryArticle@[] m_articles;
        private EditorInventoryArticle@[] m_articlesFiltered;
        private EditorInventoryArticle@[] m_articlesHistory;
        private string m_filterString;
        private string m_filterStringPrev;
        private CGameCtnArticleNodeArticle@ m_selectedArticlePrev;
        private EditorInventoryPalette@[] m_palettes;
        private uint m_selectedPaletteIndex;
        private bool m_forcePaletteIndex;
        private string m_paletteNewName;
        private bool m_deleteConfirm;
        private PaletteRandomizerMode m_paletteRandomize;

        string Name() override { return "Custom Palette"; }
        bool Enabled() override { return Compatibility::EnableCustomPaletteFunction(); }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_CustomPalette_Enabled = UI::Checkbox("Enabled", Setting_CustomPalette_Enabled);
            UI::BeginDisabled(!Setting_CustomPalette_Enabled);
            UI::TextWrapped("This function opens an additional display window that contains a searchable list of all blocks, items, and macroblocks in the editor. It also shows all recent blocks, items, and macroblocks used.");

            Setting_CustomPalette_WindowVisible = UI::Checkbox("Show Additional Window", Setting_CustomPalette_WindowVisible);
            Setting_CustomPalette_ArticleHistoryMax = Math::Clamp(UI::InputInt("Max number of recent blocks/items/macroblocks", Setting_CustomPalette_ArticleHistoryMax), 5, 100);
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                m_filterString = "";
                m_filterStringPrev = "";
                @m_selectedArticlePrev = null;
                HotkeyInterface::g_CustomPalette_QuickswitchPreviousTrigger = false;
                m_forcePaletteIndex = false;
                m_deleteConfirm = false;
                m_paletteRandomize = PaletteRandomizerMode::NONE;
            }
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Show or hide the window for the custom block palette");
                UI::SameLine();
            }
            Setting_CustomPalette_WindowVisible = UI::Checkbox("Show Custom Palette Window", Setting_CustomPalette_WindowVisible);
        }

        void RenderInterface_ChildWindow() override
        {
            if (!Enabled() || Editor is null || m_articles.Length == 0 || !Setting_CustomPalette_WindowVisible)
            {
                return;
            }

            UI::SetNextWindowSize(550, 350, UI::Cond::FirstUseEver);
            UI::Begin(g_windowName + ": " + Name(), Setting_CustomPalette_WindowVisible);

            UI::BeginTabBar("CustomPaletteTabBar");
            if (UI::BeginTabItem("Search"))
            {
                m_filterString = UI::InputText("Filter", m_filterString);

                if (m_filterString != m_filterStringPrev)
                {
                    UpdateFilteredList();
                }
                m_filterStringPrev = m_filterString;

                DisplayInventoryArticlesTable("Search", m_articlesFiltered);
                UI::EndTabItem();
            }

            if (UI::BeginTabItem("Recent"))
            {
                DisplayInventoryArticlesTable("History", m_articlesHistory);
                UI::EndTabItem();
            }

            if (UI::BeginTabItem("Custom"))
            {
                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Create, Edit, or Delete custom palettes");
                    UI::SameLine();
                }
                if (UI::TreeNode("Edit"))
                {
                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Create a new custom palette");
                        UI::SameLine();
                    }
                    if (UI::Button(" New Palette"))
                    {
                        m_palettes.InsertLast(EditorInventoryPalette());
                        m_forcePaletteIndex = true;
                        m_selectedPaletteIndex = m_palettes.Length - 1;
                    }
                    UI::BeginDisabled(m_deleteConfirm);
                    UI::SameLine();
                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Delete the active custom palette");
                        UI::SameLine();
                    }
                    if (UI::Button(" Delete Selected Palette"))
                    {
                        m_deleteConfirm = true;
                    }
                    UI::EndDisabled();
                    if (m_deleteConfirm)
                    {
                        UI::SameLine();
                        UI::Text("Are you sure?");
                        UI::SameLine();
                        if (UI::Button("Yes"))
                        {
                            if (m_selectedPaletteIndex >= 0 && m_selectedPaletteIndex < m_palettes.Length)
                            {
                                m_palettes.RemoveAt(m_selectedPaletteIndex);
                                m_forcePaletteIndex = true;
                                m_selectedPaletteIndex = m_selectedPaletteIndex != 0 ? m_selectedPaletteIndex - 1 : 0;
                            }
                            m_deleteConfirm = false;

                            SavePalettes();
                        }
                        UI::SameLine();
                        if (UI::Button("Cancel"))
                        {
                            m_deleteConfirm = false;
                        }
                    }

                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Rename the active custom palette. Use \"Set Name\" to apply changes");
                        UI::SameLine();
                    }
                    m_paletteNewName = UI::InputText("##NewPaletteName", m_paletteNewName);
                    UI::SameLine();
                    if (UI::Button("Set Name")
                        && m_selectedPaletteIndex >= 0 && m_selectedPaletteIndex < m_palettes.Length)
                    {
                        m_palettes[m_selectedPaletteIndex].Name = m_paletteNewName;
                        m_paletteNewName = "";
                        m_forcePaletteIndex = true;

                        SavePalettes();
                    }

                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Add or remove elements from the active custom palette");
                        UI::SameLine();
                    }
                    UI::Text("Current Block/Item/Macroblock: ");
                    UI::SameLine();
                    if (UI::Button(" Add") && m_articlesHistory.Length > 0)
                    {
                        AddNewArticleToPalette(m_articlesHistory[0].Article, m_selectedPaletteIndex);

                        SavePalettes();
                    }
                    UI::SameLine();
                    if (UI::Button(" Remove") && m_articlesHistory.Length > 0)
                    {
                        RemoveArticleFromPalette(m_articlesHistory[0].Article, m_selectedPaletteIndex);

                        SavePalettes();
                    }

                    UI::TreePop();
                }

                if (settingToolTipsEnabled)
                {
                    EditorHelpers::HelpMarker("Tools to use with existing custom palettes");
                    UI::SameLine();
                }
                if (UI::TreeNode("Build"))
                {
                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Chooses random from palette on block/item/macroblock placement.\n\n\"Random\" picks a random selection from the palette\n\"Cycle\" cycles through the palette in order\n\"None\" is the randomizer turned off");
                        UI::SameLine();
                    }
                    UI::Text("Randomizer:");
                    UI::SameLine();
                    if (UI::RadioButton("None", m_paletteRandomize == PaletteRandomizerMode::NONE))
                    {
                        m_paletteRandomize = PaletteRandomizerMode::NONE;
                    }
                    UI::SameLine();
                    if (UI::RadioButton("Random", m_paletteRandomize == PaletteRandomizerMode::RANDOM))
                    {
                        m_paletteRandomize = PaletteRandomizerMode::RANDOM;
                    }
                    UI::SameLine();
                    if (UI::RadioButton("Cycle", m_paletteRandomize == PaletteRandomizerMode::CYCLE))
                    {
                        m_paletteRandomize = PaletteRandomizerMode::CYCLE;
                    }

                    UI::TreePop();
                }

                UI::BeginTabBar("CustomPaletteTabBarCustomPalettes");
                for (uint paletteIndex = 0; paletteIndex < m_palettes.Length; ++paletteIndex)
                {
                    UI::TabItemFlags flags = m_forcePaletteIndex && paletteIndex == m_selectedPaletteIndex ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None;
                    if (UI::BeginTabItem(m_palettes[paletteIndex].Name + "##" + tostring(paletteIndex), flags))
                    {
                        m_selectedPaletteIndex = paletteIndex;

                        DisplayInventoryArticlesTable("Palette##" + tostring(paletteIndex), m_palettes[paletteIndex].Articles);
                        UI::EndTabItem();
                    }
                }
                m_forcePaletteIndex = false;
                UI::EndTabBar();

                UI::EndTabItem();
            }
            UI::EndTabBar();

            UI::End();
        }

        void RenderInterface_MenuItem() override
        {
            if (!Enabled())
            {
                return;
            }

            if (UI::MenuItem(Icons::PuzzlePiece + " " + Name(), selected: Setting_CustomPalette_WindowVisible))
            {
                Setting_CustomPalette_WindowVisible = !Setting_CustomPalette_WindowVisible;
            }
        }

        void Update(float) override
        {
            Debug_EnterMethod("Update");
            if (!Enabled() || Editor is null)
            {
                Debug_LeaveMethod();
                return;
            }

            if (Signal_EnteredEditor())
            {
                IndexInventory();
            }

            if (Signal_BlockItemPlaced() && m_paletteRandomize != PaletteRandomizerMode::NONE
                && Setting_CustomPalette_WindowVisible
                && m_selectedPaletteIndex >= 0 && m_selectedPaletteIndex < m_palettes.Length
                && m_palettes[m_selectedPaletteIndex].Articles.Length > 0)
            {
                if (m_paletteRandomize == PaletteRandomizerMode::RANDOM)
                {
                    int newIndex = Math::Rand(0, m_palettes[m_selectedPaletteIndex].Articles.Length);
                    SetCurrentArticle(m_palettes[m_selectedPaletteIndex].Articles[newIndex]);
                }
                else if (m_paletteRandomize == PaletteRandomizerMode::CYCLE)
                {
                    int newIndex = 0;
                    if (m_articlesHistory.Length > 0)
                    {
                        for (uint searchIndex = 0; searchIndex < m_palettes[m_selectedPaletteIndex].Articles.Length; ++searchIndex)
                        {
                            if (m_palettes[m_selectedPaletteIndex].Articles[searchIndex].Article is m_articlesHistory[0].Article)
                            {
                                newIndex = searchIndex + 1;
                                break;
                            }
                        }

                        if (newIndex >= int(m_palettes[m_selectedPaletteIndex].Articles.Length))
                        {
                            newIndex = 0;
                        }
                    }
                    SetCurrentArticle(m_palettes[m_selectedPaletteIndex].Articles[newIndex]);
                }
            }

            CGameCtnArticleNodeArticle@ selectedArticle = cast<CGameCtnArticleNodeArticle>(Editor.PluginMapType.Inventory.CurrentSelectedNode);
            if (selectedArticle !is null && selectedArticle !is m_selectedArticlePrev)
            {
                AddNewArticleToHistory(selectedArticle);
            }
            @m_selectedArticlePrev = selectedArticle;

            if (HotkeyInterface::g_CustomPalette_QuickswitchPreviousTrigger && m_articlesHistory.Length > 1)
            {
                SetCurrentArticle(m_articlesHistory[1]);
            }
            HotkeyInterface::g_CustomPalette_QuickswitchPreviousTrigger = false;

            Debug_LeaveMethod();
        }

        private void RecursiveAddInventoryArticle(CGameCtnArticleNode@ current, const string&in name, CGameEditorPluginMap::EPlaceMode placeMode)
        {
            Debug_EnterMethod("RecursiveAddInventoryArticle");

            CGameCtnArticleNodeDirectory@ currentDir = cast<CGameCtnArticleNodeDirectory>(current);
            if (currentDir !is null)
            {
                for (uint i = 0; i < currentDir.ChildNodes.Length; ++i)
                {
                    auto newDir = currentDir.ChildNodes[i];
                    if (newDir.IsDirectory)
                    {
                        RecursiveAddInventoryArticle(newDir, name + "/" + newDir.NodeName, placeMode);
                    }
                    else
                    {
                        CGameCtnArticleNodeArticle@ currentArt = cast<CGameCtnArticleNodeArticle>(newDir);
                        if (currentArt !is null)
                        {
                            string articleName = name + "/" + currentArt.NodeName;
                            if (currentArt.NodeName.Contains("\\"))
                            {
                                auto splitPath = tostring(currentArt.NodeName).Split("\\");
                                if (splitPath.Length > 0)
                                {
                                    articleName = name + "/" + splitPath[splitPath.Length-1];
                                    Debug("Split node name results in: " + tostring(articleName));
                                }
                            }
                            Debug("Add " + articleName);
                            m_articles.InsertLast(EditorInventoryArticle(articleName, currentArt, placeMode));
                        }
                    }
                }
            }

            Debug_LeaveMethod();
        }

        private void IndexInventory()
        {
            Debug_EnterMethod("IndexInventory");

            if (m_articles.Length > 0)
            {
                Debug("Clearing cached articles");
                m_articles.RemoveRange(0, m_articles.Length);
            }
            if (m_articlesHistory.Length > 0)
            {
                Debug("Clearing recent articles");
                m_articlesHistory.RemoveRange(0, m_articlesHistory.Length);
            }
            if (m_palettes.Length > 0)
            {
                Debug("Clearing palettes");
                m_palettes.RemoveRange(0, m_palettes.Length);
            }

            Debug("Loading inventory blocks");
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[0], "Block", CGameEditorPluginMap::EPlaceMode::Block);
            Debug("Loading inventory items");
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[3], "Item", CGameEditorPluginMap::EPlaceMode::Item);
            Debug("Loading inventory macroblocks");
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[4], "Macroblock", CGameEditorPluginMap::EPlaceMode::Macroblock);

            Debug("Inventory total length: " + tostring(m_articles.Length));

            UpdateFilteredList();
            LoadPalettes();

            Debug_LeaveMethod();
        }

        private void SetCurrentArticle(const EditorInventoryArticle@ newArticle)
        {
            Debug_EnterMethod("SetCurrentArticle");
            if (newArticle is null)
            {
                Debug("New  EditorInventoryArticle is null");
                Debug_LeaveMethod();
                return;
            }

            if (Editor.PluginMapType.PlaceMode != newArticle.PlaceMode)
            {
                Editor.PluginMapType.PlaceMode = newArticle.PlaceMode;
            }
            Editor.PluginMapType.Inventory.SelectArticle(newArticle.Article);

            Debug_LeaveMethod();
        }

        private EditorInventoryArticle@ FindArticleByName(const string&in articleName)
        {
            for (uint i = 0; i < m_articles.Length; ++i)
            {
                if (m_articles[i].DisplayName == articleName)
                {
                    return m_articles[i];
                }
            }
            return null;
        }

        private EditorInventoryArticle@ FindArticleByRef(const CGameCtnArticleNodeArticle@ article)
        {
            for (uint i = 0; i < m_articles.Length; ++i)
            {
                if (m_articles[i].Article is article)
                {
                    return m_articles[i];
                }
            }
            return null;
        }

        private void UpdateFilteredList()
        {
            if (m_articlesFiltered.Length > 0)
            {
                m_articlesFiltered.RemoveRange(0, m_articlesFiltered.Length);
            }
            for (uint i = 0; i < m_articles.Length; ++i)
            {
                if (m_filterString == "" || m_articles[i].DisplayName.ToUpper().Contains(m_filterString.ToUpper()))
                {
                    m_articlesFiltered.InsertLast(m_articles[i]);
                }
            }
        }

        private void AddNewArticleToHistory(const CGameCtnArticleNodeArticle@ newArticle)
        {
            for (uint i = 0; i < m_articlesHistory.Length; ++i)
            {
                if (m_articlesHistory[i].Article is newArticle)
                {
                    m_articlesHistory.RemoveAt(i);
                    break;
                }
            }

            while (m_articlesHistory.Length >= Setting_CustomPalette_ArticleHistoryMax)
            {
                m_articlesHistory.RemoveAt(m_articlesHistory.Length-1);
            }

            auto article = FindArticleByRef(newArticle);
            if (article !is null)
            {
                m_articlesHistory.InsertAt(0, article);
            }
        }

        private void AddNewArticleToPalette(const CGameCtnArticleNodeArticle@ newArticle, const uint&in index)
        {
            if (index >= 0 && index < m_palettes.Length)
            {
                for (uint searchIndex = 0; searchIndex < m_palettes[index].Articles.Length; ++searchIndex)
                {
                    if (m_palettes[index].Articles[searchIndex].Article is newArticle)
                    {
                        return;
                    }
                }

                auto article = FindArticleByRef(newArticle);
                if (article !is null)
                {
                    m_palettes[index].Articles.InsertLast(article);
                }
            }
        }

        private void RemoveArticleFromPalette(const CGameCtnArticleNodeArticle@ newArticle, const uint&in index)
        {
            if (index >= 0 && index < m_palettes.Length)
            {
                for (uint searchIndex = 0; searchIndex < m_palettes[index].Articles.Length; ++searchIndex)
                {
                    if (m_palettes[index].Articles[searchIndex].Article is newArticle)
                    {
                        m_palettes[index].Articles.RemoveAt(searchIndex);
                        break;
                    }
                }
            }
        }

        private void DisplayInventoryArticlesTable(const string&in id, const EditorInventoryArticle@[]&in articles)
        {
            auto tableFlags = UI::TableFlags(int(UI::TableFlags::ScrollY));
            if (UI::BeginTable("CustomPaletteTable" + id, 1 /*cols*/, tableFlags))
            {
                CGameCtnArticleNodeArticle@ selectedArticle = cast<CGameCtnArticleNodeArticle>(Editor.PluginMapType.Inventory.CurrentSelectedNode);

                UI::ListClipper clipper(articles.Length);
                while (clipper.Step())
                {
                    int filterOffset = 0;
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; ++i)
                    {
                        UI::TableNextRow();

                        UI::TableNextColumn();
                        if (UI::Selectable(articles[i].DisplayName + "##" + tostring(i), articles[i].Article is selectedArticle))
                        {
                            SetCurrentArticle(articles[i]);
                        }
                    }
                }
                UI::EndTable();
            }
        }

        private void LoadPalettes()
        {
            Debug_EnterMethod("LoadPalettes");

            if (m_palettes.Length > 0)
            {
                Debug("Clearing palettes");
                m_palettes.RemoveRange(0, m_palettes.Length);
            }

            auto json = Json::FromFile(IO::FromStorageFolder("EditorFunction_CustomPalette.json"));

            auto palettes = json.Get("palettes", Json::Array());
            for (uint paletteIndex = 0; paletteIndex < palettes.Length; ++paletteIndex)
            {
                auto newPalette = EditorInventoryPalette();
                newPalette.Name = palettes[paletteIndex].Get("name", Json::Value("Palette"));

                auto articles = palettes[paletteIndex].Get("articles", Json::Array());
                for (uint articleIndex = 0; articleIndex < articles.Length; ++articleIndex)
                {
                    string articleName = articles[articleIndex];
                    auto articleRef = FindArticleByName(articleName);
                    if (articleRef !is null)
                    {
                        Debug("Found article with name: " + tostring(articleName));
                        newPalette.Articles.InsertLast(articleRef);
                    }
                }

                m_palettes.InsertLast(newPalette);
            }

            Debug_LeaveMethod();
        }

        private void SavePalettes()
        {
            auto json = Json::Object();

            auto palettes = Json::Array();
            for (uint paletteIndex = 0; paletteIndex < m_palettes.Length; ++paletteIndex)
            {
                auto palette = Json::Object();
                palette["name"] = m_palettes[paletteIndex].Name;

                auto articles = Json::Array();
                for (uint articleIndex = 0; articleIndex < m_palettes[paletteIndex].Articles.Length; ++articleIndex)
                {
                    articles.Add(Json::Value(m_palettes[paletteIndex].Articles[articleIndex].DisplayName));
                }
                palette["articles"] = articles;

                palettes.Add(palette);
            }

            json["palettes"] = palettes;
            Json::ToFile(IO::FromStorageFolder("EditorFunction_CustomPalette.json"), json);
        }
    }
}
