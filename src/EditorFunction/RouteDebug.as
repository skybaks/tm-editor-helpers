
namespace EditorHelpers
{
    [Setting category="Functions" name="RouteDebug: RouteDebug Function Enabled" hidden]
    bool Setting_RouteDebug_Enabled = true;
    [Setting category="Functions" name="RouteDebug: Show test run overlay" hidden]
    bool Setting_RouteDebug_ShowOverlay = false;

    class DrivingShapshot
    {
        vec3 Position;
    }

    class RouteDebug : EditorHelpers::EditorFunction
    {
        DrivingShapshot[] m_snapshots = array<DrivingShapshot>(10000);
        uint m_snapshotLength = 0;
        float m_timeSinceLastSnapshot = 0.0f;
        bool m_isMapTestingPrev = false;

        string Name() override { return "Route Overlay Info"; }
        bool Enabled() override { return Setting_RouteDebug_Enabled; }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_RouteDebug_Enabled = UI::Checkbox("Enabled", Setting_RouteDebug_Enabled);
            UI::BeginDisabled(!Setting_RouteDebug_Enabled);
            UI::TextWrapped("Records information while you are driving in test mode and displays it as an overlay in the editor.");
            Setting_RouteDebug_ShowOverlay = UI::Checkbox("Show the last test run overlay", Setting_RouteDebug_ShowOverlay);
            UI::EndDisabled();
            UI::PopID();
        }

        void Init() override
        {
            if (!Enabled() || Editor is null)
            {
                m_snapshotLength = 0;
                m_timeSinceLastSnapshot = 0.0f;
                m_isMapTestingPrev = false;
            }
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) return;

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Show last test run");
                UI::SameLine();
            }
            Setting_RouteDebug_ShowOverlay = UI::Checkbox("Test Run Overlay", Setting_RouteDebug_ShowOverlay);
        }

        void Update(float dt) override
        {
            if (!Enabled() || Editor is null) return;

            if (Compatibility::IsMapTesting())
            {
                if (!m_isMapTestingPrev)
                {
                    m_snapshotLength = 0;
                    m_timeSinceLastSnapshot = 0.0f;
                }

                auto state = VehicleState::ViewingPlayerState();
                if (state !is null && m_timeSinceLastSnapshot > 10.0f && m_snapshotLength < m_snapshots.Length)
                {
                    m_snapshots[m_snapshotLength].Position = state.Position;

                    m_snapshotLength++;
                    m_timeSinceLastSnapshot = 0.0f;
                }

                m_timeSinceLastSnapshot += dt;
            }

            m_isMapTestingPrev = Compatibility::IsMapTesting();
        }

        void RenderDrawing() override
        {
            if (!Enabled() || Editor is null) return;
            if (!Setting_RouteDebug_ShowOverlay) return;

            if (m_snapshotLength > 1)
            {
                nvg::StrokeColor(vec4(1.0, 0.2, 0.2, 1.0));
                nvg::StrokeWidth(1.0);
                nvg::BeginPath();
                int pointsDrawn = 0;
                for (uint i = 1; i < m_snapshotLength; i++)
                {
                    if (!Camera::IsBehind(m_snapshots[i].Position))
                    {
                        if (pointsDrawn == 0)
                        {
                            nvg::MoveTo(Camera::ToScreenSpace(m_snapshots[i].Position));
                        }
                        else
                        {
                            nvg::LineTo(Camera::ToScreenSpace(m_snapshots[i].Position));
                        }

                        pointsDrawn++;
                    }
                }
                if (pointsDrawn > 1)
                {
                    nvg::Stroke();
                }
                else
                {
                    nvg::Reset();
                }
            }
        }
    }
}
