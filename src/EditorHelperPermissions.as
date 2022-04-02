
namespace EditorHelpers
{
    bool HasPermission()
    {
        bool permission = false;
#if TMNEXT
        permission = Permissions::OpenSimpleMapEditor()
                    && Permissions::OpenAdvancedMapEditor()
                    && Permissions::CreateLocalMap();
#else
        permission = true;
#endif
        return permission;
    }
}
