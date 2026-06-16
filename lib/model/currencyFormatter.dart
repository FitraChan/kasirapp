class CurrencyFormatter {
  final String locale;
  final String currencySymbol;

  CurrencyFormatter({
    this.locale = 'en_US',
    this.currencySymbol = '\$',
  });

  String format(String amount) {
    double numericAmount = double.tryParse(amount) ??
        0.0; // Use 0.0 as a default value if parsing fails

    // Define the currency symbol (you can change it as needed)

    // Use the toStringAsFixed method to format the number with two decimal places
    String formattedAmount = numericAmount.toStringAsFixed(2);

    final parts = formattedAmount.split('.');
    final mainPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    // Combine the main part, decimal point, and currency symbol
    String result = '$mainPart.${parts[1]}';

    return result;
  }
}
