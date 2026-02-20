package com.iqbot.flutter

import android.app.*
import android.content.Intent
import android.graphics.PixelFormat
import android.os.*
import android.view.*
import android.widget.TextView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())
    private var intervalSec = 120
    private var countdown = 120

    private val CHANNEL_ID = "iqbot_flutter_overlay"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(2, buildNotification())
        showOverlay()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intervalSec = intent?.getIntExtra("intervalSec", 120) ?: 120
        countdown = intervalSec
        startCountdown()
        return START_STICKY
    }

    override fun onBind(intent: Intent?) = null

    override fun onDestroy() {
        super.onDestroy()
        overlayView?.let { windowManager?.removeView(it) }
        handler.removeCallbacksAndMessages(null)
    }

    private fun showOverlay() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        // Simple overlay: just a small pill showing countdown
        overlayView = TextView(this).apply {
            text = "IQ BOT ●"
            setTextColor(0xFF00E5FF.toInt())
            textSize = 11f
            setPadding(20, 10, 20, 10)
            background = android.graphics.drawable.GradientDrawable().apply {
                setColor(0xE507070D.toInt())
                cornerRadius = 30f
                setStroke(1, 0xFF1E1E3A.toInt())
            }
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = 16; y = 120
        }

        windowManager?.addView(overlayView, params)

        // Drag to move
        overlayView?.setOnTouchListener(object : View.OnTouchListener {
            var ix = 0; var iy = 0; var tx = 0f; var ty = 0f
            override fun onTouch(v: View, e: MotionEvent): Boolean {
                when (e.action) {
                    MotionEvent.ACTION_DOWN -> {
                        ix = params.x; iy = params.y
                        tx = e.rawX;   ty = e.rawY
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = ix + (tx - e.rawX).toInt()
                        params.y = iy + (e.rawY - ty).toInt()
                        windowManager?.updateViewLayout(overlayView, params)
                    }
                }
                return true
            }
        })
    }

    private fun startCountdown() {
        handler.post(object : Runnable {
            override fun run() {
                if (countdown > 0) countdown--
                (overlayView as? TextView)?.text = "IQ BOT  ${formatTime(countdown)}"
                handler.postDelayed(this, 1000)
            }
        })
    }

    private fun formatTime(sec: Int): String {
        val m = sec / 60; val s = sec % 60
        return "$m:${s.toString().padStart(2, '0')}"
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "IQ Bot Overlay", NotificationManager.IMPORTANCE_LOW)
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val openApp = PendingIntent.getActivity(this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("IQ Option Bot Running")
            .setContentText("Tap to open")
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentIntent(openApp)
            .setOngoing(true)
            .build()
    }
}
