enum ProductsViewMode {
  grid,
  table;

  ProductsViewMode get toggled => switch (this) {
    grid => table,
    table => grid,
  };
}
