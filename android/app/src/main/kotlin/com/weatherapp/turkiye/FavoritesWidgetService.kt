package com.weatherapp.turkiye

import android.content.Intent
import android.widget.RemoteViewsService
import android.widget.RemoteViews
import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.*
import java.net.URL
import java.io.BufferedReader
import java.io.InputStreamReader
import org.json.JSONObject
import kotlinx.coroutines.*
import android.util.Log

class FavoritesWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return FavoritesWidgetItemFactory(applicationContext, intent)
    }
}

class FavoritesWidgetItemFactory(
    private val context: Context,
    private val intent: Intent
) : RemoteViewsService.RemoteViewsFactory {
    
    private var favorites: List<String> = listOf()
    private val weatherCache = mutableMapOf<String, WeatherData>()
    
    override fun onCreate() {
        loadFavorites()
    }
    
    override fun onDataSetChanged() {
        loadFavorites()
        updateWeatherData()
    }
    
    override fun onDestroy() {
        weatherCache.clear()
    }
    
    override fun getCount(): Int = favorites.size
    
    override fun getViewAt(position: Int): RemoteViews? {
        if (position >= favorites.size) return null
        
        val cityName = favorites[position]
        val weatherData = weatherCache[cityName]
        
        val layoutId = intent.getIntExtra("layout_id", R.layout.favorites_widget)
        val itemLayoutId = when (layoutId) {
            R.layout.favorites_widget_2x2 -> R.layout.favorites_widget_item_compact
            else -> R.layout.favorites_widget_item
        }
        
        val views = RemoteViews(context.packageName, itemLayoutId)
        
        views.setTextViewText(R.id.city_name, cityName)
        
        if (weatherData != null) {
            views.setTextViewText(R.id.temperature, "${weatherData.temperature}°C")
            
            // Compact layout için sadece sıcaklık göster, normal layout için tüm bilgileri göster
            if (itemLayoutId == R.layout.favorites_widget_item) {
                views.setTextViewText(R.id.description, weatherData.description)
                views.setTextViewText(R.id.humidity, "Nem: ${weatherData.humidity}%")
            }
        } else {
            views.setTextViewText(R.id.temperature, "Yükleniyor...")
            if (itemLayoutId == R.layout.favorites_widget_item) {
                views.setTextViewText(R.id.description, "")
                views.setTextViewText(R.id.humidity, "")
            }
        }
        
        // Set click intent
        val fillInIntent = Intent()
        fillInIntent.putExtra("city_name", cityName)
        views.setOnClickFillInIntent(R.id.widget_item_container, fillInIntent)
        
        return views
    }
    
    override fun getLoadingView(): RemoteViews? = null
    
    override fun getViewTypeCount(): Int = 1
    
    override fun getItemId(position: Int): Long = position.toLong()
    
    override fun hasStableIds(): Boolean = true
    
    private fun loadFavorites() {
        val prefs = context.getSharedPreferences("favorites", Context.MODE_PRIVATE)
        val favoritesJson = prefs.getString("favorite_cities", "[]")
        val gson = Gson()
        val type = object : TypeToken<List<String>>() {}.type
        
        favorites = try {
            gson.fromJson<List<String>>(favoritesJson, type) ?: listOf()
        } catch (e: Exception) {
            listOf()
        }
    }
    
    private fun updateWeatherData() {
        CoroutineScope(Dispatchers.IO).launch {
            favorites.forEach { cityName ->
                try {
                    val weatherData = fetchWeatherData(cityName)
                    weatherCache[cityName] = weatherData
                } catch (e: Exception) {
                    Log.e("FavoritesWidget", "Error fetching weather for $cityName: ${e.message}")
                }
            }
        }
    }
    
    private suspend fun fetchWeatherData(cityName: String): WeatherData {
        return withContext(Dispatchers.IO) {
            try {
                // WeatherAPI.com kullanarak hava durumu verisi çek
                val apiKey = "36a06512f3094315ad4112041240208"
                val url = "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=1&lang=tr"
                
                val connection = URL(url).openConnection()
                val reader = BufferedReader(InputStreamReader(connection.getInputStream()))
                val response = StringBuilder()
                var line: String?
                
                while (reader.readLine().also { line = it } != null) {
                    response.append(line)
                }
                reader.close()
                
                val jsonObject = JSONObject(response.toString())
                val current = jsonObject.getJSONObject("current")
                val condition = current.getJSONObject("condition")
                
                WeatherData(
                    temperature = current.getDouble("temp_c").toInt(),
                    description = condition.getString("text"),
                    humidity = current.getInt("humidity")
                )
            } catch (e: Exception) {
                Log.e("FavoritesWidget", "Error fetching weather for $cityName: ${e.message}")
                WeatherData(0, "Veri alınamadı", 0)
            }
        }
    }
    
    data class WeatherData(
        val temperature: Int,
        val description: String,
        val humidity: Int
    )
}