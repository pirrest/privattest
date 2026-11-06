sealed class ProductsServiceEvent {
  const ProductsServiceEvent();
}

/// The API was unreachable, so the data was served from the local cache.
class ProductsServiceEventServedFromCache extends ProductsServiceEvent {
  const ProductsServiceEventServedFromCache();
}
