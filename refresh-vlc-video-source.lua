obs = obslua

trigger_scene_name = ""
vlc_source_name = ""

function on_event(event)

	if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED then

		local scene = obs.obs_frontend_get_current_scene()
		local scene_name = obs.obs_source_get_name(scene)

		obs.script_log(obs.LOG_INFO, "Scene switched to: " .. scene_name)

		if trigger_scene_name == scene_name then

			local vlc_source = obs.obs_get_source_by_name(vlc_source_name)

			if vlc_source ~= nil then

				source_id = obs.obs_source_get_id(vlc_source)

				if source_id == "vlc_source" then

					local settings = obs.obs_source_get_settings(vlc_source)
					obs.obs_source_update(vlc_source, settings)
					obs.obs_data_release(settings)

					obs.script_log(obs.LOG_INFO, "VLC Video Source: Refreshed")

				end

				obs.obs_source_release(vlc_source)

			end

		end

		obs.obs_source_release(scene)

	end

end

function script_properties()

	local props = obs.obs_properties_create()

	local prop_trigger_scene = obs.obs_properties_add_list(props, "trigger_scene_name", "Trigger Scene", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local prop_vlc_source = obs.obs_properties_add_list(props, "vlc_source_name", "VLC Video Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)

	local scenes = obs.obs_frontend_get_scenes()
	local sources = obs.obs_enum_sources()

	if scenes ~= nil then

		for _, scene in ipairs(scenes) do

			local scene_name = obs.obs_source_get_name(scene);
			obs.obs_property_list_add_string(prop_trigger_scene, scene_name, scene_name)

		end

	end

	if sources ~= nil then

		for _, source in ipairs(sources) do

			source_id = obs.obs_source_get_id(source)

			if source_id == "vlc_source" then

				local source_name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(prop_vlc_source, source_name, source_name)

			end

		end

	end

	obs.source_list_release(scenes)
	obs.source_list_release(sources)

	return props

end

function script_description()

	return [[
		<h2>Refresh VLC Video Source</h2>
		<p>This script refresh VLC Video Source when scene switched to a Trigger Scene.</p>
		<p>By default, VLC Video Source cannot get newly created videos in a directory, so we need to refresh settings of VLC Video Source.</p>
		<p>Author: Антиквар</p>
		<p>Web-site: <a href="https://zozo.gg/">https://zozo.gg/</a></p>
	]]

end

function script_update(settings)

	trigger_scene_name = obs.obs_data_get_string(settings, "trigger_scene_name")
	vlc_source_name = obs.obs_data_get_string(settings, "vlc_source_name")

end

function script_load(settings)

	obs.obs_frontend_add_event_callback(on_event)

end
