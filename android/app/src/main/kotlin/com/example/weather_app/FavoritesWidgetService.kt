package com.example.weather_app

import android.content.Intent
import android.widget.RemoteViewsService
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.example.weather_app.R

class FavoritesWidgetService : RemoteViewsService() {
    
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        val layoutId = intent.getIntExtra("layout_id", R.layout.favorites_widget)
        return FavoritesWidgetItemFactory(applicationContext, layoutId)
    }
}

class FavoritesWidgetItemFactory(
    private val context: android.content.Context,
    private val layoutId: Int
) : RemoteViewsService.RemoteViewsFactory {
    
    private var favorites: List<String> = listOf()
    private val prefs: SharedPreferences = context.getSharedPreferences("favorites", android.content.Context.MODE_PRIVATE)
    private val gson = Gson()
    
    override fun onCreate() {
        loadFavorites()
    }
    
    override fun onDataSetChanged() {
        loadFavorites()
    }
    
    override fun onDestroy() {
        favorites = listOf()
    }
    
    override fun getCount(): Int = favorites.size
    
    override fun getViewAt(position: Int): android.widget.RemoteViews {
        val itemLayoutId = when (layoutId) {
            R.layout.favorites_widget_2x2 -> R.layout.favorites_widget_item_compact
            else -> R.layout.favorites_widget_item
        }
        
        val remoteViews = android.widget.RemoteViews(
            context.packageName,
            itemLayoutId
        )
        
        if (position < favorites.size) {
            val cityName = favorites[position]
            
            if (itemLayoutId == R.layout.favorites_widget_item_compact) {
                remoteViews.setTextViewText(R.id.city_name_compact, cityName)
            } else {
                remoteViews.setTextViewText(R.id.city_name, cityName)
                
                // Set different background colors for visual appeal
                val colors = arrayOf(
                    android.graphics.Color.parseColor("#E3F2FD"), // Light Blue
                    android.graphics.Color.parseColor("#F3E5F5"), // Light Purple
                    android.graphics.Color.parseColor("#E8F5E8"), // Light Green
                    android.graphics.Color.parseColor("#FFF3E0"), // Light Orange
                    android.graphics.Color.parseColor("#FCE4EC")  // Light Pink
                )
                remoteViews.setInt(R.id.widget_item_container, "setBackgroundColor", colors[position % colors.size])
            }
        }
        
        return remoteViews
    }
    
    override fun getLoadingView(): android.widget.RemoteViews? = null
    
    override fun getViewTypeCount(): Int = 1
    
    override fun getItemId(position: Int): Long = position.toLong()
    
    override fun hasStableIds(): Boolean = true
    
    private fun loadFavorites() {
        val favoritesJson = prefs.getString("favorite_cities", "[]")
        val type = object : TypeToken<List<String>>() {}.type
        favorites = try {
            gson.fromJson(favoritesJson, type) ?: listOf()
        } catch (e: Exception) {
            listOf()
        }
    }
}