// CRITERIO: Lógica de negocio - Jerarquía de estados para la conversión
// Cada estado representa una fase del proceso y transporta los datos necesarios.

abstract class CurrencyState {}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencySuccess extends CurrencyState {
  final double result;
  final double rate;
  final String from;
  final String to;
  CurrencySuccess(this.result, this.rate, this.from, this.to);
}

class CurrencyError extends CurrencyState {
  final String message;
  CurrencyError(this.message);
}
