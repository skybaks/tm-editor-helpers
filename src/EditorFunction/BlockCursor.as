
namespace EditorHelpers
{
    namespace HotkeyInterface
    {
        bool Enabled_BlockCursor()
        {
            return Setting_BlockCursor_Enabled;
        }

        void ToggleHideBlockCursor()
        {
            if (Setting_BlockCursor_Enabled)
            {
                Setting_BlockCursor_HideBlockCursor = !Setting_BlockCursor_HideBlockCursor;
            }
        }
    }

    [Setting category="Functions" name="BlockCursor: Enabled" hidden]
    bool Setting_BlockCursor_Enabled = true;
    [Setting category="Functions" name="BlockCursor: Hide Block Cursor" hidden]
    bool Setting_BlockCursor_HideBlockCursor = false;

    class BlockCursor : EditorHelpers::EditorFunction
    {
        private bool lastBlockCursorOff;

        string Name() override { return "Block Cursor"; }
        bool Enabled() override { return Setting_BlockCursor_Enabled; }
        bool SupportsPresets() override { return true; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");

            UI::BeginGroup();
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_BlockCursor_Enabled = UI::Checkbox("Enabled", Setting_BlockCursor_Enabled);
            UI::BeginDisabled(!Setting_BlockCursor_Enabled);
            UI::TextWrapped("Enables hiding/showing the colored box that surrounds the current block or item in your"
                " cursor.");
            Setting_BlockCursor_HideBlockCursor = UI::Checkbox("Block Cursor Hidden", Setting_BlockCursor_HideBlockCursor);
            UI::EndDisabled();
            UI::EndGroup();
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("BlockCursor::HideCursor");
            }

            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                lastBlockCursorOff = false;
            }
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            EditorHelpers::BeginHighlight("BlockCursor::HideCursor");
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Hide/Show block cursor box");
                UI::SameLine();
            }
            Setting_BlockCursor_HideBlockCursor = UI::Checkbox("Block Cursor Hidden", Setting_BlockCursor_HideBlockCursor);
            EditorHelpers::EndHighlight();
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            if (Setting_BlockCursor_HideBlockCursor)
            {
                Editor.Cursor.CursorBox.IsShowQuads = false;
                Editor.Cursor.CursorBox.IsShowLines = false;
            }
            else if (lastBlockCursorOff && !Setting_BlockCursor_HideBlockCursor)
            {
                Editor.Cursor.CursorBox.IsShowQuads = true;
                Editor.Cursor.CursorBox.IsShowLines = true;
            }
            lastBlockCursorOff = Setting_BlockCursor_HideBlockCursor;
        }

        void SerializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            json["cursor_hidden"] = Setting_BlockCursor_HideBlockCursor;
        }

        void DeserializePresets(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_cursor_hidden", Json::Value(true))))
            {
                Setting_BlockCursor_HideBlockCursor = bool(json.Get("cursor_hidden", Json::Value(false)));
            }
        }

        void RenderPresetValues(Json::Value@ json) override
        {
            if (!Enabled()) { return; }
            if (bool(json.Get("enable_cursor_hidden", Json::Value(true))))
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Block Cursor Hidden");
                UI::TableNextColumn();
                UI::Text(tostring(bool(json.Get("cursor_hidden", Json::Value(false)))));
            }
        }

        bool RenderPresetEnables(Json::Value@ json, bool defaultValue, bool forceValue) override
        {
            bool changed = false;
            if (!Enabled()) { return changed; }
            if (JsonCheckboxChanged(json, "enable_cursor_hidden", "Cursor Hidden", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("BlockCursor::HideCursor");
            }
            return changed;
        }
    }
}
