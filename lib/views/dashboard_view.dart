import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/tarjeta_service.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const Color _colorFondo = Color(0xFF101722);
  static const Color _colorAcento = Color(0xFF35D6C8);

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final nombreUsuario = usuario?.displayName?.split(' ').first ?? 'Usuario';
    final tarjetaService = Provider.of<TarjetaService>(context);
    final cantidadTarjetas = tarjetaService.tarjetas.length;

    return Scaffold(
      backgroundColor: _colorFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Saludo ────────────────────────────────────────────────────
              Text(
                'Hola, $nombreUsuario 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Aquí está tu resumen financiero',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 14),
              ),

              const SizedBox(height: 24),

              // ── Cards de resumen ──────────────────────────────────────────
              _TituloSeccion(titulo: 'Resumen'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CardResumen(
                      icono: Icons.credit_card_rounded,
                      etiqueta: 'Mis tarjetas',
                      valor: '$cantidadTarjetas',
                      colorIcono: _colorAcento,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CardResumen(
                      icono: Icons.attach_money_rounded,
                      etiqueta: 'Gasto este mes',
                      valor: 'L 0.00',
                      colorIcono: const Color(0xFFFF7E5F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CardResumen(
                      icono: Icons.account_balance_wallet_rounded,
                      etiqueta: 'Límite disponible',
                      valor: tarjetaService.tarjetas.isEmpty
                          ? 'L 0.00'
                          : 'L ${tarjetaService.tarjetas.where((t) => t.limiteCredito != null).fold<double>(0, (acc, t) => acc + (t.limiteCredito ?? 0)).toStringAsFixed(2)}',
                      colorIcono: const Color(0xFF7E5FFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CardResumen(
                      icono: Icons.trending_up_rounded,
                      etiqueta: 'Ahorro estimado',
                      valor: 'L 0.00',
                      colorIcono: const Color(0xFF5FD068),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Gráfica de barras simulada ────────────────────────────────
              _TituloSeccion(titulo: 'Gastos mensuales'),
              const SizedBox(height: 12),
              _CardContenido(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2025 — Vista anual',
                      style: TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GraficaBarras(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Ene', style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                        Text('Feb', style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                        Text('Mar', style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                        Text('Abr', style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                        Text('May', style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                        Text('Jun', style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Gráfica circular simulada ─────────────────────────────────
              _TituloSeccion(titulo: 'Distribución de gastos'),
              const SizedBox(height: 12),
              _CardContenido(
                child: Row(
                  children: [
                    const _GraficaCircular(),
                    const SizedBox(width: 20),
                    Expanded(child: _LeyendaCircular()),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Actividad reciente ────────────────────────────────────────
              _TituloSeccion(titulo: 'Actividad reciente'),
              const SizedBox(height: 12),
              _CardContenido(
                child: Column(
                  children: const [
                    _ItemActividad(
                      icono: Icons.shopping_cart_rounded,
                      nombre: 'ComprasNet Honduras',
                      fecha: 'Hoy, 10:30 AM',
                      monto: '- L 520.00',
                      colorMonto: Color(0xFFFF6B6B),
                    ),
                    Divider(color: Color(0xFF2A3A50), height: 20),
                    _ItemActividad(
                      icono: Icons.local_dining_rounded,
                      nombre: 'Restaurante La Cumbre',
                      fecha: 'Ayer, 1:15 PM',
                      monto: '- L 380.00',
                      colorMonto: Color(0xFFFF6B6B),
                    ),
                    Divider(color: Color(0xFF2A3A50), height: 20),
                    _ItemActividad(
                      icono: Icons.local_gas_station_rounded,
                      nombre: 'Gasolinera UNO',
                      fecha: '22 mar, 8:00 AM',
                      monto: '- L 800.00',
                      colorMonto: Color(0xFFFF6B6B),
                    ),
                    Divider(color: Color(0xFF2A3A50), height: 20),
                    _ItemActividad(
                      icono: Icons.arrow_downward_rounded,
                      nombre: 'Depósito recibido',
                      fecha: '20 mar, 3:45 PM',
                      monto: '+ L 5,000.00',
                      colorMonto: Color(0xFF35D6C8),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────────

class _TituloSeccion extends StatelessWidget {
  final String titulo;

  const _TituloSeccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CardResumen extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color colorIcono;

  const _CardResumen({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorIcono.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: colorIcono, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            etiqueta,
            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContenido extends StatelessWidget {
  final Widget child;

  const _CardContenido({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _GraficaBarras extends StatelessWidget {
  final List<double> alturas = const [0.4, 0.65, 0.5, 0.8, 0.55, 0.7];
  final List<Color> colores = const [
    Color(0xFF35D6C8),
    Color(0xFF35D6C8),
    Color(0xFF35D6C8),
    Color(0xFF35D6C8),
    Color(0xFF35D6C8),
    Color(0xFF2BBFB2),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(alturas.length, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 32,
                height: 100 * alturas[i],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colores[i], colores[i].withOpacity(0.4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _GraficaCircular extends StatelessWidget {
  const _GraficaCircular();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(110, 110),
            painter: _PintorCircular(),
          ),
          const Text(
            '100%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PintorCircular extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = size.width / 2 - 10;
    const grosor = 16.0;

    final segmentos = [
      (const Color(0xFF35D6C8), 0.35),
      (const Color(0xFF7E5FFF), 0.25),
      (const Color(0xFFFF7E5F), 0.25),
      (const Color(0xFF5FD068), 0.15),
    ];

    double anguloActual = -90 * (3.14159 / 180);

    for (final seg in segmentos) {
      final paint = Paint()
        ..color = seg.$1
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..strokeCap = StrokeCap.round;

      final barrido = 2 * 3.14159 * seg.$2 - 0.1;
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: radio),
        anguloActual,
        barrido,
        false,
        paint,
      );
      anguloActual += barrido + 0.1;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeyendaCircular extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ItemLeyenda(color: Color(0xFF35D6C8), etiqueta: 'Alimentación', porcentaje: '35%'),
        SizedBox(height: 10),
        _ItemLeyenda(color: Color(0xFF7E5FFF), etiqueta: 'Transporte', porcentaje: '25%'),
        SizedBox(height: 10),
        _ItemLeyenda(color: Color(0xFFFF7E5F), etiqueta: 'Compras', porcentaje: '25%'),
        SizedBox(height: 10),
        _ItemLeyenda(color: Color(0xFF5FD068), etiqueta: 'Otros', porcentaje: '15%'),
      ],
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String etiqueta;
  final String porcentaje;

  const _ItemLeyenda({
    required this.color,
    required this.etiqueta,
    required this.porcentaje,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            etiqueta,
            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
          ),
        ),
        Text(
          porcentaje,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ItemActividad extends StatelessWidget {
  final IconData icono;
  final String nombre;
  final String fecha;
  final String monto;
  final Color colorMonto;

  const _ItemActividad({
    required this.icono,
    required this.nombre,
    required this.fecha,
    required this.monto,
    required this.colorMonto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF35D6C8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: const Color(0xFF35D6C8), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                fecha,
                style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          monto,
          style: TextStyle(
            color: colorMonto,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
