package com.binderdex.app

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.app.Activity
import android.content.Intent
import android.graphics.LinearGradient
import android.graphics.Shader
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.animation.DecelerateInterpolator
import android.view.animation.OvershootInterpolator
import android.widget.TextView
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

/**
 * Ecrã de arranque animado (nativo).
 *
 * Fluxo: o splash do sistema (Android 12+) mostra primeiro o ícone estático
 * (logo-icon-512) sobre o vermelho da marca e entrega a esta Activity, que
 * anima o logo real (pop-in + halo) e o wordmark, sobre fundo vermelho a ecrã
 * inteiro. Ao fim de ~2s navega para a [MainActivity] (a UI Flutter).
 */
class SplashActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private var navigated = false
    private var glowPulse: ObjectAnimator? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Tem de ser chamado antes de super.onCreate para ligar o splash do SO.
        installSplashScreen()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        val logoGroup = findViewById<View>(R.id.logoGroup)
        val glow = findViewById<View>(R.id.glow)
        val wordmark = findViewById<TextView>(R.id.wordmark)
        val credit = findViewById<View>(R.id.credit)
        applyBrandGradient(findViewById(R.id.creditBrand))

        // Estado inicial (escondido) antes de animar.
        logoGroup.alpha = 0f
        logoGroup.scaleX = 0.7f
        logoGroup.scaleY = 0.7f
        wordmark.alpha = 0f
        wordmark.translationY = dp(24f)
        credit.alpha = 0f

        // Logo: pop-in com leve overshoot.
        logoGroup.animate()
            .alpha(1f).scaleX(1f).scaleY(1f)
            .setDuration(620)
            .setInterpolator(OvershootInterpolator(1.6f))
            .withEndAction { startGlowPulse(glow) }
            .start()

        // Wordmark: desliza de baixo + fade.
        wordmark.animate()
            .alpha(1f).translationY(0f)
            .setStartDelay(340)
            .setDuration(520)
            .setInterpolator(DecelerateInterpolator())
            .start()

        // Crédito: fade suave.
        credit.animate()
            .alpha(1f)
            .setStartDelay(620)
            .setDuration(520)
            .start()

        // Avança para a app passado o tempo de exibição.
        handler.postDelayed({ goToMain() }, 2000L)
    }

    /** Pinta o "hivecode" com o gradiente azul→roxo→rosa do logo do hivecode. */
    private fun applyBrandGradient(brand: TextView) {
        brand.post {
            val w = brand.width.toFloat()
            if (w <= 0f) return@post
            brand.paint.shader = LinearGradient(
                0f, 0f, w, 0f,
                intArrayOf(
                    0xFF4FA9FF.toInt(), // azul
                    0xFFB06BFF.toInt(), // roxo
                    0xFFFF63C9.toInt(), // rosa
                ),
                null,
                Shader.TileMode.CLAMP,
            )
            brand.invalidate()
        }
    }

    /** Halo a "respirar" enquanto o splash está visível. */
    private fun startGlowPulse(glow: View) {
        if (isFinishing) return
        glowPulse = ObjectAnimator.ofFloat(glow, View.ALPHA, 1f, 0.55f).apply {
            duration = 1100
            repeatMode = ValueAnimator.REVERSE
            repeatCount = ValueAnimator.INFINITE
            interpolator = DecelerateInterpolator()
            start()
        }
    }

    private fun dp(value: Float): Float = value * resources.displayMetrics.density

    private fun goToMain() {
        if (navigated) return
        navigated = true
        handler.removeCallbacksAndMessages(null)
        glowPulse?.cancel()
        startActivity(Intent(this, MainActivity::class.java))
        // Sem animação de transição para um "handoff" suave para o Flutter.
        overridePendingTransition(0, 0)
        finish()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        glowPulse?.cancel()
        super.onDestroy()
    }
}
