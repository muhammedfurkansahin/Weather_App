package com.weatherapp.turkiye
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.weatherapp.turkiye.R


class MainActivity: FlutterActivity() {
    private val CHANNEL = "favorites_widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    val favoritesJson = call.argument<String>("favorites")
                    updateFavoritesInSharedPreferences(favoritesJson)
                    updateWidget()
                    result.success(null)
                }
                "addFavorite" -> {
                    val cityName = call.argument<String>("cityName")
                    addFavoriteToSharedPreferences(cityName)
                    updateWidget()
                    result.success(null)
                }
                "removeFavorite" -> {
                    val cityName = call.argument<String>("cityName")
                    removeFavoriteFromSharedPreferences(cityName)
                    updateWidget()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun updateFavoritesInSharedPreferences(favoritesJson: String?) {
        val prefs = getSharedPreferences("favorites", MODE_PRIVATE)
        prefs.edit().putString("favorite_cities", favoritesJson).apply()
    }
    
    private fun addFavoriteToSharedPreferences(cityName: String?) {
        if (cityName == null) return
        
        val prefs = getSharedPreferences("favorites", MODE_PRIVATE)
        val favoritesJson = prefs.getString("favorite_cities", "[]")
        val gson = Gson()
        val type = object : TypeToken<MutableList<String>>() {}.type
        
        val favorites = try {
            gson.fromJson<MutableList<String>>(favoritesJson, type) ?: mutableListOf()

        } catch (e: Exception) {
            mutableListOf()
        }
        
        if (!favorites.contains(cityName)) {
            favorites.add(cityName)
            prefs.edit().putString("favorite_cities", gson.toJson(favorites)).apply()
        }
    }
    
    private fun removeFavoriteFromSharedPreferences(cityName: String?) {
        if (cityName == null) return
        
        val prefs = getSharedPreferences("favorites", MODE_PRIVATE)
        val favoritesJson = prefs.getString("favorite_cities", "[]")
        val gson = Gson()
        val type = object : TypeToken<MutableList<String>>() {}.type
        
        val favorites = try {
            gson.fromJson<MutableList<String>>(favoritesJson, type) ?: mutableListOf()

        } catch (e: Exception) {
            mutableListOf()
        }
        
        favorites.remove(cityName)
        prefs.edit().putString("favorite_cities", gson.toJson(favorites)).apply()
    }
    
    private fun updateWidget() {
        val intent = Intent(this, FavoritesWidgetProvider::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val componentName = ComponentName(this, FavoritesWidgetProvider::class.java)
        val ids = appWidgetManager.getAppWidgetIds(componentName)

        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        
        sendBroadcast(intent)
    }
}
