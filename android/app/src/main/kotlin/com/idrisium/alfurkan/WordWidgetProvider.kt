package com.idrisium.alfurkan

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.app.PendingIntent
import android.graphics.BitmapFactory
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class WordWidgetProvider : AppWidgetProvider() {

  private companion object {
    const val ACTION_WIDGET_UPDATE = "es.antonborri.home_widget.action.WIDGET_UPDATE"
  }

  override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
    for (widgetId in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.word_widget)

      val imagePath = HomeWidgetPlugin.getData(context).getString("word_image", null)
      if (!imagePath.isNullOrBlank()) {
        val normalizedPath = imagePath.removePrefix("file://")
        val bitmap = BitmapFactory.decodeFile(normalizedPath)
        if (bitmap != null) {
          views.setImageViewBitmap(R.id.word_image, bitmap)
        } else {
          views.setImageViewResource(R.id.word_image, R.drawable.launch_background)
        }
      } else {
        views.setImageViewResource(R.id.word_image, R.drawable.launch_background)
      }

      val launchIntent = Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
      }
      val pendingIntent = PendingIntent.getActivity(
        context,
        1,
        launchIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
      )
      views.setOnClickPendingIntent(R.id.root_word, pendingIntent)

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
