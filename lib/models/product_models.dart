import 'package:billing_software/models/category_model.dart';

class Product {
  final String image, name;
  final double price;
  final Category category;

  Product({
    required this.image,
    required this.name,
    required this.category,
    required this.price,
  });
}

List<Product> products = [

  /// Drink
  Product(
    image: 'drinks/Evolution Fresh® Mighty Watermelon.png',
    name: ' Evolution Fresh® Mighty Watermelon',
    category: categories[1],
    price: 18,
  ),
  Product(
      image: 'drinks/Mango Dragonfruit Starbucks Refreshers® Beverage.png',
      name: 'Mango Dragonfruit Starbucks Refreshers® Beverage',
      category: categories[1],
      price: 18),
  Product(
      image: 'drinks/Pink Drink Starbucks Refreshers® Beverage.png',
      category: categories[1],
      name: 'Pink Drink Starbucks Refreshers® Beverage',
      price: 18),
  Product(
      image: 'drinks/Pistachio Frappuccino® Blended Beverage.png',
      category: categories[1],
      name: 'Pistachio Frappuccino® Blended Beverage',
      price: 18),
  Product(
      image: 'drinks/Starbucks BAYA™ Energy Mango Guava.png',
      category: categories[1],
      name: 'Starbucks BAYA™ Energy Mango Guava',
      price: 18),


/// Hot coffee

  Product(
      image: 'hot coffee/Cappuccino.png',
      name: 'Cappuccino',
      category: categories[0],
      price: 18),
  Product(
      image: 'hot coffee/Featured Medium Roast - Pike Place® Roast.png',
      category: categories[0],
      name: 'Featured Medium Roast - Pike Place® Roast',
      price: 18),
  Product(
      image: 'hot coffee/Honey Almondmilk Flat White.png',
      category: categories[0],
      name: 'Honey Almondmilk Flat White',
      price: 18),


  ///hot teas
  Product(
      category: categories[3],
      image: 'hot teas/Chai Tea Latte.png',
      name: 'Chai Tea Latte',
      price: 18),
  Product(
      image: 'hot teas/Chai Tea.png',
      category: categories[3],
      name: 'Chai Tea',
      price: 18),
  Product(
      image: 'hot teas/Emperor\'s Clouds & Mist®.png',
      category: categories[3],
      name: 'Emperor\'s Clouds & Mist®',
      price: 18),
  Product(
      image: 'hot teas/Honey Citrus Mint Tea.png',
      category: categories[3],
      name: 'Honey Citrus Mint Tea',
      price: 18),
  Product(
      image: 'hot teas/Matcha Tea Latte.png',
      category: categories[3],
      name: 'Matcha Tea Latte',
      price: 18),



  ///chickens

  Product(
      image: 'chicken/chicken tikka.png',
      category: categories[2],
      name: 'Chicken Tika',
      price: 18),

  Product(
      image: 'chicken/Manchurian Dry.jpg',
      category: categories[2],
      name: 'Manchurian Dry',
      price: 18),
  Product(
      image: 'chicken/Paneer Malai Tikka.jpg',
      category: categories[2],
      name: 'Paneer Malai Tikka',
      price: 18),

  Product(
      image: 'chicken/pepper fry _ Kurryleaves.jpg',
      category: categories[2],
      name: 'pepper fry_Kurryleaves',
      price: 18),

  Product(
      image: 'chicken/tandoori chicken.jpeg',
      category: categories[2],
      name: 'Tandoori Chicken',
      price: 18),

];
