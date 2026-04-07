package com.example.ontario_tech_plus

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val title = widgetData.getString("title", "No Classes Today!")
                val description = widgetData.getString("description", "Enjoy your free time.")

                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_description, description)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}