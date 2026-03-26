import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarjeta_model.dart';
import '../services/tarjeta_service.dart';
import '../widgets/tarjeta_visual.dart';
import 'agregar_tarjeta_view.dart';
import 'editar_tarjeta_view.dart';

class TarjetasView extends StatelessWidget {
  const TarjetasView({super.key});

  static const Color _colorFondo = Color(0xFF101722);
  static const Color _colorAcento = Color(0xFF35D6C8);

  @override
  Widget build(BuildContext context) {
    final tarjetaService = Provider.of<TarjetaService>(context);
    final tarjetas = tarjetaService.tarjetas;

    return Scaffold(
      backgroundColor: _colorFondo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Tarjetas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                
                ],
              ),
            ),

            // ── Contador ──────────────────────────────────────────────────
            if (tarjetas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Text(
                  '${tarjetas.length} tarjeta${tarjetas.length != 1 ? 's' : ''} registrada${tarjetas.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 13,
                  ),
                ),
              ),

            // ── Lista de tarjetas o pantalla vacía ────────────────────────
            Expanded(
              child: tarjetas.isEmpty
                  ? _PantallaVacia(alAgregar: () => _irAgregarTarjeta(context))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: tarjetas.length,
                      itemBuilder: (context, indice) {
                        final tarjeta = tarjetas[indice];
                        return _ItemTarjeta(
                          tarjeta: tarjeta,
                          alEditar: () => _irEditarTarjeta(context, tarjeta),
                          alEliminar: () =>
                              _confirmarEliminar(context, tarjeta, tarjetaService),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Botón flotante
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _irAgregarTarjeta(context),
        backgroundColor: _colorAcento,
        icon: const Icon(Icons.add_card_rounded, color: Colors.black87),
        label: const Text(
          'Agregar tarjeta',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _irAgregarTarjeta(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgregarTarjetaView()),
    );
  }

  void _irEditarTarjeta(BuildContext context, TarjetaModel tarjeta) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarTarjetaView(tarjeta: tarjeta)),
    );
  }

  void _confirmarEliminar(
    BuildContext context,
    TarjetaModel tarjeta,
    TarjetaService servicio,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar tarjeta',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro que deseas eliminar la tarjeta terminada en ${tarjeta.ultimos4}?',
          style: const TextStyle(color: Color(0xFF8899AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF8899AA)),
            ),
          ),
          TextButton(
            onPressed: () {
              servicio.borrarTarjeta(tarjeta.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Item individual de tarjeta ────────────────────────────────────────────────
class _ItemTarjeta extends StatelessWidget {
  final TarjetaModel tarjeta;
  final VoidCallback alEditar;
  final VoidCallback alEliminar;

  const _ItemTarjeta({
    required this.tarjeta,
    required this.alEditar,
    required this.alEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Tarjeta visual
          TarjetaVisual(tarjeta: tarjeta, ancho: double.infinity),

          const SizedBox(height: 12),

          // Detalles + botones
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2535),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                // Info de fechas y límite
                Row(
                  children: [
                    if (tarjeta.limiteCredito != null) ...[
                      _ChipInfo(
                        icono: Icons.account_balance_wallet_rounded,
                        etiqueta:
                            'Límite: L ${tarjeta.limiteCredito!.toStringAsFixed(0)}',
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (tarjeta.diaCorte != null)
                      _ChipInfo(
                        icono: Icons.calendar_today_rounded,
                        etiqueta: 'Corte: día ${tarjeta.diaCorte}',
                      ),
                    if (tarjeta.diaPago != null) ...[
                      const SizedBox(width: 8),
                      _ChipInfo(
                        icono: Icons.payments_rounded,
                        etiqueta: 'Pago: día ${tarjeta.diaPago}',
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: alEditar,
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: Color(0xFF35D6C8),
                        ),
                        label: const Text(
                          'Editar',
                          style: TextStyle(color: Color(0xFF35D6C8)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF35D6C8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: alEliminar,
                        icon: const Icon(
                          Icons.delete_rounded,
                          size: 16,
                          color: Color(0xFFFF6B6B),
                        ),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(color: Color(0xFFFF6B6B)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF6B6B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _ChipInfo({required this.icono, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: const Color(0xFF35D6C8)),
        const SizedBox(width: 4),
        Text(
          etiqueta,
          style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
        ),
      ],
    );
  }
}

// ─── Pantalla vacía ─────────────────────────────────────────────────────────────
class _PantallaVacia extends StatelessWidget {
  final VoidCallback alAgregar;

  const _PantallaVacia({required this.alAgregar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF35D6C8).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_off_rounded,
              color: Color(0xFF35D6C8),
              size: 42,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No tienes tarjetas aún',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega tu primera tarjeta de crédito\no débito para comenzar',
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: alAgregar,
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('Agregar tarjeta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF35D6C8),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
