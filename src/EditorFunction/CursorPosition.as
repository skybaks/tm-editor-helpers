
namespace EditorHelpers
{
    [Setting category="Functions" name="CursorPosition: Enabled" hidden]
    bool Setting_CursorPosition_Enabled = true;

    class CursorPosition : EditorHelpers::EditorFunction
    {
        private vec3 m_position;

        string Name() override { return "Cursor Position"; }
        bool Enabled() override { return Setting_CursorPosition_Enabled; }

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
            if (Editor.Cursor.UseFreePos)
            {
                m_position = Editor.Cursor.FreePosInMap;
            }
            else
            {
                m_position.x = float(Editor.Cursor.Coord.x) * 32.0f;
                m_position.y = float(Editor.Cursor.Coord.y - 8) * 8.0f;
                m_position.z = float(Editor.Cursor.Coord.z) * 32.0f;
            }
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
