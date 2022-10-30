
namespace EditorHelpers
{
    namespace SignalsInternal
    {
        bool Signal_MapFileUpdated = false;
    }

    // Notifies when the map uid changes or the map file changes size
    bool Signal_MapFileUpdated() { return EditorHelpers::SignalsInternal::Signal_MapFileUpdated; }

    // The EventSignals editor function has no function effect for users but
    // rather provides notifications for certain events occurring so that code
    // doesnt need to be duplicated in multiple editor functions.
    class EventSignals : EditorHelpers::EditorFunction
    {
        private uint m_lastUidAndSizeBytes = 0;

        string Name() override { return "Event Signals"; }
        bool Enabled() override { return true; }

        void Init() override
        {
            if (!Enabled()) return;

            if (Editor is null)
            {
                m_lastUidAndSizeBytes = 0;
            }
        }

        void Update(float dt) override
        {
            Debug_EnterMethod("Update");
            if (!Enabled())
            {
                Debug_LeaveMethod();
                return;
            }

            UpdateSignal_MapFileUpdated();

            Debug_LeaveMethod();
        }

        private void UpdateSignal_MapFileUpdated()
        {
            Debug_EnterMethod("UpdateSignal_MapFileUpdated");

            EditorHelpers::SignalsInternal::Signal_MapFileUpdated = false;

            if (Editor !is null)
            {
                auto challengeFidFile = cast<CSystemFidFile>(GetFidFromNod(Editor.Challenge));
                if (challengeFidFile !is null)
                {
                    uint uidAndBytes = challengeFidFile.ByteSize;
                    if (m_lastUidAndSizeBytes != uidAndBytes)
                    {
                        EditorHelpers::SignalsInternal::Signal_MapFileUpdated = true;

                        Debug("Activate Signal: Signal_MapFileUpdated. Prev flag: " + tostring(m_lastUidAndSizeBytes) + " New flag: " + tostring(uidAndBytes));
                    }

                    m_lastUidAndSizeBytes = uidAndBytes;
                }
                else
                {
                    m_lastUidAndSizeBytes = 0;
                }
            }

            Debug_LeaveMethod();
        }
    }
}
