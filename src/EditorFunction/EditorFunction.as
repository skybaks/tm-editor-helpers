
namespace EditorHelpers
{
    abstract class EditorFunction
    {
        bool FirstPass = true;
        CGameCtnEditorFree@ Editor { get const { return cast<CGameCtnEditorFree>(GetApp().Editor); } }
        private string[] m_debugMethodStack = {};

        string Name() { return ""; }
        bool Enabled(){ return false; }
        bool HasSettingsEntry() { return true; }
        void Init(){}
        void RenderInterface_Action(){}
        void RenderInterface_Display(){}
        void RenderInterface_Build(){}
        void RenderInterface_Info(){}
        void RenderInterface_Settings(){}
        void RenderInterface_ChildWindow(){}
        void RenderInterface_MenuItem(){}
        void Update(float){}
        void OnKeyPress(bool down, VirtualKey key){}

        void Debug_EnterMethod(const string&in methodName)
        {
            if (Setting_DebugLoggingEnabled)
            {
                m_debugMethodStack.InsertLast(methodName);
            }
        }

        void Debug_LeaveMethod()
        {
            if (Setting_DebugLoggingEnabled && m_debugMethodStack.Length > 0)
            {
                m_debugMethodStack.RemoveAt(m_debugMethodStack.Length - 1);
            }
        }

        void Debug(const string&in message)
        {
            if (Setting_DebugLoggingEnabled)
            {
                trace(Name() + " :" + string::Join(m_debugMethodStack, ":") + ": " + message);
            }
        }
    }
}
