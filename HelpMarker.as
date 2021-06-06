
namespace EditorHelpers
{
    string lastTipHover = "";
    CountdownTimer tipHoverTimer = CountdownTimer(0.5f);
    void HelpMarker(string desc)
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
                UI::BeginTooltip();
                UI::Text(desc);
                UI::EndTooltip();
            }
        }
        else if (desc == lastTipHover)
        {
            lastTipHover = "";
        }
    }
}
