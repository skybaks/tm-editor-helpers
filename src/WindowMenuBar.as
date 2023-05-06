
namespace EditorHelpers
{
    namespace WindowMenuBar
    {
        void RenderDefaultMenus()
        {
            if (UI::BeginMenuBar())
            {
                if (UI::BeginMenu("Windows"))
                {
                    RenderWindowsMenuItems();
                    UI::EndMenu();
                }

                if (UI::BeginMenu("Help"))
                {
                    RenderHelpMenuItems();
                    UI::EndMenu();
                }

                UI::EndMenuBar();
            }
        }

        void RenderWindowsMenuItems()
        {
            if (UI::MenuItem(Icons::PuzzlePiece + " Main Window", selected: Setting_WindowVisible))
            {
                Setting_WindowVisible = !Setting_WindowVisible;
            }

            for (uint index = 0; index < g_functions.Length; index++)
            {
                g_functions[index].RenderInterface_MenuItem();
            }
        }

        void RenderHelpMenuItems()
        {
            if (UI::MenuItem(Icons::Github + " Github Wiki"))
            {
                OpenBrowserURL("https://github.com/skybaks/tm-editor-helpers/wiki");
            }

            if (UI::MenuItem(Icons::Bug + " Report a Bug"))
            {
                OpenBrowserURL("https://github.com/skybaks/tm-editor-helpers/issues");
            }

            UI::Separator();

            if (UI::MenuItem(Icons::InfoCircle + " About"))
            {
                Setting_About_WindowVisible = true;
            }
        }
    }
}
