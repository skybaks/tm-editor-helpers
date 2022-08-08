
namespace EditorHelpers
{
    EditorHelpers::CountdownTimer permissionReduceSpamTimer = CountdownTimer(1.0f);

    bool HasPermission()
    {
        bool permission = false;
#if TMNEXT
        permission = Permissions::OpenSimpleMapEditor()
                    && Permissions::OpenAdvancedMapEditor()
                    && Permissions::CreateLocalMap();

        if (Setting_DebugLoggingEnabled)
        {
            if (permissionReduceSpamTimer.Complete())
            {
                trace("EditorHelpers::HasPermission(): OpenSimpleMapEditor:" + tostring(Permissions::OpenSimpleMapEditor())
                    + " OpenAdvancedMapEditor:" + tostring(Permissions::OpenAdvancedMapEditor())
                    + " CreateLocalMap:" + tostring(Permissions::CreateLocalMap()));
                permissionReduceSpamTimer.StartNew();
            }
        }
#else
        permission = true;
#endif
        return permission;
    }
}
