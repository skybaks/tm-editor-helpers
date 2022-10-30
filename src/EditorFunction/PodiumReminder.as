
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
    [Setting category="Functions" name="PodiumReminder: NotificationEnabled" hidden]
    bool Setting_PodiumReminder_NotificationEnabled = true;
    [Setting category="Functions" name="PodiumReminder: NotificationLength" hidden]
    float Setting_PodiumReminder_NotificationLength = 8.0f;

    class PodiumReminder : EditorHelpers::EditorFunction
    {
        private int m_podiumCount = 0;
        private EditorHelpers::CountdownTimer timerEnterEditorDelay;

        string Name() override { return "Podium Reminder"; }
        bool Enabled() override { return Setting_PodiumReminder_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_PodiumReminder_Enabled = UI::Checkbox("Enabled", Setting_PodiumReminder_Enabled);
            UI::BeginDisabled(!Setting_PodiumReminder_Enabled);
            UI::TextWrapped("This function will keep track of the podiums in a map and generate notifications so you don't forget to place a podium.");

            Setting_PodiumReminder_NotificationEnabled = UI::Checkbox("Display a notification when map is saved", Setting_PodiumReminder_NotificationEnabled);

            UI::Text("Length to display notification (seconds)");
            UI::SameLine();
            float notificationLength = UI::InputFloat("##Setting_PodiumReminder_NotificationLength", Setting_PodiumReminder_NotificationLength);
            Setting_PodiumReminder_NotificationLength = Math::Min(25.0, Math::Max(1.0, notificationLength));

            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (FirstPass)
            {
                timerEnterEditorDelay.MaxTime = 15.0f;
            }
        }

        void Update(float dt) override
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

            timerEnterEditorDelay.Update(dt);
            if (Signal_EnteredEditor())
            {
                timerEnterEditorDelay.StartNew();
                Debug("Restart entered editor time delay");
            }

            if (Signal_MapFileUpdated()
                && timerEnterEditorDelay.Complete()
                && Setting_PodiumReminder_NotificationEnabled
                && m_podiumCount != 1)
            {
                string title = "Editor Helpers: " + Name();
                int displayTime = int(Setting_PodiumReminder_NotificationLength * 1000.0f);
                string settingsText = "\n\n(Configure this notification in the settings)";
                if (m_podiumCount < 1)
                {
                    UI::ShowNotification(
                        title,
                        "No podium in the map. Don't forget to place a podium!" + settingsText,
                        displayTime
                    );
                }
                else if (m_podiumCount > 1)
                {
                    UI::ShowNotification(
                        title,
                        "Too many podium's in the map (" + tostring(m_podiumCount) + "). Place only one podium!" + settingsText,
                        displayTime
                    );
                }
            }

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
