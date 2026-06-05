import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'currency_state.dart';

// CRITERIO: Lógica de negocio - Excepción personalizada para errores de API/red
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

// CRITERIO: Lógica de negocio - Lógica pura separada de la UI usando ChangeNotifier
class CurrencyCubit extends ChangeNotifier {
  CurrencyState _state = CurrencyInitial();
  CurrencyState get state => _state;

  /// CRITERIO: Lógica de negocio - API real con tasas de cambio actualizadas
  /// Fuente: https://github.com/fawazahmed0/currency-api (datos diarios vía CDN)
  Future<double> _fetchConversionRate(String from, String to) async {
    final fromL = from.toLowerCase();
    final toL = to.toLowerCase();

    final uri = Uri.parse(
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$fromL.json',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw NetworkException(
        'Error de la API (código ${response.statusCode}). Verifique las divisas.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = body[fromL] as Map<String, dynamic>;
    final rate = (rates[toL] as num).toDouble();

    return rate;
  }

  /// Valida que la entrada no esté vacía y sea un número válido.
  /// CRITERIO: Manejo de errores - try-catch con FormatException
  double _validateAmount(String amountStr) {
    if (amountStr.trim().isEmpty) {
      throw const FormatException('El campo de cantidad no puede estar vacío.');
    }

    final amount = double.tryParse(amountStr);
    if (amount == null) {
      throw FormatException('"$amountStr" no es un número válido.');
    }
    if (amount < 0) {
      throw const FormatException('La cantidad no puede ser negativa.');
    }
    return amount;
  }

  /// Método principal de conversión. Orquesta validación, llamada asíncrona y actualización de estado.
  /// CRITERIO: Lógica de negocio - Método que procesa la conversión de forma asíncrona
  Future<void> convert({
    required String amountStr,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    _state = CurrencyLoading();
    notifyListeners();

    try {
      // CRITERIO: Manejo de errores - Validación con try-catch
      final amount = _validateAmount(amountStr);

      // Si la moneda origen y destino son la misma, la tasa es 1.0
      final rate = fromCurrency == toCurrency
          ? 1.0
          : await _fetchConversionRate(fromCurrency, toCurrency);
      final result = amount * rate;

      _state = CurrencySuccess(result, rate, fromCurrency, toCurrency);
    } on FormatException catch (e) {
      // CRITERIO: Manejo de errores - Captura específica de FormatException
      _state = CurrencyError(e.message);
    } on NetworkException catch (e) {
      // CRITERIO: Manejo de errores - Captura de excepción personalizada de red
      _state = CurrencyError(e.message);
    } catch (e) {
      // CRITERIO: Manejo de errores - Captura genérica para cualquier otro error
      _state = CurrencyError('Error inesperado: ${e.toString()}');
    }

    notifyListeners();
  }
}
