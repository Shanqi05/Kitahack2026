class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be empty";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return "This field cannot be empty";
    return null;
  }

  static String? validateBudget(String? value) {
    if (value == null || value.isEmpty) return "Budget cannot be empty";
    final budget = double.tryParse(value);
    if (budget == null) return "Enter a valid number";
    if (budget < 0) return "Budget cannot be negative";
    return null;
  }
}
