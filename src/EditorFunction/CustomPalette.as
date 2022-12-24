
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

        string Name() override { return "Custom Palette"; }
        bool Enabled() override { return Setting_CustomPalette_Enabled; }

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
            UI::EndTabBar();

            UI::End();
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

            CGameCtnArticleNodeArticle@ selectedArticle = cast<CGameCtnArticleNodeArticle>(Editor.PluginMapType.Inventory.CurrentSelectedNode);
            if (selectedArticle !is null && selectedArticle !is m_selectedArticlePrev)
            {
                AddNewArticleToHistory(selectedArticle);
            }
            @m_selectedArticlePrev = selectedArticle;

            Debug_LeaveMethod();
        }

        private void RecursiveAddInventoryArticle(CGameCtnArticleNode@ current, CGameEditorPluginMap::EPlaceMode placeMode)
        {
            Debug_EnterMethod("RecursiveAddInventoryArticle");

            CGameCtnArticleNodeDirectory@ currentDir = cast<CGameCtnArticleNodeDirectory>(current);
            if (currentDir !is null)
            {
                for (uint i = 0; i < currentDir.ChildNodes.Length; ++i)
                {
                    auto newDir = currentDir.ChildNodes[i];
                    RecursiveAddInventoryArticle(newDir, placeMode);
                }
            }
            else
            {
                CGameCtnArticleNodeArticle@ currentArt = cast<CGameCtnArticleNodeArticle>(current);
                if (currentArt !is null)
                {
                    string articleName = tostring(currentArt.Article.PageName) + tostring(currentArt.Article.NameOrDisplayName);
                    Debug("Add " + articleName);
                    m_articles.InsertLast(EditorInventoryArticle(articleName, currentArt, placeMode));
                }
            }

            Debug_LeaveMethod();
        }

        private void IndexInventory()
        {
            Debug_EnterMethod("IndexInventory");

            if (m_articles.Length > 0)
            {
                m_articles.RemoveRange(0, m_articles.Length);
            }

            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[0], CGameEditorPluginMap::EPlaceMode::Block);
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[3], CGameEditorPluginMap::EPlaceMode::Item);
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[4], CGameEditorPluginMap::EPlaceMode::Macroblock);

            Debug("Inventory Length: " + tostring(m_articles.Length));

            UpdateFilteredList();

            Debug_LeaveMethod();
        }

        private void SetCurrentArticle(const EditorInventoryArticle@ newArticle)
        {
            if (Editor.PluginMapType.PlaceMode != newArticle.PlaceMode)
            {
                Editor.PluginMapType.PlaceMode = newArticle.PlaceMode;
            }
            Editor.PluginMapType.Inventory.SelectArticle(newArticle.Article);
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

            for (uint i = 0; i < m_articles.Length; ++i)
            {
                if (m_articles[i].Article is newArticle)
                {
                    m_articlesHistory.InsertAt(0, m_articles[i]);
                    break;
                }
            }
        }

        private void DisplayInventoryArticlesTable(const string&in id, const EditorInventoryArticle@[]&in articles)
        {
            auto tableFlags = UI::TableFlags(/*int(UI::TableFlags::SizingFixedFit) |*/ int(UI::TableFlags::ScrollY));
            if (UI::BeginTable("CustomPaletteTable" + id, 1 /*cols*/, tableFlags))
            {
                UI::ListClipper clipper(articles.Length);
                while (clipper.Step())
                {
                    int filterOffset = 0;
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; ++i)
                    {
                        UI::TableNextRow();

                        UI::TableNextColumn();
                        if (UI::Selectable(articles[i].DisplayName + "##" + tostring(i), false))
                        {
                            SetCurrentArticle(articles[i]);
                        }
                    }
                }
                UI::EndTable();
            }
        }
    }
}
