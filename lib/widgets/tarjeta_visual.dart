import 'package:flutter/material.dart';
import '../models/tarjeta_model.dart';

class TarjetaVisual extends StatelessWidget {
  final TarjetaModel tarjeta;
  final double ancho;
  final double alto;

  const TarjetaVisual({
    super.key,
    required this.tarjeta,
    this.ancho = 340,
    this.alto = 200,
  });

  @override
  Widget build(BuildContext context) {
    final colorBase = Color(tarjeta.colorTarjeta);
    final colorOscuro = HSLColor.fromColor(colorBase)
        .withLightness(
          (HSLColor.fromColor(colorBase).lightness - 0.18).clamp(0.0, 1.0),
        )
        .toColor();

    return Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [colorBase, colorOscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorBase.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos decorativos de fondo
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Contenido de la tarjeta debito o credito
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: banco y  tipo de tarjeta, ya sea amex, visa o mastercard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tarjeta.banco.isEmpty ? 'Mi Tarjeta' : tarjeta.banco,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _LogoRedTarjeta(red: tarjeta.redTarjeta),
                  ],
                ),

                const SizedBox(height: 18),

                // Chip EMV simulado
                Container(
                  width: 42,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomPaint(painter: _ChipPainter()),
                ),

                const Spacer(),

                // Número de tarjeta
                Text(
                  tarjeta.numeroEnmascarado.isEmpty
                      ? '•••• •••• •••• ••••'
                      : tarjeta.numeroEnmascarado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 11),

                // Titular + Vencimiento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TITULAR',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          tarjeta.titular.isEmpty
                              ? 'NOMBRE TITULAR'
                              : tarjeta.titular.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'VENCE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${tarjeta.mesVencimiento.isEmpty ? 'MM' : tarjeta.mesVencimiento}/${tarjeta.anioVencimiento.isEmpty ? 'AA' : tarjeta.anioVencimiento}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge de tipo (crédito/débito)
          Positioned(
            top: 22,
            left: 22,
            child: Container(
              margin: const EdgeInsets.only(top: 28),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tarjeta.tipo == 'credito' ? 'CRÉDITO' : 'DÉBITO',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// creacion de logos en la tarjeta
class _LogoRedTarjeta extends StatelessWidget {
  final String red;

  const _LogoRedTarjeta({required this.red});

  @override
  Widget build(BuildContext context) {
    switch (red.toLowerCase()) {
      case 'mastercard':
        return SizedBox(
          width: 46,
          height: 28,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEB001B),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF79E1B),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'amex':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Color(0xFF006FCF),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        );

      default: // visa
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        );
    }
  }
}

// dibujar el chip EMV
class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC09B30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Lineas del chip
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.35),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.65),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
