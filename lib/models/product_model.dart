// Esta clase se tiene que borrar al final cuando ya tengamos los retaurantes y la
//base de datos funcionando
class Product {
  final String id;
  final String name;
  final String restaurant;
  final double price;
  final String image; // Usaremos URLs o Assets

  Product({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.price,
    this.image = 'https://via.placeholder.com/150', // Placeholder
  });
}

// DATOS DE PRUEBA (Hardcodeados para el Sprint 1)
final List<Product> dummyMenu = [
  Product(
    id: 'p1',
    name: 'Pizza Pepperoni',
    restaurant: 'Pepperonnis',
    price: 5.0,
  ),
  Product(
    id: 'p2',
    name: 'Hamburguesa Chesse',
    restaurant: 'Burger Shack',
    price: 7.5,
  ),
  Product(
    id: 'p3',
    name: 'Malteada Oreo',
    restaurant: 'Holly Shakes',
    price: 4.0,
  ),
  Product(id: 'p4', name: 'Ensalada César', restaurant: 'Subway', price: 6.0),
];
