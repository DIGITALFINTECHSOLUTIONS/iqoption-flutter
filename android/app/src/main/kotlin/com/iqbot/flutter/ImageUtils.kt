package com.iqbot.flutter

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import java.io.File

object ImageUtils {

    fun loadBitmap(ctx: Context, pathOrUri: String): Bitmap? {
        return try {
            if (pathOrUri.startsWith("content://")) {
                val stream = ctx.contentResolver.openInputStream(Uri.parse(pathOrUri))
                BitmapFactory.decodeStream(stream).also { stream?.close() }
            } else {
                BitmapFactory.decodeFile(pathOrUri)
            }
        } catch (e: Exception) { null }
    }

    fun findTemplate(screen: Bitmap, template: Bitmap, minConf: Float): IntArray? {
        val sw = screen.width;   val sh = screen.height
        val tw = template.width; val th = template.height
        if (tw > sw || th > sh) return null

        val screenPx   = toGrayscale(screen,   sw, sh)
        val templatePx = toGrayscale(template, tw, th)

        val tMean = mean(templatePx)
        val tStd  = std(templatePx, tMean)
        if (tStd == 0.0) return null

        var bestVal = -1.0
        var bestX = -1; var bestY = -1

        for (y in 0..(sh - th)) {
            for (x in 0..(sw - tw)) {
                val corr = ncc(screenPx, sw, x, y, templatePx, tw, th, tMean, tStd)
                if (corr > bestVal) { bestVal = corr; bestX = x; bestY = y }
            }
        }

        return if (bestVal >= minConf) intArrayOf(bestX + tw/2, bestY + th/2) else null
    }

    private fun toGrayscale(bmp: Bitmap, w: Int, h: Int): IntArray {
        val pixels = IntArray(w * h)
        bmp.getPixels(pixels, 0, w, 0, 0, w, h)
        return IntArray(w * h) { i ->
            val r = (pixels[i] shr 16) and 0xFF
            val g = (pixels[i] shr 8)  and 0xFF
            val b =  pixels[i]         and 0xFF
            (r * 77 + g * 150 + b * 29) shr 8
        }
    }

    private fun mean(arr: IntArray) = arr.sumOf { it.toLong() }.toDouble() / arr.size

    private fun std(arr: IntArray, mean: Double): Double {
        var s = 0.0
        arr.forEach { s += (it - mean) * (it - mean) }
        return Math.sqrt(s / arr.size)
    }

    private fun ncc(screen: IntArray, sw: Int, ox: Int, oy: Int,
                    tmpl: IntArray, tw: Int, th: Int,
                    tMean: Double, tStd: Double): Double {
        val n = tw * th
        val patch = IntArray(n) { i -> screen[(oy + i/tw) * sw + (ox + i%tw)] }
        val pMean = mean(patch)
        val pStd  = std(patch, pMean)
        if (pStd == 0.0) return 0.0
        var corr = 0.0
        for (i in 0 until n) {
            corr += ((patch[i] - pMean) / pStd) * ((tmpl[i] - tMean) / tStd)
        }
        return corr / n
    }
}
