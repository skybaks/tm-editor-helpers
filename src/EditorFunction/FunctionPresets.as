
namespace EditorHelpers
{
    class EditorFunctionPresetItem
    {
        EditorFunctionPresetItem(const string&in name)
        {
            Name = name;
        }

        Json::Value@ JsonData
        {
            get
            {
                if (json is null)
                {
                    @json = Json::Object();
                }
                return json;
            }
            set
            {
                @json = value;
            }
        }

        string Name = "Invalid";
        private Json::Value@ json = null;
    }

    class EditorFunctionPreset
    {
        EditorFunctionPreset()
        {
            Name = "Preset";
            Functions = {};
            HotkeyEnabled = false;
            Key = VirtualKey::B;
        }

        void Init()
        {
            for (uint index = 0; index < g_functions.Length; index++)
            {
                EditorFunction@ ef = g_functions[index];
                if (ef.SupportsPresets())
                {
                    auto@ presetItem = GetItem(ef.Name());
                    if (presetItem is null)
                    {
                        @presetItem = EditorFunctionPresetItem(ef.Name());
                        ef.SerializePresets(presetItem.JsonData);
                        Functions.InsertLast(presetItem);
                    }
                }
            }
        }

        EditorFunctionPresetItem@ GetItem(const string&in name)
        {
            for (uint i = 0; i < Functions.Length; ++i)
            {
                if (Functions[i].Name == name)
                {
                    return Functions[i];
                }
            }
            return null;
        }

        string Name;
        array<EditorFunctionPresetItem@> Functions;
        bool HotkeyEnabled;
        VirtualKey Key;
    }

    namespace HotkeyInterface
    {
        bool Enabled_FunctionPresets()
        {
            return Setting_FunctionPresets_Enabled;
        }
    }

    [Setting category="Functions" name="Function Presets: Enabled" hidden]
    bool Setting_FunctionPresets_Enabled = true;
    [Setting category="Functions" name="Function Presets: Window Visible" hidden]
    bool Setting_FunctionPresets_WindowVisible = true;
    [Setting category="Functions" name="Function Presets: Show Activate Buttons" hidden]
    bool Setting_FunctionPresets_ShowActivateButtons = true;

    class FunctionPresets : EditorHelpers::EditorFunction
    {
        private array<EditorFunctionPreset@> m_presets;
        private uint m_selectedPresetIndex;
        private int m_forcePresetIndex;
        private string m_presetNewName;
        private bool m_deleteConfirm;
        private bool m_signalSave;

        string Name() override { return "Presets"; }
        bool Enabled() override { return Setting_FunctionPresets_Enabled; }

        void Init() override
        {
            if (!Enabled()) { return; }
        }

        void RenderInterface_Settings() override
        {
            UI::PushID(Name() + "SettingsPage");
            UI::Markdown("**" + Name() + "**");
            UI::SameLine();
            Setting_FunctionPresets_Enabled = UI::Checkbox("Enabled", Setting_FunctionPresets_Enabled);
            UI::BeginDisabled(!Setting_FunctionPresets_Enabled);
            string settingsDescription = "The function presets enables you to surgically save the state of the"
            " plugin and recall it at any time. Add, remove, and configure presets from the additional presets window."
            " You can also bind hotkeys to your defined presets through the hotkey settings.";
            UI::TextWrapped(settingsDescription);

            Setting_FunctionPresets_WindowVisible = UI::Checkbox("Show Additional Window", Setting_FunctionPresets_WindowVisible);
            Setting_FunctionPresets_ShowActivateButtons = UI::Checkbox("Show Preset Buttons on Action tab", Setting_FunctionPresets_ShowActivateButtons);
            UI::EndDisabled();
            UI::PopID();
        }

        void RenderInterface_Action() override
        {
            if (!Enabled()) { return; }

            if (Setting_FunctionPresets_ShowActivateButtons)
            {
                for (uint i = 0; i < m_presets.Length; ++i)
                {
                    if (settingToolTipsEnabled)
                    {
                        string helperText = "Click this button to activate the " + m_presets[i].Name + " preset";
                        if (m_presets[i].HotkeyEnabled)
                        {
                            helperText += " or use the hotkey [" + tostring(m_presets[i].Key) + "]";
                        }
                        EditorHelpers::HelpMarker(helperText);
                        UI::SameLine();
                    }
                    if (UI::Button("Preset: " + m_presets[i].Name))
                    {
                        ApplyPreset(m_presets[i]);
                    }
                }
            }
        }

        void RenderInterface_ChildWindow() override
        {
            if (!Enabled() || !Setting_FunctionPresets_WindowVisible)
            {
                return;
            }

            UI::SetNextWindowSize(580, 350, UI::Cond::FirstUseEver);
            int windowFlags = UI::WindowFlags::NoCollapse | UI::WindowFlags::MenuBar;
            UI::Begin(g_windowName + ": " + Name(), Setting_FunctionPresets_WindowVisible, windowFlags);

            EditorHelpers::WindowMenuBar::RenderDefaultMenus();

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Create a new preset");
                UI::SameLine();
            }
            bool newPreset = false;
            if (UI::Button(" New Preset"))
            {
                auto@ newFunctionPreset = EditorFunctionPreset();
                newFunctionPreset.Init();
                m_presets.InsertLast(newFunctionPreset);
                m_forcePresetIndex = m_presets.Length - 1;
                newPreset = true;
                m_signalSave = true;
            }

            UI::BeginDisabled(m_deleteConfirm);
            UI::SameLine();
            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Delete the currently selected preset");
                UI::SameLine();
            }
            if (UI::Button(" Delete Selected Preset"))
            {
                m_deleteConfirm = true;
            }
            UI::EndDisabled();
            if (m_deleteConfirm)
            {
                UI::SameLine();
                UI::Text("Are you sure?");
                UI::SameLine();
                if (UI::Button("Yes"))
                {
                    if (m_selectedPresetIndex >= 0 && m_selectedPresetIndex < m_presets.Length)
                    {
                        m_presets.RemoveAt(m_selectedPresetIndex);
                        m_forcePresetIndex = m_selectedPresetIndex != 0 ? m_selectedPresetIndex - 1 : 0;

                        m_signalSave = true;
                    }
                    m_deleteConfirm = false;
                }
                UI::SameLine();
                if (UI::Button("Cancel"))
                {
                    m_deleteConfirm = false;
                }
            }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Change the name of the currently selected preset");
                UI::SameLine();
            }
            m_presetNewName = UI::InputText("##SetNameInputText", m_presetNewName);
            UI::SameLine();
            if (UI::Button("Set Name")
                && m_selectedPresetIndex >= 0 && m_selectedPresetIndex < m_presets.Length)
            {
                m_presets[m_selectedPresetIndex].Name = m_presetNewName;
                m_presetNewName = "";
                m_forcePresetIndex = m_selectedPresetIndex;

                m_signalSave = true;
            }


            UI::BeginTabBar("FunctionPresetsTabBarFunctionPresets");
            for (uint presetIndex = 0; presetIndex < m_presets.Length; ++presetIndex)
            {
                UI::TabItemFlags flags = int(presetIndex) == m_forcePresetIndex ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None;
                if (UI::BeginTabItem(m_presets[presetIndex].Name + "##" + tostring(presetIndex), flags))
                {
                    m_selectedPresetIndex = presetIndex;

                    if (UI::BeginChild("FunctionPresetsTabBarFunctionPresetsChild", flags: UI::WindowFlags::NoScrollbar))
                    {
                        if (UI::BeginTable("FunctionPresetsTabBarTable", 2 /* cols */))
                        {
                            UI::TableSetupColumn("Col1", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoResize), 250.0);
                            UI::TableSetupColumn("Col2");

                            UI::TableNextColumn();
                            if (settingToolTipsEnabled)
                            {
                                EditorHelpers::HelpMarker("Enable or disable individual functions to specify what data the preset should read/write to");
                                UI::SameLine();
                            }
                            UI::Text("Enabled Functions");
                            UI::Separator();

                            bool forceValueFlag = false;
                            bool forceValue = true;
                            if (UI::Button(" Select All") || newPreset)
                            {
                                forceValueFlag = true;
                                forceValue = true;
                            }
                            UI::SameLine();
                            if (UI::Button(" Select None"))
                            {
                                forceValueFlag = true;
                                forceValue = false;
                            }

                            if (UI::BeginChild("FunctionPresetsTabBarTableChildCol1"))
                            {
                                UI::TextDisabled("\tAction");
                                RenderPresetEnables(g_functionsAction, m_presets[m_selectedPresetIndex], forceValue, forceValueFlag);
                                UI::TextDisabled("\tDisplay");
                                RenderPresetEnables(g_functionsDisplay, m_presets[m_selectedPresetIndex], forceValue, forceValueFlag);
                                UI::TextDisabled("\tBuild");
                                RenderPresetEnables(g_functionsBuild, m_presets[m_selectedPresetIndex], forceValue, forceValueFlag);
                                UI::TextDisabled("\tInfo");
                                RenderPresetEnables(g_functionsInfo, m_presets[m_selectedPresetIndex], forceValue, forceValueFlag);
                            }
                            UI::EndChild();

                            UI::TableNextColumn();
                            UI::BeginDisabled(m_presets[m_selectedPresetIndex].Functions.IsEmpty());

                            if (settingToolTipsEnabled)
                            {
                                EditorHelpers::HelpMarker("Configure the preset hotkey in the Openplanet settings menu");
                                UI::SameLine();
                            }
                            string hotkeyText = "Hotkey: ";
                            if (!m_presets[m_selectedPresetIndex].HotkeyEnabled)
                            {
                                hotkeyText += "Disabled";
                            }
                            else
                            {
                                hotkeyText += tostring(m_presets[m_selectedPresetIndex].Key);
                            }
                            UI::Text(hotkeyText);
                            UI::Separator();

                            if (settingToolTipsEnabled)
                            {
                                EditorHelpers::HelpMarker("Update this preset's data based on what is currently entered in the Editor Helpers window(s) and save");
                                UI::SameLine();
                            }
                            if (UI::Button("Update Preset Data"))
                            {
                                for (uint index = 0; index < g_functions.Length; index++)
                                {
                                    EditorFunction@ ef = g_functions[index];
                                    auto@ presetItem = m_presets[presetIndex].GetItem(ef.Name());
                                    if (ef.SupportsPresets() && presetItem !is null)
                                    {
                                        ef.SerializePresets(presetItem.JsonData);
                                    }
                                }

                                m_signalSave = true;
                            }
                            UI::SameLine();
                            if (settingToolTipsEnabled)
                            {
                                EditorHelpers::HelpMarker("Apply the data saved in this preset to the Editor Helpers window(s)");
                                UI::SameLine();
                            }
                            if (UI::Button("Apply Preset"))
                            {
                                ApplyPreset(m_presets[m_selectedPresetIndex]);
                            }
                            if (UI::BeginChild("FunctionPresetsTabBarTableChildCol2"))
                            {
                                if (UI::BeginTable("FunctionPresetsRenderPresetValuesTable", 2 /* cols */))
                                {
                                    UI::TableSetupColumn("Col1");
                                    UI::TableSetupColumn("Col2");

                                    UI::TableNextRow();
                                    UI::TableNextColumn();
                                    UI::TextDisabled("\tAction");
                                    RenderPresetValues(g_functionsAction, m_presets[m_selectedPresetIndex]);
                                    UI::TableNextRow();
                                    UI::TableNextColumn();
                                    UI::TextDisabled("\tDisplay");
                                    RenderPresetValues(g_functionsDisplay, m_presets[m_selectedPresetIndex]);
                                    UI::TableNextRow();
                                    UI::TableNextColumn();
                                    UI::TextDisabled("\tBuild");
                                    RenderPresetValues(g_functionsBuild, m_presets[m_selectedPresetIndex]);
                                    UI::TableNextRow();
                                    UI::TableNextColumn();
                                    UI::TextDisabled("\tInfo");
                                    RenderPresetValues(g_functionsInfo, m_presets[m_selectedPresetIndex]);

                                    UI::EndTable();
                                }
                            }
                            UI::EndChild();
                            UI::EndDisabled();

                            UI::EndTable();
                        }
                    }
                    UI::EndChild();

                    UI::EndTabItem();
                }
            }
            m_forcePresetIndex = -1;
            UI::EndTabBar();

            UI::End();
        }

        void RenderInterface_MenuItem() override
        {
            if (!Enabled()) { return; }

            if (UI::MenuItem(Icons::ListAlt + " " + Name(), selected: Setting_FunctionPresets_WindowVisible))
            {
                Setting_FunctionPresets_WindowVisible = !Setting_FunctionPresets_WindowVisible;
            }
        }

        void Update(float) override
        {
            if (!Enabled()) { return; }

            if (Signal_EnteredEditor())
            {
                LoadPresets();
            }

            if (m_signalSave)
            {
                SavePresets();
            }
            m_signalSave = false;
        }

        array<EditorFunctionPreset@>@ GetPresets() { return m_presets; }

        void ApplyPreset(EditorFunctionPreset@ preset)
        {
            Debug_EnterMethod("ApplyPreset");

            Debug("Applying preset data for name " + preset.Name);

            for (uint index = 0; index < g_functions.Length; index++)
            {
                EditorFunction@ ef = g_functions[index];
                auto@ presetItem = preset.GetItem(ef.Name());
                if (ef.SupportsPresets() && presetItem !is null)
                {
                    ef.DeserializePresets(presetItem.JsonData);
                }
            }

            Debug_LeaveMethod();
        }

        string GetRebindKeyName(const uint&in presetIndex)
        {
            if (presetIndex < 0 || presetIndex >= m_presets.Length)
            {
                return "";
            }
            return "Preset" + m_presets[presetIndex].Name + tostring(presetIndex);
        }

        void RebindPresetKey(const string&in rebindName, const VirtualKey&in key)
        {
            for (uint i = 0; i < m_presets.Length; ++i)
            {
                if (rebindName == GetRebindKeyName(i))
                {
                    m_presets[i].Key = key;
                    m_signalSave = true;
                    break;
                }
            }
        }

        private void RenderPresetEnables(array<EditorFunction@>@ functions, EditorFunctionPreset@ preset, bool forceValue, bool forceValueFlag)
        {
            for (uint index = 0; index < functions.Length; ++index)
            {
                EditorFunction@ ef = functions[index];
                if (ef.SupportsPresets())
                {
                    auto@ presetItem = preset.GetItem(ef.Name());
                    if (presetItem !is null)
                    {
                        if (ef.RenderPresetEnables(presetItem.JsonData, forceValue, forceValueFlag))
                        {
                            m_signalSave = true;
                        }
                    }
                }
            }
        }

        private void RenderPresetValues(array<EditorFunction@>@ functions, EditorFunctionPreset@ preset)
        {
            for (uint index = 0; index < functions.Length; index++)
            {
                EditorFunction@ ef = functions[index];
                auto@ presetItem = preset.GetItem(ef.Name());
                if (ef.SupportsPresets() && presetItem !is null)
                {
                    ef.RenderPresetValues(presetItem.JsonData);
                }
            }
        }

        private void LoadPresets()
        {
            Debug_EnterMethod("LoadPresets");

            if (m_presets.Length > 0)
            {
                Debug("Clearing presets");
                m_presets.RemoveRange(0, m_presets.Length);
            }

            auto json = Json::FromFile(IO::FromStorageFolder("EditorFunction_FunctionPresets.json"));

            auto presets = json.Get("presets", Json::Array());
            for (uint presetIndex = 0; presetIndex < presets.Length; ++presetIndex)
            {
                auto newPreset = EditorFunctionPreset();
                newPreset.Name = presets[presetIndex].Get("name", Json::Value("Preset"));
                newPreset.HotkeyEnabled = presets[presetIndex].Get("hotkey_enabled", Json::Value(false));
                newPreset.Key = VirtualKey(int(presets[presetIndex].Get("hotkey", Json::Value(66))));

                auto functions = presets[presetIndex].Get("functions", Json::Object());
                array<string>@ functionKeys = functions.GetKeys();
                for (uint functionIndex = 0; functionIndex < functionKeys.Length; ++functionIndex)
                {
                    string name = functionKeys[functionIndex];
                    auto newFunction = EditorFunctionPresetItem(name);
                    newFunction.JsonData = functions.Get(name, Json::Object());
                    newPreset.Functions.InsertLast(newFunction);
                }

                m_presets.InsertLast(newPreset);
            }

            Debug_LeaveMethod();
        }

        void SavePresets()
        {
            Debug_EnterMethod("SavePresets");

            Debug("Saving presets...");

            auto json = Json::Object();

            auto presets = Json::Array();

            for (uint presetIndex = 0; presetIndex < m_presets.Length; ++presetIndex)
            {
                auto preset = Json::Object();

                preset["name"] = m_presets[presetIndex].Name;
                preset["functions"] = Json::Object();
                preset["hotkey_enabled"] = m_presets[presetIndex].HotkeyEnabled;
                preset["hotkey"] = int(m_presets[presetIndex].Key);

                for (uint presetItemIndex = 0; presetItemIndex < m_presets[presetIndex].Functions.Length; ++presetItemIndex)
                {
                    auto@ presetItem = m_presets[presetIndex].Functions[presetItemIndex];
                    preset["functions"][presetItem.Name] = presetItem.JsonData;
                }

                presets.Add(preset);
            }

            json["presets"] = presets;
            Json::ToFile(IO::FromStorageFolder("EditorFunction_FunctionPresets.json"), json);

            Debug_LeaveMethod();
        }
    }

    bool JsonCheckboxChanged(Json::Value@ json, const string&in key, const string&in text, bool defaultValue, bool forceValue)
    {
        bool beforeVal = bool(json.Get(key, Json::Value(defaultValue)));
        bool afterVal = UI::Checkbox(text, beforeVal);
        if (forceValue) { afterVal = defaultValue; }
        json[key] = afterVal;
        return beforeVal != afterVal;
    }
}
