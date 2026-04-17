package com.idrisium.alfurkan

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.app.PendingIntent
import android.graphics.BitmapFactory
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerWidgetProvider : AppWidgetProvider() {

  private companion object {
    const val ACTION_WIDGET_UPDATE = "es.antonborri.home_widget.action.WIDGET_UPDATE"
  }

  override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
    for (widgetId in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.prayer_widget)

      val imagePath = HomeWidgetPlugin.getData(context).getString("prayer_image", null)
      if (!imagePath.isNullOrBlank()) {
        val normalizedPath = imagePath.removePrefix("file://")
        val bitmap = BitmapFactory.decodeFile(normalizedPath)
        if (bitmap != null) {
          views.setImageViewBitmap(R.id.prayer_image, bitmap)
        } else {
          views.setImageViewResource(R.id.prayer_image, R.drawable.launch_background)
        }
      } else {
        views.setImageViewResource(R.id.prayer_image, R.drawable.launch_background)
      }

      val prayerUrl = HomeWidgetPlugin.getData(context).getString("prayer_url", null)
      val launchIntent = Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        if (!prayerUrl.isNullOrBlank()) {
          data = android.net.Uri.parse(prayerUrl)
          action = Intent.ACTION_VIEW
        }
      }
      val pendingIntent = PendingIntent.getActivity(
        context,
        2,
        launchIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
      )
      views.setOnClickPendingIntent(R.id.root_prayer, pendingIntent)

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  override fun onReceive(context: Context, intent: Intent) {
    super.onReceive(context, intent)
    if (ACTION_WIDGET_UPDATE == intent.action) {
      val ids = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
      if (ids != null) {
        onUpdate(context, AppWidgetManager.getInstance(context), ids)
      }
    }
  }
}
