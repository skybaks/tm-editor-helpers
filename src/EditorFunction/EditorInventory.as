
namespace EditorHelpers
{
    class EditorInventoryArticle
    {
        EditorInventoryArticle()
        {
            DisplayName = "";
            @Article = null;
            @ArticleAlt = null;
            PlaceMode = CGameEditorPluginMap::EPlaceMode::Unknown;
        }

        EditorInventoryArticle(const string&in name, CGameCtnArticleNodeArticle@ article, CGameCtnArticleNodeArticle@ articleAlt, CGameEditorPluginMap::EPlaceMode placeMode)
        {
            DisplayName = name;
            @Article = article;
            @ArticleAlt = articleAlt;
            PlaceMode = placeMode;
        }

        string DisplayName;
        CGameCtnArticleNodeArticle@ Article;
        CGameCtnArticleNodeArticle@ ArticleAlt;
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
        bool EnableEditorInventoryFunction()
        {
#if TMNEXT
#else
            Setting_EditorInventory_Enabled = false;
#endif
            return Setting_EditorInventory_Enabled;
        }

        bool IsBlockMode(CGameEditorPluginMap::EPlaceMode mode)
        {
            return mode == CGameEditorPluginMap::EPlaceMode::Block
                || mode == CGameEditorPluginMap::EPlaceMode::GhostBlock
#if TMNEXT
                || mode == CGameEditorPluginMap::EPlaceMode::FreeBlock
#endif
                ;
        }

        bool IsMacroblockMode(CGameEditorPluginMap::EPlaceMode mode)
        {
            return mode == CGameEditorPluginMap::EPlaceMode::Macroblock
#if TMNEXT
                || mode == CGameEditorPluginMap::EPlaceMode::FreeMacroblock
#endif
                ;
        }
    }

    namespace HotkeyInterface
    {
        bool g_EditorInventory_QuickswitchPreviousTrigger = false;

        bool Enabled_EditorInventory()
        {
            return Setting_EditorInventory_Enabled;
        }

        void QuickswitchPreviousArticle()
        {
            if (Setting_EditorInventory_Enabled)
            {
                g_EditorInventory_QuickswitchPreviousTrigger = true;
            }
        }
    }

    [Setting category="Functions" name="EditorInventory: Enabled" hidden]
    bool Setting_EditorInventory_Enabled = true;
    [Setting category="Functions" name="EditorInventory: Window Visible" hidden]
    bool Setting_EditorInventory_WindowVisible = true;
    [Setting category="Functions" name="EditorInventory: Article History Max" hidden]
    uint Setting_EditorInventory_ArticleHistoryMax = 10;

    [Setting category="Functions" name="EditorInventory: Persist Palette Index" hidden]
    uint Setting_EditorInventory_PersistPaletteIndex = 0;

    class EditorInventory : EditorHelpers::EditorFunction
    {
        private array<EditorInventoryArticle@> m_articles;
        private array<EditorInventoryArticle@> m_articlesFiltered;
        private array<EditorInventoryArticle@> m_articlesHistory;
        private string m_filterString;
        private string m_filterStringPrev;
        private CGameCtnArticleNodeArticle@ m_selectedArticlePrev;
        private array<EditorInventoryPalette@> m_palettes;
        private uint m_selectedPaletteIndex;
        private int m_forcePaletteIndex;
        private string m_paletteNewName;
        private bool m_deleteConfirm;
        private PaletteRandomizerMode m_paletteRandomize;
        private uint64 m_parallelLoadYieldTime; // This signal is used yield the IndexInventory coroutine at reasonable times
        private uint m_loadedInventoryArticleCount;
        private bool m_loadingInventory;
        private bool m_loadingInventoryPrev;

        string Name() override { return "Editor Inventory"; }
        bool Enabled() override { return Compatibility::EnableEditorInventoryFunction(); }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_EditorInventory_Enabled = UI::Checkbox("Enabled", Setting_EditorInventory_Enabled);
            UI::BeginDisabled(!Setting_EditorInventory_Enabled);
            UI::TextWrapped("This function opens an additional display window that contains a searchable list of all"
                " blocks, items, and macroblocks in the editor. It also shows all recent blocks, items, and"
                " macroblocks used. You can also create your own custom sets and place from a random selection within"
                " a set."
            );

            Setting_EditorInventory_WindowVisible = UI::Checkbox("Show Additional Window", Setting_EditorInventory_WindowVisible);
            Setting_EditorInventory_ArticleHistoryMax = Math::Clamp(UI::InputInt("Max number of recent blocks/items/macroblocks", Setting_EditorInventory_ArticleHistoryMax), 5, 100);
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
                HotkeyInterface::g_EditorInventory_QuickswitchPreviousTrigger = false;
                m_forcePaletteIndex = -1;
                m_deleteConfirm = false;
                m_paletteRandomize = PaletteRandomizerMode::NONE;
                m_loadedInventoryArticleCount = 0;
                m_loadingInventory = false;
            }
        }

        void RenderInterface_ChildWindow() override
        {
            if (!Enabled() || Editor is null || m_articles.Length == 0 || !Setting_EditorInventory_WindowVisible)
            {
                return;
            }

            UI::SetNextWindowSize(580, 350, UI::Cond::FirstUseEver);
            int windowFlags = UI::WindowFlags::NoCollapse | UI::WindowFlags::MenuBar;
            UI::Begin(g_windowName + ": " + Name(), Setting_EditorInventory_WindowVisible, windowFlags);

            EditorHelpers::WindowMenuBar::RenderDefaultMenus();

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
                    if (UI::Button(Icons::Kenney::Plus + " New Palette"))
                    {
                        m_palettes.InsertLast(EditorInventoryPalette());
                        m_forcePaletteIndex = m_palettes.Length - 1;
                    }
                    UI::BeginDisabled(m_deleteConfirm);
                    UI::SameLine();
                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Delete the active custom palette");
                        UI::SameLine();
                    }
                    if (UI::Button(Icons::Kenney::TrashAlt + " Delete Selected Palette"))
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
                                m_forcePaletteIndex = m_selectedPaletteIndex != 0 ? m_selectedPaletteIndex - 1 : 0;
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
                        m_forcePaletteIndex = m_selectedPaletteIndex;

                        SavePalettes();
                    }

                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Add or remove elements from the active custom palette");
                        UI::SameLine();
                    }
                    if (UI::Button(Icons::Kenney::Plus + " Add") && m_articlesHistory.Length > 0)
                    {
                        AddNewArticleToPalette(m_articlesHistory[0].Article, m_selectedPaletteIndex);

                        SavePalettes();
                    }
                    UI::SameLine();
                    if (UI::Button(Icons::Kenney::Minus + " Remove") && m_articlesHistory.Length > 0)
                    {
                        RemoveArticleFromPalette(m_articlesHistory[0].Article, m_selectedPaletteIndex);

                        SavePalettes();
                    }

                    UI::SameLine();
                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Shift selected object up and down within the current active palette");
                        UI::SameLine();
                    }
                    if (UI::Button(Icons::Kenney::ArrowTop + " Shift Up") && m_articlesHistory.Length > 0)
                    {
                        ShiftArticleInPalette(m_articlesHistory[0].Article, m_selectedPaletteIndex, shiftUp: true);
                        SavePalettes();
                    }
                    UI::SameLine();
                    if (UI::Button(Icons::Kenney::ArrowBottom + " Shift Down") && m_articlesHistory.Length > 0)
                    {
                        ShiftArticleInPalette(m_articlesHistory[0].Article, m_selectedPaletteIndex, shiftUp: false);
                        SavePalettes();
                    }

                    if (settingToolTipsEnabled)
                    {
                        EditorHelpers::HelpMarker("Shift active palette left and right in the tab order");
                        UI::SameLine();
                    }
                    if (UI::Button(Icons::Kenney::ArrowLeft + " Shift Left"))
                    {
                        ShiftPalette(m_selectedPaletteIndex, shiftUp: true);
                        SavePalettes();
                    }
                    UI::SameLine();
                    if (UI::Button(Icons::Kenney::ArrowRight + " Shift Right"))
                    {
                        ShiftPalette(m_selectedPaletteIndex, shiftUp: false);
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
                    UI::TabItemFlags flags = int(paletteIndex) == m_forcePaletteIndex ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None;
                    if (UI::BeginTabItem(m_palettes[paletteIndex].Name + "##" + tostring(paletteIndex), flags))
                    {
                        m_selectedPaletteIndex = paletteIndex;

                        DisplayInventoryArticlesTable("Palette##" + tostring(paletteIndex), m_palettes[paletteIndex].Articles);
                        UI::EndTabItem();
                    }
                }
                m_forcePaletteIndex = -1;
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

            if (UI::MenuItem(Icons::Cube + " " + Name(), selected: Setting_EditorInventory_WindowVisible))
            {
                Setting_EditorInventory_WindowVisible = !Setting_EditorInventory_WindowVisible;
            }
        }

        void Update(float) override
        {
            Debug_EnterMethod("Update");
            if (!Enabled() || Editor is null || Editor.PluginMapType is null)
            {
                Debug_LeaveMethod();
                return;
            }
            else
            {
            }

            if (!m_loadingInventory && (Signal_EnteredEditor() || m_loadedInventoryArticleCount != GetArticleCount()))
            {
                m_loadingInventory = true;
                m_loadedInventoryArticleCount = GetArticleCount();

                // COROUTINE USAGE!
                startnew(CoroutineFunc(IndexInventory));
            }

            if (Signal_BlockItemPlaced() && m_paletteRandomize != PaletteRandomizerMode::NONE
                && Setting_EditorInventory_WindowVisible
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
                Debug("Selected article has changed");
                AddNewArticleToHistory(selectedArticle);
            }
            @m_selectedArticlePrev = selectedArticle;

            if (HotkeyInterface::g_EditorInventory_QuickswitchPreviousTrigger && m_articlesHistory.Length > 1)
            {
                SetCurrentArticle(m_articlesHistory[1]);
            }
            HotkeyInterface::g_EditorInventory_QuickswitchPreviousTrigger = false;

            if (!m_loadingInventory && m_loadingInventoryPrev)
            {
                m_forcePaletteIndex = Setting_EditorInventory_PersistPaletteIndex;
                Debug("Force palette to persist number: " + tostring(m_forcePaletteIndex));
            }
            else if (!m_loadingInventory)
            {
                Setting_EditorInventory_PersistPaletteIndex = m_selectedPaletteIndex;
            }
            m_loadingInventoryPrev = m_loadingInventory;

            Debug_LeaveMethod();
        }


        // PARALLEL METHODS BEGIN
        // - Be careful about calling these methods from the main thread. They
        //      are designed to yield at specific intervals and calling them
        //      from the main thread could impact behavior of other classes.

        private bool VerifyInventoryItem(CGameCtnArticleNode@ rootNode, const string&in check)
        {
            Debug_EnterMethod("VerifyInventoryItem");
            bool success = false;

            CGameCtnArticleNodeDirectory@ rootNodeDir = cast<CGameCtnArticleNodeDirectory>(rootNode);
            if (rootNodeDir !is null && rootNodeDir.ChildNodes.Length > 0)
            {
                success = rootNodeDir.ChildNodes[0].NodeName == check;
                Debug("Compared: rootNodeDir.ChildNodes[0].NodeName=" + rootNodeDir.ChildNodes[0].NodeName + "  ==  check=" + check);
            }

            Debug_LeaveMethod();
            return success;
        }

        private void RecursiveAddInventoryArticle(CGameCtnArticleNode@ current, const string&in name, CGameEditorPluginMap::EPlaceMode placeMode, CGameCtnArticleNode@ sister)
        {
            Debug_EnterMethod("RecursiveAddInventoryArticle");

            if ((m_parallelLoadYieldTime + 10) < Time::Now)
            {
                Debug("*** YIELDING NOW *** : Time::Now-" + tostring(Time::Now) + " m_parallelLoadYieldTime-" + tostring(m_parallelLoadYieldTime));
                yield();
                m_parallelLoadYieldTime = Time::Now;
            }

            // Since yield will skip us to the next frame we must be aware that
            // the user could choose to exit the editor in the middle of this
            // process! If that does happen we should break out and exit
            if (Editor is null
                || Editor.PluginMapType is null
                || Editor.PluginMapType.Inventory is null)
            {
                Debug("Null reference! aborting index after yield");
                Debug_LeaveMethod(); return;
            }

            CGameCtnArticleNodeDirectory@ currentDir = cast<CGameCtnArticleNodeDirectory>(current);
            CGameCtnArticleNodeDirectory@ sisterDir = cast<CGameCtnArticleNodeDirectory>(sister);
            if (currentDir !is null)
            {
                for (uint i = 0; i < currentDir.ChildNodes.Length; ++i)
                {
                    CGameCtnArticleNode@ newDir = currentDir.ChildNodes[i];
                    CGameCtnArticleNode@ newSisterDir = null;
                    if (sisterDir !is null && i < sisterDir.ChildNodes.Length)
                    {
                        @newSisterDir = sisterDir.ChildNodes[i];

                        if (tostring(newSisterDir.NodeName) != tostring(newDir.NodeName))
                        {
                            Debug("newSisterDir has invalid node name");
                            @newSisterDir = null;
                        }
                    }

                    if (newDir.IsDirectory)
                    {
                        RecursiveAddInventoryArticle(newDir, name + "/" + newDir.NodeName, placeMode, newSisterDir);
                        Debug("Returned from RecursiveAddInventoryArticle");

                        // If we are aborting due to the leaving the editor
                        // then we need to get out of this loop ASAP because
                        // all the references to inventory objects are
                        // potential crashes
                        if (Editor is null
                            || Editor.PluginMapType is null
                            || Editor.PluginMapType.Inventory is null)
                        {
                            Debug("Null reference! aborting index after returned from RecursiveAddInventoryArticle");
                            Debug_LeaveMethod(); return;
                        }
                    }
                    else
                    {
                        CGameCtnArticleNodeArticle@ currentArt = cast<CGameCtnArticleNodeArticle>(newDir);
                        CGameCtnArticleNodeArticle@ currentSisterArt = cast<CGameCtnArticleNodeArticle>(newSisterDir);
                        if (currentArt !is null)
                        {
                            string articleName = name + "/" + currentArt.NodeName;
                            if (currentArt.NodeName.Contains("\\"))
                            {
                                auto splitPath = tostring(currentArt.NodeName).Split("\\");
                                if (splitPath.Length > 0)
                                {
                                    articleName = name + "/" + splitPath[splitPath.Length-1];
                                }
                            }

                            if (currentSisterArt !is null && tostring(currentSisterArt.NodeName) != tostring(currentArt.NodeName))
                            {
                                Debug("currentSisterArt has invalid node name");
                                @currentSisterArt = null;
                            }

                            m_articles.InsertLast(EditorInventoryArticle(articleName, currentArt, currentSisterArt, placeMode));
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

            if (Editor is null
                || Editor.PluginMapType is null
                || Editor.PluginMapType.Inventory is null)
            {
                Debug("Null reference! aborting index");
                Debug_LeaveMethod();
                return;
            }

            if (!VerifyInventoryItem(Editor.PluginMapType.Inventory.RootNodes[0], "Roads"))
            {
                Debug("Error verifying blocks integrity. aborting index");
                Debug_LeaveMethod();
                return;
            }
            if (!VerifyInventoryItem(Editor.PluginMapType.Inventory.RootNodes[1], "Roads"))
            {
                Debug("Error verifying blocks integrity. aborting index");
                Debug_LeaveMethod();
                return;
            }
            if (!VerifyInventoryItem(Editor.PluginMapType.Inventory.RootNodes[3], "Official"))
            {
                Debug("Error verifying items integrity. aborting index");
                Debug_LeaveMethod();
                return;
            }
            if (!VerifyInventoryItem(Editor.PluginMapType.Inventory.RootNodes[4], "Official"))
            {
                Debug("Error verifying macroblocks integrity. aborting index");
                Debug_LeaveMethod();
                return;
            }

            Debug("Loading inventory blocks");
            // Index 0 is is used for normal block mode while Index 1 is used
            // for ghost block mode and free block mode. They are the same
            // blocks but the articles have different pointers.
            m_parallelLoadYieldTime = Time::Now;
            if (Editor is null
                || Editor.PluginMapType is null
                || Editor.PluginMapType.Inventory is null
                || Editor.PluginMapType.Inventory.RootNodes.Length < 2)
            {
                Debug("Editor is null. Exiting index");
                Debug_LeaveMethod(); return;
            }
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[0], "Block", CGameEditorPluginMap::EPlaceMode::Block, Editor.PluginMapType.Inventory.RootNodes[1]);

            Debug("Loading inventory items");
            if (Editor is null
                || Editor.PluginMapType is null
                || Editor.PluginMapType.Inventory is null
                || Editor.PluginMapType.Inventory.RootNodes.Length < 4)
            {
                Debug("Editor is null. Exiting index");
                Debug_LeaveMethod(); return;
            }
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[3], "Item", CGameEditorPluginMap::EPlaceMode::Item, null);

            Debug("Loading inventory macroblocks");
            if (Editor is null
                || Editor.PluginMapType is null
                || Editor.PluginMapType.Inventory is null
                || Editor.PluginMapType.Inventory.RootNodes.Length < 5)
            {
                Debug("Editor is null. Exiting index");
                Debug_LeaveMethod(); return;
            }
            RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[4], "Macroblock", CGameEditorPluginMap::EPlaceMode::Macroblock, null);

            Debug("Inventory total length: " + tostring(m_articles.Length));

            UpdateFilteredList();
            LoadPalettes();

            m_loadingInventory = false;

            Debug_LeaveMethod();
        }

        // PARALLEL METHODS END


        private bool PlaceModeIncompatible(CGameEditorPluginMap::EPlaceMode modeCurr, CGameEditorPluginMap::EPlaceMode modeNew)
        {
            bool incompatible = modeCurr != modeNew;
            if ((Compatibility::IsBlockMode(modeCurr) && Compatibility::IsBlockMode(modeNew))
                || (Compatibility::IsMacroblockMode(modeCurr) && Compatibility::IsMacroblockMode(modeNew)))
            {
                incompatible = false;
            }
            return incompatible;
        }

        private void SetCurrentArticle(const EditorInventoryArticle@ newArticle)
        {
            Debug_EnterMethod("SetCurrentArticle");
            if (newArticle is null)
            {
                Debug("New EditorInventoryArticle is null");
                Debug_LeaveMethod();
                return;
            }

            if (PlaceModeIncompatible(Editor.PluginMapType.PlaceMode, newArticle.PlaceMode))
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
            Debug_EnterMethod("FindArticleByRef");

            for (uint i = 0; i < m_articles.Length; ++i)
            {
                if (m_articles[i].Article is article || m_articles[i].ArticleAlt is article)
                {
                    Debug("Found the article");

                    Debug_LeaveMethod();
                    return m_articles[i];
                }
            }

            Debug("Article not found");

            Debug_LeaveMethod();
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
            Debug_EnterMethod("AddNewArticleToHistory");

            for (uint i = 0; i < m_articlesHistory.Length; ++i)
            {
                if (m_articlesHistory[i].Article is newArticle)
                {
                    Debug("Article already present in history-- remove old instance");
                    m_articlesHistory.RemoveAt(i);
                    break;
                }
            }

            while (m_articlesHistory.Length >= Setting_EditorInventory_ArticleHistoryMax)
            {
                Debug("History too long-- remove one from end");
                m_articlesHistory.RemoveAt(m_articlesHistory.Length-1);
            }

            auto article = FindArticleByRef(newArticle);
            if (article !is null)
            {
                m_articlesHistory.InsertAt(0, article);
            }

            Debug_LeaveMethod();
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

        private void ShiftArticleInPalette(const CGameCtnArticleNodeArticle@ newArticle, const uint&in index, bool shiftUp)
        {
            if (index >= 0 && index < m_palettes.Length)
            {
                for (uint searchIndex = 0; searchIndex < m_palettes[index].Articles.Length; ++searchIndex)
                {
                    if (m_palettes[index].Articles[searchIndex].Article is newArticle)
                    {
                        auto article = FindArticleByRef(newArticle);
                        if (article !is null)
                        {
                            int newIndex = shiftUp ? int(searchIndex) - 1 : int(searchIndex) + 1;
                            newIndex = Math::Clamp(newIndex, 0, m_palettes[index].Articles.Length - 1);
                            if (newIndex != int(searchIndex))
                            {
                                m_palettes[index].Articles.RemoveAt(searchIndex);
                                m_palettes[index].Articles.InsertAt(newIndex, article);
                            }
                        }
                        break;
                    }
                }
            }
        }

        private void ShiftPalette(uint index, bool shiftUp)
        {
            if (index >= 0 && index < m_palettes.Length)
            {
                int newIndex = shiftUp ? int(index) - 1 : int(index) + 1;
                newIndex = Math::Clamp(newIndex, 0, m_palettes.Length - 1);
                if (newIndex != int(index))
                {
                    auto@ palette = m_palettes[index];
                    m_palettes.RemoveAt(index);
                    m_palettes.InsertAt(newIndex, palette);
                    m_forcePaletteIndex = newIndex;
                }
            }
        }

        private void DisplayInventoryArticlesTable(const string&in id, const EditorInventoryArticle@[]&in articles)
        {
            if (!m_loadingInventory)
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
            else
            {
                UI::Text(Icons::Hourglass + " Loading...");
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

            if (IO::FileExists(IO::FromStorageFolder("EditorFunction_CustomPalette.json")))
            {
                Debug("Renaming legacy palettes file");
                IO::Move(IO::FromStorageFolder("EditorFunction_CustomPalette.json"), IO::FromStorageFolder("EditorFunction_EditorInventory.json"));
            }

            auto json = Json::FromFile(IO::FromStorageFolder("EditorFunction_EditorInventory.json"));

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
            Json::ToFile(IO::FromStorageFolder("EditorFunction_EditorInventory.json"), json);
        }

        private uint GetArticleCount()
        {
            uint count = 0;
            auto chapters = GetApp().GlobalCatalog.Chapters;
            if (chapters.Length > 3)
            {
                count = chapters[3].Articles.Length;
            }
            return count;
        }
    }
}
