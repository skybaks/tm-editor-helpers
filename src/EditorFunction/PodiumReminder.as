
namespace EditorHelpers
{
    namespace Compatibility
    {
        bool ItemContainsPodiumInfo(CGameItemModel@ itemModel)
        {
            bool containsPodiumInfo = false;
#if TMNEXT
            containsPodiumInfo = itemModel !is null && itemModel.PodiumInfo !is null;
#endif
            return containsPodiumInfo;
        }
    }

    [Setting category="Functions" name="PodiumReminder: Enabled" hidden]
    bool Setting_PodiumReminder_Enabled = true;

    class PodiumReminder : EditorHelpers::EditorFunction
    {
        private int m_podiumCount = 0;

        string Name() override { return "Podium Reminder"; }
        bool Enabled() override { return Setting_PodiumReminder_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_PodiumReminder_Enabled = UI::Checkbox("Enabled", Setting_PodiumReminder_Enabled);
            UI::BeginDisabled(!Setting_PodiumReminder_Enabled);
            UI::TextWrapped("This function will generate a reminder when you save so that you dont forget to place a podium.");
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled()) return;
        }

        void Update(float) override
        {
            Debug_EnterMethod("Update");
            if (!Enabled() || Editor is null)
            {
                Debug_LeaveMethod();
                return;
            }

            if (Signal_BlockItemPlaced() || Signal_BlockItemRemoved())
            {
                m_podiumCount = GetPodiumCount();
                Debug("Podiums:" + tostring(m_podiumCount));
            }

            // notification methods
            // ALWAYS (if function enabled) - display in ui window
            // * UI::Notification with message - time displayed?
            // * UI dialog appearing in center screen with message

            Debug_LeaveMethod();
        }

        void RenderInterface_Info() override
        {
            if (!Enabled()) return;
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Reminder to place a podium");
                UI::SameLine();
            }
            if (m_podiumCount < 1)
            {
                UI::Text("\\$f00");
                UI::SameLine();
                UI::Text("Podium Check: No podiums");
            }
            else if (m_podiumCount > 1)
            {
                UI::Text("\\$f00");
                UI::SameLine();
                UI::Text("Podium Check: Too many (" + tostring(m_podiumCount) + ")");
            }
            else
            {
                UI::Text("\\$0f0");
                UI::SameLine();
                UI::Text("Podium Check: Valid");
            }
        }

        private int GetPodiumCount()
        {
            Debug_EnterMethod("GetPodiumCount");
            int podiumCount = 0;

            if (Editor.Challenge !is null)
            {
                for (uint i = 0; i < Editor.Challenge.Blocks.Length; ++i)
                {
                    auto currentBlock = Editor.Challenge.Blocks[i];
                    if (currentBlock.BlockModel !is null
                        && currentBlock.BlockModel.PodiumInfo !is null)
                    {
                        podiumCount += 1;
                        Debug("Adding podium to count for BLOCK index:" + tostring(i) + " name:" + tostring(currentBlock.BlockModel.Name));
                    }
                }

                for (uint i = 0; i < Editor.Challenge.AnchoredObjects.Length; ++i)
                {
                    auto currentObject = Editor.Challenge.AnchoredObjects[i];
                    if (Compatibility::ItemContainsPodiumInfo(currentObject.ItemModel))
                    {
                        podiumCount += 1;
                        Debug("Adding podium to count for ITEM index:" + tostring(i) + " name:" + tostring(currentObject.ItemModel.Name));
                    }
                }
            }

            Debug_LeaveMethod();
            return podiumCount;
        }
    }
}
