package com.washij.washij

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import org.json.JSONArray
import java.util.Random

/**
 * Home-screen widget that shows one painting from the museum, changing every
 * hour. The refresh button shows another painting for the rest of the hour,
 * and tapping the painting opens it in the app.
 */
class PaintingWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) manager.updateAppWidget(id, buildViews(context, id))
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_REFRESH) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val slot = currentSlot()
            val nonce = if (prefs.getLong(KEY_SLOT, -1) == slot) prefs.getInt(KEY_NONCE, 0) else 0
            prefs.edit().putLong(KEY_SLOT, slot).putInt(KEY_NONCE, nonce + 1).apply()
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, PaintingWidgetProvider::class.java))
            onUpdate(context, manager, ids)
        } else {
            super.onReceive(context, intent)
        }
    }

    private fun buildViews(context: Context, widgetId: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.painting_widget)
        views.setOnClickPendingIntent(R.id.widget_refresh, refreshIntent(context, widgetId))
        val painting = pickPainting(context)
        if (painting == null) {
            views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_empty))
            views.setTextViewText(R.id.widget_artist, "")
            return views
        }
        views.setTextViewText(R.id.widget_title, painting.titleArabic)
        views.setTextViewText(R.id.widget_artist, painting.artistArabic)
        loadBitmap(context, painting.imageAsset)?.let {
            views.setImageViewBitmap(R.id.widget_image, it)
        }
        val open = openIntent(context, widgetId, painting.id)
        views.setOnClickPendingIntent(R.id.widget_image, open)
        views.setOnClickPendingIntent(R.id.widget_text, open)
        return views
    }

    private fun refreshIntent(context: Context, widgetId: Int): PendingIntent {
        val intent = Intent(context, PaintingWidgetProvider::class.java).setAction(ACTION_REFRESH)
        return PendingIntent.getBroadcast(
            context, widgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun openIntent(context: Context, widgetId: Int, paintingId: String): PendingIntent {
        // The Flutter router reads the path of this link, e.g. /artwork/museum/<id>.
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("washij:///artwork/museum/$paintingId"))
            .setClass(context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(
            context, widgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private data class Painting(
        val id: String,
        val titleArabic: String,
        val artistArabic: String,
        val imageAsset: String,
    )

    private fun pickPainting(context: Context): Painting? {
        val all = readPaintings(context)
        if (all.isEmpty()) return null
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val slot = currentSlot()
        val nonce = if (prefs.getLong(KEY_SLOT, -1) == slot) prefs.getInt(KEY_NONCE, 0) else 0
        return pickFor(all, slot, nonce)
    }

    private fun pickFor(all: List<Painting>, slot: Long, nonce: Int): Painting {
        val pick = all[Random(slot * 1000003L + nonce * 7919L).nextInt(all.size)]
        if (nonce > 0 && all.size > 1 && pickFor(all, slot, nonce - 1).id == pick.id) {
            return all[(all.indexOf(pick) + 1) % all.size]
        }
        return pick
    }

    private fun readPaintings(context: Context): List<Painting> {
        val text = context.assets.open("flutter_assets/assets/data/museum_paintings_ar.json")
            .bufferedReader(Charsets.UTF_8).use { it.readText() }
        val array = JSONArray(text)
        val list = ArrayList<Painting>()
        for (i in 0 until array.length()) {
            val item = array.getJSONObject(i)
            val asset = item.optString("image_asset", "")
            if (asset.isEmpty() || item.isNull("image_asset")) continue
            list.add(
                Painting(
                    id = item.getString("id"),
                    titleArabic = item.getString("title_ar"),
                    artistArabic = item.getString("artist_ar"),
                    imageAsset = asset,
                ),
            )
        }
        return list
    }

    /** Decodes the whole painting, scaled down so the widget stays within memory limits. */
    private fun loadBitmap(context: Context, asset: String): Bitmap? = try {
        val path = "flutter_assets/$asset"
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        context.assets.open(path).use { BitmapFactory.decodeStream(it, null, bounds) }
        var sample = 1
        while (bounds.outWidth / sample > MAX_SIDE || bounds.outHeight / sample > MAX_SIDE) sample *= 2
        val options = BitmapFactory.Options().apply { inSampleSize = sample }
        context.assets.open(path).use { BitmapFactory.decodeStream(it, null, options) }
    } catch (e: Exception) {
        null
    }

    private fun currentSlot(): Long = System.currentTimeMillis() / 3_600_000L

    companion object {
        const val ACTION_REFRESH = "com.washij.washij.action.REFRESH_PAINTING"
        private const val PREFS = "washij_painting_widget"
        private const val KEY_SLOT = "slot"
        private const val KEY_NONCE = "nonce"
        private const val MAX_SIDE = 1080
    }
}
