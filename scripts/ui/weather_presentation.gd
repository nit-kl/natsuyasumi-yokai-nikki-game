class_name WeatherPresentation
extends RefCounted

const WEATHER_NAMES := {
	&"sunny": "晴れ",
	&"cloudy": "曇り",
	&"rain": "雨",
	&"thunderstorm": "雷雨",
}

const ICON_PATHS := {
	&"sunny": "res://assets/ui/diary/icon_weather_sunny.png",
	&"cloudy": "res://assets/ui/diary/icon_weather_cloudy.png",
	&"rain": "res://assets/ui/diary/icon_weather_rain.png",
	&"thunderstorm": "res://assets/ui/diary/icon_weather_thunderstorm.png",
}


static func display_name(weather: StringName) -> String:
	return String(WEATHER_NAMES.get(weather, String(weather)))


static func icon_path(weather: StringName) -> String:
	return String(ICON_PATHS.get(weather, ""))


static func icon_texture(weather: StringName) -> Texture2D:
	var path := icon_path(weather)
	if path.is_empty():
		return null
	return load(path) as Texture2D
