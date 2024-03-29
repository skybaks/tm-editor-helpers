
namespace EditorHelpers
{
    namespace Compatibility
    {
        bool ItemContainsPodiumInfo(CGameItemModel@ itemModel)
        {
            bool containsPodiumInfo = false;
#if TMNEXT
            containsPodiumInfo = itemModel !is null && itemModel.PodiumClipList !is null;
#endif
            return containsPodiumInfo;
        }

        bool PodiumCountInvalid(const int count)
        {
#if TMNEXT
            return count < 1;
#else
            return count != 1;
#endif
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

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_PodiumReminder_Enabled = UI::Checkbox("Enabled", Setting_PodiumReminder_Enabled);
            UI::BeginDisabled(!Setting_PodiumReminder_Enabled);
            UI::TextWrapped("This function will keep track of the podiums in a map and generate notifications so"
                " you don't forget to place a podium.");

            Setting_PodiumReminder_NotificationEnabled = UI::Checkbox("Display a notification when map is saved", Setting_PodiumReminder_NotificationEnabled);

            UI::Text("Length to display notification (seconds)");
            UI::SameLine();
            float notificationLength = UI::InputFloat("##Setting_PodiumReminder_NotificationLength", Setting_PodiumReminder_NotificationLength);
            Setting_PodiumReminder_NotificationLength = Math::Min(25.0, Math::Max(1.0, notificationLength));
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("PodiumReminder::ReminderText");
            }

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

            if (Signal_MapFileUpdated())
            {
                m_podiumCount = GetPodiumCount();
                Debug("Podiums:" + tostring(m_podiumCount));
            }

            timerEnterEditorDelay.Update(dt);
            if (Signal_EnteredEditor())
            {
                timerEnterEditorDelay.StartNew();
                Debug("Restart entered editor time delay");
                m_podiumCount = GetPodiumCount();
                Debug("Podiums:" + tostring(m_podiumCount));
            }

            if (Signal_MapFileUpdated()
                && timerEnterEditorDelay.Complete()
                && Setting_PodiumReminder_NotificationEnabled
                && Compatibility::PodiumCountInvalid(m_podiumCount))
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

        void RenderInterface_MainWindow() override
        {
            if (!Enabled()) return;

            EditorHelpers::BeginHighlight("PodiumReminder::ReminderText");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Reminder to place a podium");
                UI::SameLine();
            }
            if (Compatibility::PodiumCountInvalid(m_podiumCount))
            {
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
            }
            else
            {
                UI::Text("\\$0f0");
                UI::SameLine();
                UI::Text("Podium Check: Valid");
            }
            EditorHelpers::EndHighlight();
        }

        private int GetPodiumCount()
        {
            Debug_EnterMethod("GetPodiumCount");
            int podiumCount = 0;

            if (Editor.Challenge !is null)
            {
                // Using preprocessor to skip looking for podiums in certain
                // games where we know they will not be
#if TMNEXT
                for (uint i = 0; i < Editor.Challenge.AnchoredObjects.Length; ++i)
                {
                    auto currentObject = Editor.Challenge.AnchoredObjects[i];
                    if (Compatibility::ItemContainsPodiumInfo(currentObject.ItemModel))
                    {
                        podiumCount += 1;
                        Debug("Adding podium to count for ITEM index:" + tostring(i) + " name:" + tostring(currentObject.ItemModel.Name));
                    }
                }
#else
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
#endif
            }

            Debug_LeaveMethod();
            return podiumCount;
        }
    }
}
