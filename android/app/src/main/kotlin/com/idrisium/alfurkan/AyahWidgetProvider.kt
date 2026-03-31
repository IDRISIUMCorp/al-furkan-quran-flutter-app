package com.idrisium.alfurkan

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.app.PendingIntent
import android.graphics.BitmapFactory
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class AyahWidgetProvider : AppWidgetProvider() {

  private companion object {
    const val ACTION_WIDGET_UPDATE = "es.antonborri.home_widget.action.WIDGET_UPDATE"
  }

  override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
    for (widgetId in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.ayah_widget)

      val imagePath = HomeWidgetPlugin.getData(context).getString("ayah_image", null)
      val surahName = HomeWidgetPlugin.getData(context).getString("surah_name", "") ?: ""

      views.setTextViewText(R.id.surah_name, surahName)

      if (!imagePath.isNullOrBlank()) {
        val normalizedPath = imagePath.removePrefix("file://")
        val bitmap = BitmapFactory.decodeFile(normalizedPath)
        if (bitmap != null) {
          views.setImageViewBitmap(R.id.ayah_image, bitmap)
        } else {
          views.setImageViewResource(R.id.ayah_image, R.drawable.launch_background)
        }
      } else {
        views.setImageViewResource(R.id.ayah_image, R.drawable.launch_background)
      }

      // Launch app on tap
      val launchIntent = Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
      }
      val pendingIntent = PendingIntent.getActivity(
        context,
        0,
        launchIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
      )
      views.setOnClickPendingIntent(R.id.root, pendingIntent)

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  override fun onReceive(context: Context, intent: Intent) {
    super.onReceive(context, intent)
    // Ensure widget refresh after file updates
    if (ACTION_WIDGET_UPDATE == intent.action) {
      val ids = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
      if (ids != null) {
        onUpdate(context, AppWidgetManager.getInstance(context), ids)
      }
    }
  }
}
