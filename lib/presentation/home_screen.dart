import 'package:flutter/material.dart';
import '../business_logic/currency_cubit.dart';
import '../business_logic/currency_state.dart';

// CRITERIO: UI - Interfaz limpia y moderna con Material Design 3
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cubit = CurrencyCubit();
  final _amountController = TextEditingController();

  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';

  static const _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD',
    'MXN', 'BRL', 'ARS', 'CHF', 'CNY', 'DOP',
  ];

  @override
  void dispose() {
    // CRITERIO: Buenas prácticas - Dispose de controladores y recursos
    _amountController.dispose();
    _cubit.dispose();
    super.dispose();
  }

  void _onConvert() {
    _cubit.convert(
      amountStr: _amountController.text,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
    );
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  // CRITERIO: UI - Sección reactiva que responde visualmente a los estados
  Widget _buildResultCard(CurrencyState state) {
    if (state is CurrencyInitial) {
      return const SizedBox.shrink();
    }

    if (state is CurrencyLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is CurrencySuccess) {
      // CRITERIO: UI - Contenedor verde con el resultado en caso de éxito
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade300, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 36),
            const SizedBox(height: 8),
            Text(
              'Resultado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_amountController.text} ${state.from} = ${state.result.toStringAsFixed(2)} ${state.to}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasa: 1 ${state.from} = ${state.rate.toStringAsFixed(4)} ${state.to}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (state is CurrencyError) {
      // CRITERIO: UI - Contenedor rojo con icono de advertencia y mensaje de error
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade300, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 36),
            const SizedBox(height: 8),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.red.shade900,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Divisas'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CRITERIO: UI - TextField para la cantidad con teclado numérico
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cantidad',
                hintText: 'Ej: 100.50',
                prefixIcon: const Icon(Icons.monetization_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CRITERIO: UI - DropdownButton para divisa de origen y destino + botón swap
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    decoration: InputDecoration(
                      labelText: 'De',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _fromCurrency = v!),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Invertir divisas',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: InputDecoration(
                      labelText: 'A',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _toCurrency = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // CRITERIO: UI - Botón de acción para ejecutar la conversión
            FilledButton.icon(
              onPressed: _onConvert,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Convertir'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // CRITERIO: UI - Sección reactiva con ValueListenableBuilder (a través de ListenableBuilder)
            ListenableBuilder(
              listenable: _cubit,
              builder: (context, _) => _buildResultCard(_cubit.state),
            ),
          ],
        ),
      ),
    );
  }
}
