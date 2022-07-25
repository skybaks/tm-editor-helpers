
namespace EditorHelpers
{
    abstract class EditorFunction
    {
        bool FirstPass = true;
        CGameCtnEditorFree@ Editor { get const { return cast<CGameCtnEditorFree>(GetApp().Editor); } }

        string Name() { return ""; }
        bool Enabled(){ return false; }
        void Init(){}
        void RenderInterface_Action(){}
        void RenderInterface_Display(){}
        void RenderInterface_Build(){}
        void RenderInterface_Info(){}
        void RenderInterface_Settings(){}
        void RenderDrawing(){}
        void Update(float){}
        void OnKeyPress(bool down, VirtualKey key){}
    }
}
