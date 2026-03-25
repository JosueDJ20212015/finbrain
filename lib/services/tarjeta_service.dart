import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/tarjeta_model.dart';

class TarjetaService extends ChangeNotifier {
  final List<TarjetaModel> _tarjetas = [];

  UnmodifiableListView<TarjetaModel> get tarjetas =>
      UnmodifiableListView(_tarjetas);

  void agregarTarjeta(TarjetaModel tarjeta) {
    _tarjetas.add(tarjeta);
    notifyListeners();
  }

  void editarTarjeta(TarjetaModel tarjetaActualizada) {
    final indice = _tarjetas.indexWhere((t) => t.id == tarjetaActualizada.id);
    if (indice != -1) {
      _tarjetas[indice] = tarjetaActualizada;
      notifyListeners();
    }
  }

  void borrarTarjeta(String id) {
    _tarjetas.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void limpiar() {
    _tarjetas.clear();
    notifyListeners();
  }
}
