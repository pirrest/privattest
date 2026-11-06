T? castOrNull<T>(dynamic value) => value is T ? value : null;
T cast<T>(dynamic value, {required T orElse}) => value is T ? value : orElse;
