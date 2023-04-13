
namespace EditorHelpers
{
    class EditorFunctionPresetItem
    {
        EditorFunctionPresetItem()
        {
            json = Json::Object();
        }

        Json::Value json;
    }

    class EditorFunctionPreset
    {
        EditorFunctionPreset()
        {
            Name = "Preset";
            Functions = {};
        }

        string Name;
        dictionary Functions;
    }

    [Setting category="Functions" name="Function Presets: Enabled" hidden]
    bool Setting_FunctionPresets_Enabled = true;
    [Setting category="Functions" name="Function Presets: Window Visible" hidden]
    bool Setting_FunctionPresets_WindowVisible = true;

    class FunctionPresets : EditorHelpers::EditorFunction
    {
        private array<EditorFunctionPreset@> m_presets;
        private uint m_selectedPresetIndex;
        private bool m_forcePresetIndex;
        private string m_presetNewName;
        private bool m_deleteConfirm;

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
            UI::TextWrapped("The function presets enables you to surgically save the state of the plugin and recall that at any time.");

            Setting_FunctionPresets_WindowVisible = UI::Checkbox("Show Additional Window", Setting_FunctionPresets_WindowVisible);
            UI::EndDisabled();
            UI::PopID();
        }

        void RenderInterface_Display() override
        {
            if (!Enabled()) { return; }

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Show or hide the window for managing presets");
                UI::SameLine();
            }
            Setting_FunctionPresets_WindowVisible = UI::Checkbox("Show Presets Window", Setting_FunctionPresets_WindowVisible);
        }

        void RenderInterface_ChildWindow() override
        {
            if (!Enabled() || !Setting_FunctionPresets_WindowVisible)
            {
                g_presetConfigMode = false;
                return;
            }

            g_presetConfigMode = true;

            UI::SetNextWindowSize(550, 350, UI::Cond::FirstUseEver);
            UI::Begin(g_windowName + ": " + Name(), Setting_FunctionPresets_WindowVisible);

            if (settingToolTipsEnabled)
            {
                EditorHelpers::HelpMarker("Create a new preset");
                UI::SameLine();
            }
            if (UI::Button(" New Preset"))
            {
                m_presets.InsertLast(EditorFunctionPreset());
                m_forcePresetIndex = true;
                m_selectedPresetIndex = m_presets.Length - 1;
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
                        m_forcePresetIndex = true;
                        m_selectedPresetIndex = m_selectedPresetIndex != 0 ? m_selectedPresetIndex - 1 : 0;

                        SavePresets();
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
                m_forcePresetIndex = true;

                SavePresets();
            }


            UI::BeginTabBar("FunctionPresetsTabBarFunctionPresets");
            for (uint presetIndex = 0; presetIndex < m_presets.Length; ++presetIndex)
            {
                UI::TabItemFlags flags = m_forcePresetIndex && presetIndex == m_selectedPresetIndex ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None;
                if (UI::BeginTabItem(m_presets[presetIndex].Name + "##" + tostring(presetIndex), flags))
                {
                    m_selectedPresetIndex = presetIndex;

                    if (UI::BeginTable("FunctionPresetsTabBarTable", 2 /* cols */))
                    {
                        UI::TableNextColumn();
                        if (settingToolTipsEnabled)
                        {
                            EditorHelpers::HelpMarker("Enable or disable individual functions to specify what data the preset should read/write to");
                            UI::SameLine();
                        }
                        UI::Text("Enabled Functions");
                        if (UI::BeginChild("FunctionPresetsTabBarTableChildCol1"))
                        {
                            for (uint index = 0; index < functions.Length; index++)
                            {
                                EditorFunction@ ef = functions[index];
                                if (ef.SupportsPresets())
                                {
                                    ef.PresetConfigMode = UI::Checkbox(ef.Name() + "##" + tostring(index), m_presets[presetIndex].Functions.Exists(ef.Name()));

                                    if (ef.PresetConfigMode && !m_presets[presetIndex].Functions.Exists(ef.Name()))
                                    {
                                        m_presets[presetIndex].Functions.Set(ef.Name(), EditorFunctionPresetItem());
                                    }
                                    else if (!ef.PresetConfigMode && m_presets[presetIndex].Functions.Exists(ef.Name()))
                                    {
                                        m_presets[presetIndex].Functions.Delete(ef.Name());
                                    }
                                }
                            }
                        }
                        UI::EndChild();

                        UI::TableNextColumn();
                        UI::BeginDisabled(m_presets[m_selectedPresetIndex].Functions.IsEmpty());
                        if (settingToolTipsEnabled)
                        {
                            EditorHelpers::HelpMarker("Update this saved preset data based on what is currently entered in the Editor Helpers window(s)");
                            UI::SameLine();
                        }
                        if (UI::Button("Update Preset Data"))
                        {
                            for (uint index = 0; index < functions.Length; index++)
                            {
                                EditorFunction@ ef = functions[index];
                                if (ef.SupportsPresets() && m_presets[m_selectedPresetIndex].Functions.Exists(ef.Name()))
                                {
                                    ef.SerializePresets(cast<EditorFunctionPresetItem>(m_presets[m_selectedPresetIndex].Functions[ef.Name()]).json);
                                }
                            }

                            SavePresets();
                        }
                        UI::SameLine();
                        if (settingToolTipsEnabled)
                        {
                            EditorHelpers::HelpMarker("Apply the data saved in this preset to the Editor Helpers window(s)");
                            UI::SameLine();
                        }
                        if (UI::Button("Apply Preset"))
                        {
                            ApplyPreset(m_selectedPresetIndex);
                        }
                        if (UI::BeginChild("FunctionPresetsTabBarTableChildCol2"))
                        {
                            for (uint index = 0; index < functions.Length; index++)
                            {
                                EditorFunction@ ef = functions[index];
                                if (ef.SupportsPresets() && m_presets[presetIndex].Functions.Exists(ef.Name()))
                                {
                                    if (UI::TreeNode(ef.Name() + "##" + presetIndex, UI::TreeNodeFlags::DefaultOpen))
                                    {
                                        ef.RenderPresetValues(cast<EditorFunctionPresetItem>(m_presets[presetIndex].Functions[ef.Name()]).json);
                                        UI::TreePop();
                                    }
                                }
                            }
                        }
                        UI::EndChild();
                        UI::EndDisabled();

                        UI::EndTable();
                    }

                    UI::EndTabItem();
                }
            }
            m_forcePresetIndex = false;
            UI::EndTabBar();

            UI::End();
        }

        void RenderInterface_MenuItem() override
        {
            if (!Enabled()) { return; }

            if (UI::MenuItem(Icons::PuzzlePiece + " " + Name(), selected: Setting_FunctionPresets_WindowVisible))
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
        }

        private void ApplyPreset(int presetIndex)
        {
            Debug_EnterMethod("ApplyPreset");

            if (presetIndex >= 0 && presetIndex < int(m_presets.Length))
            {
                Debug("Applying preset data for name " + m_presets[presetIndex].Name);

                for (uint index = 0; index < functions.Length; index++)
                {
                    EditorFunction@ ef = functions[index];
                    if (ef.SupportsPresets() && m_presets[presetIndex].Functions.Exists(ef.Name()))
                    {
                        ef.DeserializePresets(cast<EditorFunctionPresetItem>(m_presets[presetIndex].Functions[ef.Name()]).json);
                    }
                }
            }

            Debug_LeaveMethod();
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

                auto functions = presets[presetIndex].Get("functions", Json::Object());
                array<string>@ functionKeys = functions.GetKeys();
                for (uint functionIndex = 0; functionIndex < functionKeys.Length; ++functionIndex)
                {
                    auto newFunction = EditorFunctionPresetItem();

                    string key = functionKeys[functionIndex];
                    newFunction.json = functions.Get(key, Json::Object());
                    newPreset.Functions.Set(key, newFunction);
                }

                m_presets.InsertLast(newPreset);
            }

            Debug_LeaveMethod();
        }

        private void SavePresets()
        {
            Debug_EnterMethod("SavePresets");

            auto json = Json::Object();

            auto presets = Json::Array();

            for (uint presetIndex = 0; presetIndex < m_presets.Length; ++presetIndex)
            {
                auto preset = Json::Object();

                preset["name"] = m_presets[presetIndex].Name;
                preset["functions"] = Json::Object();

                auto keys = m_presets[presetIndex].Functions.GetKeys();
                for (uint keyIndex = 0; keyIndex < keys.Length; ++keyIndex)
                {
                    string key = keys[keyIndex];
                    preset["functions"][key] = cast<EditorFunctionPresetItem>(m_presets[presetIndex].Functions[key]).json;
                }

                presets.Add(preset);
            }

            json["presets"] = presets;
            Json::ToFile(IO::FromStorageFolder("EditorFunction_FunctionPresets.json"), json);

            Debug_LeaveMethod();
        }
    }
}
