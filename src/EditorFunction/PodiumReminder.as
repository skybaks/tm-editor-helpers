
namespace EditorHelpers
{
    [Setting category="Functions" name="PodiumReminder: Enabled" hidden]
    bool Setting_PodiumReminder_Enabled = true;

    class PodiumReminder : EditorHelpers::EditorFunction
    {
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

            if (Signal_MapFileUpdated())
            {
                int podiums = GetPodiumCount();
                Debug("Podiums:" + tostring(podiums));
            }

            // notification methods
            // ALWAYS (if function enabled) - display in ui window
            // * UI::Notification with message - time displayed?
            // * UI dialog appearing in center screen with message

            Debug_LeaveMethod();
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

                // Get Podiums in Items - Maybe needs compatibility?
                for (uint i = 0; i < Editor.Challenge.AnchoredObjects.Length; ++i)
                {
                    auto currentObject = Editor.Challenge.AnchoredObjects[i];
                    if (currentObject.ItemModel !is null
                        && currentObject.ItemModel.PodiumInfo !is null)
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
