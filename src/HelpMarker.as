
namespace EditorHelpers
{
    string lastTipHover = "";
    CountdownTimer tipHoverTimer = CountdownTimer(0.5f);
    void HelpMarker(const string &in desc)
    {
        UI::TextDisabled(Icons::QuestionCircle);
        if (UI::IsItemHovered())
        {
            if (desc != lastTipHover)
            {
                tipHoverTimer.StartNew();
                lastTipHover = desc;
            }
            else if (desc == lastTipHover && tipHoverTimer.Complete())
            {
                // X value used as width, Y value ignored because text continues to wrap.
                UI::SetNextWindowSize(300, 10);
                UI::BeginTooltip();
                UI::TextWrapped(desc);
                UI::EndTooltip();
            }
        }
        else if (desc == lastTipHover)
        {
            lastTipHover = "";
        }
    }

    bool g_highlightInit = true;
    vec4 g_highlightColor;
    vec4 g_highlightColorDisabled;
    bool g_highlightNeedsPop = false;
    array<string> g_highlightId = {};

    void SetHighlightId(const string&in id)
    {
        if (g_highlightId.Find(id) < 0)
        {
            g_highlightId.InsertLast(id);
        }
    }

    void BeginHighlight(const string&in id)
    {
        if (g_highlightInit)
        {
            g_highlightInit = false;
            // Try to find a highlight color that doesn't overlap with the window background.
            vec4 windowBg = UI::GetStyleColor(UI::Col::WindowBg);
            g_highlightColor = vec4(1.0, 1.0, 1.0, 1.0);
            if (windowBg.x > windowBg.y && windowBg.x > windowBg.z)
            {
                g_highlightColor.x *= 0.3;
            }
            else if (windowBg.y > windowBg.x && windowBg.y > windowBg.z)
            {
                g_highlightColor.y *= 0.3;
            }
            else
            {
                g_highlightColor.z *= 0.3;
            }
            if (windowBg.x > 0.75 && windowBg.y > 0.75 && windowBg.z > 0.75)
            {
                g_highlightColor.x *= 0.6;
                g_highlightColor.y *= 0.6;
                g_highlightColor.z *= 0.6;
            }
            g_highlightColorDisabled = g_highlightColor * 0.4;
            g_highlightColorDisabled.w = 1.0;
        }

        int idIndex = g_highlightId.Find(id);
        if (idIndex >= 0)
        {
            g_highlightId.RemoveAt(idIndex);
            if (!g_highlightNeedsPop)
            {
                g_highlightNeedsPop = true;
                UI::PushStyleColor(UI::Col::Text, g_highlightColor);
                UI::PushStyleColor(UI::Col::TextDisabled, g_highlightColorDisabled);
                UI::PushStyleColor(UI::Col::FrameBg, g_highlightColorDisabled);
                UI::PushStyleColor(UI::Col::Button, g_highlightColorDisabled);
            }
        }
    }

    void EndHighlight()
    {
        if (g_highlightNeedsPop)
        {
            g_highlightNeedsPop = false;
            UI::PopStyleColor(4);
        }
    }

    void NewMarker()
    {
        UI::Text("\\$f00" + Icons::InfoCircle + " New");
    }
}
