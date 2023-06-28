
namespace EditorHelpers
{
    class BlockCursorPreset : EditorFunctionPresetBase
    {
        bool EnableCursorHidden;
        bool CursorHidden;

        BlockCursorPreset()
        {
            super("Block Cursor");
        }

        Json::Value@ ToJson() override
        {
            m_json["enable_cursor_hidden"] = EnableCursorHidden;
            m_json["cursor_hidden"] = CursorHidden;
            return m_json;
        }

        void FromJson(const Json::Value@ json) override
        {
            EnableCursorHidden = json.Get("enable_cursor_hidden", Json::Value(true));
            CursorHidden = json.Get("cursor_hidden", Json::Value(false));
        }
    }

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

    class BlockCursor : EditorHelpers::EditorFunction, EditorFunctionPresetInterface
    {
        private bool lastBlockCursorOff;

        string Name() override { return "Block Cursor"; }
        bool Enabled() override { return Setting_BlockCursor_Enabled; }

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

        void RenderInterface_MainWindow() override
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

        // EditorFunctionPresetInterface
        EditorFunctionPresetBase@ CreatePreset() override { return BlockCursorPreset(); }

        void UpdatePreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            BlockCursorPreset@ preset = cast<BlockCursorPreset>(data);
            if (preset is null) { return; }
            preset.CursorHidden = Setting_BlockCursor_HideBlockCursor;
        }

        void ApplyPreset(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            BlockCursorPreset@ preset = cast<BlockCursorPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableCursorHidden)
            {
                Setting_BlockCursor_HideBlockCursor = preset.CursorHidden;
            }
        }

        void RenderPresetValues(EditorFunctionPresetBase@ data) override
        {
            if (!Enabled()) { return; }
            BlockCursorPreset@ preset = cast<BlockCursorPreset>(data);
            if (preset is null) { return; }
            if (preset.EnableCursorHidden)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("Block Cursor Hidden");
                UI::TableNextColumn();
                UI::Text(tostring(preset.CursorHidden));
            }
        }

        bool RenderPresetEnables(EditorFunctionPresetBase@ data, bool defaultValue, bool forceValue) override
        {
            if (!Enabled()) { return false; }
            BlockCursorPreset@ preset = cast<BlockCursorPreset>(data);
            if (preset is null) { return false; }

            bool changed = false;
            if (ForcedCheckbox(preset.EnableCursorHidden, preset.EnableCursorHidden, "Cursor Hidden", defaultValue, forceValue)) { changed = true; }
            if (UI::IsItemHovered())
            {
                EditorHelpers::SetHighlightId("BlockCursor::HideCursor");
            }
            return changed;
        }
    }
}
