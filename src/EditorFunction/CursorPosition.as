
namespace EditorHelpers
{
    namespace Compatibility
    {
        void UpdateFreePosition(CGameCtnEditorFree@ editor, vec3&out pos)
        {
#if TMNEXT
            if (editor.Cursor.UseFreePos)
#else
            if (false)
#endif
            {
#if TMNEXT
                pos.x = editor.Cursor.FreePosInMap.x;
                pos.y = editor.Cursor.FreePosInMap.y;
                pos.z = editor.Cursor.FreePosInMap.z;
#endif
            }
            else
            {
                pos.x = float(editor.Cursor.Coord.x) * 32.0f;
                pos.y = float(editor.Cursor.Coord.y - 8) * 8.0f;
                pos.z = float(editor.Cursor.Coord.z) * 32.0f;
            }
        }

        bool EnableCursorPositionFunction()
        {
#if TMNEXT
#elif MP4
            Setting_CursorPosition_Enabled = false;
#endif
            return Setting_CursorPosition_Enabled;
        }

    }

    [Setting category="Functions" name="CursorPosition: Enabled" hidden]
    bool Setting_CursorPosition_Enabled = true;

    class CursorPosition : EditorHelpers::EditorFunction
    {
        private vec3 m_position;

        string Name() override { return "Cursor Position"; }
        bool Enabled() override { return Compatibility::EnableCursorPositionFunction(); }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_CursorPosition_Enabled = UI::Checkbox("Enabled", Setting_CursorPosition_Enabled);
            UI::BeginDisabled(!Setting_CursorPosition_Enabled);
            UI::TextWrapped("Displays the cursor position (x, y, z) in the map.");
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                m_position = vec3(0.0f, 0.0f, 0.0f);
            }
        }

        void Update(float) override
        {
            if (!Enabled() || Editor is null) return;
            Compatibility::UpdateFreePosition(Editor, m_position);
        }

        void RenderInterface_Info() override
        {
            if (!Enabled() || Editor is null) return;
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Current X, Y, Z position of the block/item cursor");
                UI::SameLine();
            }
            UI::Text(
                  Text::Format("%8.3f", m_position.x) + " "
                + Text::Format("%8.3f", m_position.y) + " "
                + Text::Format("%8.3f", m_position.z));
        }
    }
}
