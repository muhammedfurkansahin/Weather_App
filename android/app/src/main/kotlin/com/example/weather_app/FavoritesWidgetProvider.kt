package com.example.weather_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.graphics.Color
import android.os.Build
import android.util.Log

class FavoritesWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
        
        val layoutId = when {
            minWidth <= 110 && minHeight <= 110 -> R.layout.favorites_widget_1x1
            minWidth <= 250 && minHeight <= 110 -> R.layout.favorites_widget_2x1
            minWidth <= 110 && minHeight <= 250 -> R.layout.favorites_widget_1x2
            minWidth <= 250 && minHeight <= 250 -> R.layout.favorites_widget_2x2
            else -> R.layout.favorites_widget
        }
        
        val views = RemoteViews(context.packageName, layoutId)
        
        when (layoutId) {
            R.layout.favorites_widget_1x1 -> update1x1Widget(context, views, appWidgetId)
            R.layout.favorites_widget_2x1 -> update2x1Widget(context, views, appWidgetId)
            R.layout.favorites_widget_1x2 -> update1x2Widget(context, views, appWidgetId)
            else -> updateListWidget(context, views, appWidgetId, layoutId)
        }
        
        // Update widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    private fun update1x1Widget(context: Context, views: RemoteViews, appWidgetId: Int) {
        val favorites = getFavoritesCount(context)
        views.setTextViewText(R.id.favorites_count, favorites.toString())
        setClickIntent(context, views, R.id.favorites_count)
    }
    
    private fun update2x1Widget(context: Context, views: RemoteViews, appWidgetId: Int) {
        val favorites = getFavoritesCount(context)
        views.setTextViewText(R.id.favorites_count_horizontal, favorites.toString())
        setClickIntent(context, views, R.id.favorites_count_horizontal)
    }
    
    private fun update1x2Widget(context: Context, views: RemoteViews, appWidgetId: Int) {
        val favorites = getFavoritesCount(context)
        views.setTextViewText(R.id.favorites_count_vertical, favorites.toString())
        setClickIntent(context, views, R.id.favorites_count_vertical)
    }
    
    private fun updateListWidget(context: Context, views: RemoteViews, appWidgetId: Int, layoutId: Int) {
        val listViewId = when (layoutId) {
            R.layout.favorites_widget_2x2 -> R.id.favorites_list_compact
            else -> R.id.favorites_list
        }
        
        val emptyViewId = when (layoutId) {
            R.layout.favorites_widget_2x2 -> R.id.empty_view_compact
            else -> R.id.empty_view
        }
        
        // Set up the RemoteViewsService for the ListView
        val intent = Intent(context, FavoritesWidgetService::class.java)
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        intent.putExtra("layout_id", layoutId)
        views.setRemoteAdapter(listViewId, intent)
        
        // Set empty view
        views.setEmptyView(listViewId, emptyViewId)
        
        // Set up click intent template
        val clickIntent = Intent(context, MainActivity::class.java)
        val clickPendingIntent = PendingIntent.getActivity(
            context,
            0,
            clickIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )
        views.setPendingIntentTemplate(listViewId, clickPendingIntent)
        
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, listViewId)
    }
    
    private fun getFavoritesCount(context: Context): Int {
        val prefs = context.getSharedPreferences("favorites", Context.MODE_PRIVATE)
        val favoritesJson = prefs.getString("favorite_cities", "[]")
        return try {
            val favorites = com.google.gson.Gson().fromJson(favoritesJson, Array<String>::class.java) ?: arrayOf()
            favorites.size
        } catch (e: Exception) {
            0
        }
    }
    
    private fun setClickIntent(context: Context, views: RemoteViews, viewId: Int) {
        val clickIntent = Intent(context, MainActivity::class.java)
        val clickPendingIntent = PendingIntent.getActivity(
            context,
            0,
            clickIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )
        views.setOnClickPendingIntent(viewId, clickPendingIntent)
    }
}