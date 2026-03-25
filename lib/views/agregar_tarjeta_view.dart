import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarjeta_model.dart';
import '../services/tarjeta_service.dart';
import '../widgets/tarjeta_visual.dart';
import '../widgets/formulario_tarjeta_widgets.dart';

class AgregarTarjetaView extends StatefulWidget {
  const AgregarTarjetaView({super.key});

  @override
  State<AgregarTarjetaView> createState() => _AgregarTarjetaViewState();
}

class _AgregarTarjetaViewState extends State<AgregarTarjetaView> {
  final _claveFormulario = GlobalKey<FormState>();

  final _bancoCtrl = TextEditingController();
  final _titularCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _vencimientoCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _limiteCtrl = TextEditingController();

  String _tipo = 'credito';
  String _redTarjeta = 'visa';
  int _colorSeleccionado = 0xFF1A237E;
  int? _diaCorte;
  int? _diaPago;
  bool _guardando = false;

  @override
  void dispose() {
    _bancoCtrl.dispose();
    _titularCtrl.dispose();
    _numeroCtrl.dispose();
    _vencimientoCtrl.dispose();
    _cvvCtrl.dispose();
    _limiteCtrl.dispose();
    super.dispose();
  }

  TarjetaModel get _tarjetaPrevia {
    final numero = _numeroCtrl.text.replaceAll(' ', '');
    final ultimos4 = numero.length >= 4
        ? numero.substring(numero.length - 4)
        : '••••';
    final partes = _vencimientoCtrl.text.split('/');
    return TarjetaModel(
      id: 'preview',
      banco: _bancoCtrl.text,
      tipo: _tipo,
      redTarjeta: _redTarjeta,
      titular: _titularCtrl.text,
      ultimos4: ultimos4,
      mesVencimiento: partes.isNotEmpty ? partes[0] : '',
      anioVencimiento: partes.length > 1 ? partes[1] : '',
      numeroEnmascarado: numero.isEmpty
          ? ''
          : numero.length >= 8
          ? '${numero.substring(0, 4)} **** **** $ultimos4'
          : '**** **** **** $ultimos4',
      cvv: _cvvCtrl.text,
      colorTarjeta: _colorSeleccionado,
      creadaEn: DateTime.now(),
    );
  }

  Future<void> _guardar() async {
    if (!_claveFormulario.currentState!.validate()) return;
    setState(() => _guardando = true);

    final numero = _numeroCtrl.text.replaceAll(' ', '');
    final ultimos4 = numero.length >= 4
        ? numero.substring(numero.length - 4)
        : numero;
    final partes = _vencimientoCtrl.text.split('/');

    final tarjeta = TarjetaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      banco: _bancoCtrl.text.trim(),
      tipo: _tipo,
      redTarjeta: _redTarjeta,
      titular: _titularCtrl.text.trim(),
      ultimos4: ultimos4,
      mesVencimiento: partes[0],
      anioVencimiento: partes.length > 1 ? partes[1] : '',
      numeroEnmascarado: numero.length >= 8
          ? '${numero.substring(0, 4)} **** **** $ultimos4'
          : '**** **** **** $ultimos4',
      cvv: _cvvCtrl.text.trim(),
      colorTarjeta: _colorSeleccionado,
      limiteCredito: _limiteCtrl.text.isNotEmpty
          ? double.tryParse(_limiteCtrl.text.replaceAll(',', ''))
          : null,
      diaCorte: _diaCorte,
      diaPago: _diaPago,
      creadaEn: DateTime.now(),
    );

    Provider.of<TarjetaService>(context, listen: false).agregarTarjeta(tarjeta);
    setState(() => _guardando = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101722),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101722),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agregar tarjeta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // ── Vista previa en tiempo real ───────────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([
                _bancoCtrl,
                _titularCtrl,
                _numeroCtrl,
                _vencimientoCtrl,
              ]),
              builder: (_, __) => Center(
                child: TarjetaVisual(
                  tarjeta: _tarjetaPrevia,
                  ancho: double.infinity,
                  alto: 190,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Tipo de tarjeta ───────────────────────────────────────────
            const SeccionFormulario(titulo: 'Tipo de tarjeta'),
            const SizedBox(height: 10),
            SelectorTipoTarjeta(
              seleccionado: _tipo,
              alCambiar: (v) => setState(() => _tipo = v),
            ),

            const SizedBox(height: 20),

            // ── Red de pago ───────────────────────────────────────────────
            const SeccionFormulario(titulo: 'Red de pago'),
            const SizedBox(height: 10),
            SelectorRedTarjeta(
              seleccionada: _redTarjeta,
              alCambiar: (v) => setState(() => _redTarjeta = v),
            ),

            const SizedBox(height: 20),

            // ── Color de tarjeta ──────────────────────────────────────────
            const SeccionFormulario(titulo: 'Color de tarjeta'),
            const SizedBox(height: 10),
            SelectorColorTarjeta(
              colores: coloresDisponiblesTarjeta,
              seleccionado: _colorSeleccionado,
              alCambiar: (c) => setState(() => _colorSeleccionado = c),
            ),

            const SizedBox(height: 20),

            // ── Datos de la tarjeta ───────────────────────────────────────
            const SeccionFormulario(titulo: 'Datos de la tarjeta'),
            const SizedBox(height: 10),

            CampoTextoTarjeta(
              controlador: _bancoCtrl,
              etiqueta: 'Nombre del banco',
              icono: Icons.account_balance_rounded,
              alCambiar: (_) => setState(() {}),
              validador: (v) => (v == null || v.isEmpty)
                  ? 'Ingresa el nombre del banco'
                  : null,
            ),
            const SizedBox(height: 14),

            CampoTextoTarjeta(
              controlador: _titularCtrl,
              etiqueta: 'Nombre del titular',
              icono: Icons.person_rounded,
              textoCapital: true,
              alCambiar: (_) => setState(() {}),
              validador: (v) => (v == null || v.isEmpty)
                  ? 'Ingresa el nombre del titular'
                  : null,
            ),
            const SizedBox(height: 11),

            CampoNumeroTarjeta(
              controlador: _numeroCtrl,
              alCambiar: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CampoVencimientoTarjeta(
                    controlador: _vencimientoCtrl,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: CampoCVVTarjeta(controlador: _cvvCtrl)),
              ],
            ),

            const SizedBox(height: 20),

            // ── Control financiero ────────────────────────────────────────
            const SeccionFormulario(titulo: 'Control financiero'),
            const SizedBox(height: 10),

            CampoTextoTarjeta(
              controlador: _limiteCtrl,
              etiqueta: 'Límite de crédito (opcional)',
              icono: Icons.account_balance_wallet_rounded,
              teclado: TextInputType.number,
              validador: (v) {
                if (v == null || v.isEmpty) return null;
                if (double.tryParse(v.replaceAll(',', '')) == null) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: SelectorDiaTarjeta(
                    etiqueta: 'Día de corte',
                    icono: Icons.calendar_today_rounded,
                    valor: _diaCorte,
                    alCambiar: (d) => setState(() => _diaCorte = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectorDiaTarjeta(
                    etiqueta: 'Día de pago',
                    icono: Icons.payments_rounded,
                    valor: _diaPago,
                    alCambiar: (d) => setState(() => _diaPago = d),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Botón guardar ─────────────────────────────────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF35D6C8),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Guardar tarjeta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
