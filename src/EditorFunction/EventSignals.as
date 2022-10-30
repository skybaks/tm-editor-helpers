
namespace EditorHelpers
{
    namespace Compatibility
    {
        uint GetGhostBlocksCount(CGameCtnEditorFree@ editor)
        {
            uint count = 0;
#if TMNEXT
            count = editor.PluginMapType.GhostBlocks.Length;
#endif
            return count;
        }
    }

    namespace SignalsInternal
    {
        bool Signal_MapFileUpdated = false;
        bool Signal_BlockItemPlaced = false;
        bool Signal_BlockItemRemoved = false;
        bool Signal_EnteredEditor = false;
    }

    // Notifies when the map uid changes or the map file changes size
    bool Signal_MapFileUpdated() { return EditorHelpers::SignalsInternal::Signal_MapFileUpdated; }

    // Notifies when a block or item is placed
    bool Signal_BlockItemPlaced() { return EditorHelpers::SignalsInternal::Signal_BlockItemPlaced; }

    // Notifies when a block or item is removed
    bool Signal_BlockItemRemoved() { return EditorHelpers::SignalsInternal::Signal_BlockItemRemoved; }

    // Notifies that you have just entered the editor
    bool Signal_EnteredEditor() { return EditorHelpers::SignalsInternal::Signal_EnteredEditor; }

    // The EventSignals editor function has no function effect for users but
    // rather provides notifications for certain events occurring so that code
    // doesnt need to be duplicated in multiple editor functions.
    class EventSignals : EditorHelpers::EditorFunction
    {
        private uint m_lastUidAndSizeBytes = 0;
        private uint m_prevClassicBlockCount = 0;
        private uint m_prevGhostBlockCount = 0;
        private uint m_prevAnchoredObjectCount = 0;
        private bool m_prevEditorIsNull = true;

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
            UpdateSignal_BlockItemPlacedRemoved();
            UpdateSignal_EnteredEditor();

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

        private void UpdateSignal_BlockItemPlacedRemoved()
        {
            Debug_EnterMethod("UpdateSignal_BlockItemPlacedRemoved");

            EditorHelpers::SignalsInternal::Signal_BlockItemPlaced = false;
            EditorHelpers::SignalsInternal::Signal_BlockItemRemoved = false;

            if (Editor !is null
                && Editor.PluginMapType !is null
                && Editor.Challenge !is null)
            {
                uint classicBlockCount = Editor.PluginMapType.ClassicBlocks.Length;
                uint ghostBlockCount = Compatibility::GetGhostBlocksCount(Editor);
                uint anchoredObjectCount = Editor.Challenge.AnchoredObjects.Length;

                if (m_prevClassicBlockCount < classicBlockCount
                    || m_prevGhostBlockCount < ghostBlockCount
                    || m_prevAnchoredObjectCount < anchoredObjectCount)
                {
                    EditorHelpers::SignalsInternal::Signal_BlockItemPlaced = true;

                    Debug("Activate Signal: Signal_BlockItemPlaced");
                }
                else if (m_prevClassicBlockCount > classicBlockCount
                    || m_prevGhostBlockCount > ghostBlockCount
                    || m_prevAnchoredObjectCount > anchoredObjectCount)
                {
                    EditorHelpers::SignalsInternal::Signal_BlockItemRemoved = true;

                    Debug("Activate Signal: Signal_BlockItemRemoved");
                }

                m_prevClassicBlockCount = classicBlockCount;
                m_prevGhostBlockCount = ghostBlockCount;
                m_prevAnchoredObjectCount = anchoredObjectCount;
            }
            else
            {
                m_prevClassicBlockCount = 0;
                m_prevGhostBlockCount = 0;
                m_prevAnchoredObjectCount = 0;
            }

            Debug_LeaveMethod();
        }

        private void UpdateSignal_EnteredEditor()
        {
            Debug_EnterMethod("UpdateSignal_EnteredEditor");

            EditorHelpers::SignalsInternal::Signal_EnteredEditor = false;

            bool editorIsNull = Editor is null;
            if (m_prevEditorIsNull && !editorIsNull)
            {
                EditorHelpers::SignalsInternal::Signal_EnteredEditor = true;

                Debug("Activate Signal: Signal_EnteredEditor");
            }
            m_prevEditorIsNull = editorIsNull;

            Debug_LeaveMethod();
        }
    }
}
