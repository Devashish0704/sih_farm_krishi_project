import 'package:e_commerce_app_flutter/models/Product.dart';

final Map<ProductType, List<String>> productCategories = {
  ProductType.freshProduce: ['Vegetables', 'Fruits', 'Leafy Greens'],
  ProductType.grainsAndPulses: ['Cereals', 'Pulses'],
  ProductType.dairyProducts: ['Milk', 'Cheese', 'Yogurt', 'Butter'],
  ProductType.meatAndPoultry: ['Chicken', 'Fish', 'Eggs'],
  ProductType.organicProducts: [
    'Organic Vegetables',
    'Organic Fruits',
    'Organic Honey'
  ],
  ProductType.processedProducts: ['Flour', 'Pickles', 'Dried Fruits'],
  ProductType.spicesAndHerbs: ['Spices', 'Herbs'],
  ProductType.flowersAndPlants: ['Fresh Flowers', 'Potted Plants', 'Seeds'],
  ProductType.beverages: ['Juices', 'Herbal Teas', 'Coffee'],
  ProductType.animalFeed: ['Cattle Feed', 'Poultry Feed', 'Fish Feed'],
  ProductType.fertilizersAndManure: [
    'Organic Fertilizers',
    'Vermicompost',
    'Compost'
  ],
  ProductType.miscellaneous: ['Honey', 'Natural Oils', 'Handcrafted Items'],
};

final Map<String, List<String>> categoryProducts = {
  'Vegetables': ['Tomato', 'Potato', 'Onion', 'Cucumber', 'Carrot', 'Spinach'],
  'Fruits': ['Apple', 'Banana', 'Mango', 'Grapes', 'Orange', 'Papaya'],
  'Leafy Greens': ['Spinach', 'Kale', 'Lettuce', 'Collard Greens'],
  'Cereals': ['Wheat', 'Rice', 'Maize', 'Barley'],
  'Pulses': ['Lentils', 'Chickpeas', 'Green Gram', 'Black Gram'],
  'Milk': ['Cow Milk', 'Buffalo Milk', 'Goat Milk'],
  'Cheese': ['Cheddar', 'Mozzarella', 'Parmesan'],
  'Yogurt': ['Greek Yogurt', 'Flavored Yogurt', 'Probiotic Yogurt'],
  'Butter': ['Salted Butter', 'Unsalted Butter'],
  'Chicken': ['Broiler Chicken', 'Country Chicken'],
  'Fish': ['Salmon', 'Tilapia', 'Catfish'],
  'Eggs': ['Chicken Eggs', 'Duck Eggs', 'Quail Eggs'],
  'Organic Vegetables': ['Organic Tomato', 'Organic Spinach'],
  'Organic Fruits': ['Organic Apple', 'Organic Banana'],
  'Organic Honey': ['Raw Honey', 'Multi-floral Honey'],
  'Flour': ['Wheat Flour', 'Rice Flour', 'Cornmeal'],
  'Pickles': ['Mango Pickle', 'Lemon Pickle', 'Mixed Vegetable Pickle'],
  'Dried Fruits': ['Raisins', 'Almonds', 'Cashews'],
  'Spices': ['Turmeric', 'Cumin', 'Coriander', 'Black Pepper'],
  'Herbs': ['Mint', 'Basil', 'Thyme', 'Oregano'],
  'Fresh Flowers': ['Roses', 'Lilies', 'Tulips'],
  'Potted Plants': ['Succulents', 'Ferns', 'Flowering Plants'],
  'Seeds': ['Vegetable Seeds', 'Flower Seeds', 'Grass Seeds'],
  'Juices': ['Orange Juice', 'Apple Juice', 'Mixed Fruit Juice'],
  'Herbal Teas': ['Green Tea', 'Chamomile Tea', 'Peppermint Tea'],
  'Coffee': ['Arabica Coffee', 'Robusta Coffee', 'Instant Coffee'],
  'Cattle Feed': ['Cattle Pellets', 'Grass Silage', 'Alfalfa'],
  'Poultry Feed': ['Layer Feed', 'Broiler Feed', 'Starter Feed'],
  'Fish Feed': ['Floating Pellets', 'Sinking Pellets'],
  'Organic Fertilizers': ['Cow Dung Manure', 'Neem Cake'],
  'Vermicompost': ['Worm Castings', 'Composted Manure'],
  'Compost': ['Green Waste Compost', 'Mixed Organic Compost'],
  'Honey': ['Wildflower Honey', 'Eucalyptus Honey'],
  'Natural Oils': ['Coconut Oil', 'Mustard Oil', 'Olive Oil'],
  'Handcrafted Items': ['Clay Pots', 'Handwoven Baskets', 'Jute Bags'],
};

final Map<String, List<String>> productVarieties = {
  // Vegetables
  'Tomato': [
    'Roma Tomato',
    'Cherry Tomato',
    'Beefsteak Tomato',
    'Heirloom Tomato',
    'Grape Tomato'
  ],
  'Potato': [
    'Russet Potato',
    'Red Potato',
    'Sweet Potato',
    'Fingerling Potato',
    'Purple Potato'
  ],
  'Onion': [
    'Red Onion',
    'Yellow Onion',
    'White Onion',
    'Spring Onion',
    'Shallots'
  ],
  'Cucumber': ['English Cucumber', 'Persian Cucumber', 'Armenian Cucumber'],
  'Carrot': ['Nantes Carrot', 'Imperator Carrot', 'Danvers Carrot'],
  'Spinach': ['Savoy Spinach', 'Flat-Leaf Spinach', 'Baby Spinach'],

  // Fruits
  'Apple': [
    'Red Delicious',
    'Granny Smith',
    'Fuji',
    'Honeycrisp',
    'Golden Delicious'
  ],
  'Banana': ['Cavendish Banana', 'Red Banana', 'Plantain'],
  'Mango': ['Alphonso Mango', 'Haden Mango', 'Tommy Atkins Mango'],
  'Grapes': ['Red Grapes', 'Green Grapes', 'Black Grapes', 'Thompson Seedless'],
  'Orange': ['Navel Orange', 'Valencia Orange', 'Blood Orange'],
  'Papaya': ['Hawaiian Papaya', 'Mexican Papaya'],

  // Leafy Greens
  'Kale': ['Curly Kale', 'Tuscan Kale', 'Red Russian Kale'],
  'Lettuce': ['Iceberg Lettuce', 'Romaine Lettuce', 'Butterhead Lettuce'],
  'Collard Greens': ['Georgia Collards', 'Morris Heading'],

  // Cereals
  'Wheat': ['Durum Wheat', 'Hard Red Wheat', 'Soft White Wheat'],
  'Rice': ['Basmati', 'Jasmine', 'Brown Rice', 'Wild Rice', 'Sticky Rice'],
  'Maize': ['Flint Corn', 'Dent Corn', 'Popcorn'],
  'Barley': ['Hulled Barley', 'Pearl Barley'],

  // Pulses
  'Lentils': ['Red Lentils', 'Green Lentils', 'Brown Lentils'],
  'Chickpeas': ['Desi Chickpeas', 'Kabuli Chickpeas'],
  'Green Gram': ['Whole Green Gram', 'Split Green Gram'],
  'Black Gram': ['Split Black Gram', 'Whole Black Gram'],

  // Dairy Products
  'Cow Milk': ['Whole Milk', 'Skimmed Milk', 'Organic Milk'],
  'Buffalo Milk': ['Raw Buffalo Milk', 'Pasteurized Buffalo Milk'],
  'Goat Milk': ['Fresh Goat Milk', 'Powdered Goat Milk'],
  'Cheese': ['Cheddar', 'Mozzarella', 'Parmesan', 'Gouda', 'Brie'],
  'Yogurt': ['Greek Yogurt', 'Flavored Yogurt', 'Probiotic Yogurt'],
  'Butter': ['Salted Butter', 'Unsalted Butter'],

  // Meat and Poultry
  'Chicken': ['Broiler Chicken', 'Country Chicken'],
  'Fish': ['Salmon', 'Tilapia', 'Catfish', 'Mackerel', 'Tuna'],
  'Chicken Eggs': ['White Eggs', 'Brown Eggs', 'Free-Range Eggs'],
  'Duck Eggs': ['Organic Duck Eggs', 'Salted Duck Eggs'],
  'Quail Eggs': ['Fresh Quail Eggs', 'Processed Quail Eggs'],

  // Organic Products
  'Organic Tomato': ['Roma Organic Tomato', 'Cherry Organic Tomato'],
  'Organic Spinach': ['Baby Organic Spinach', 'Flat-Leaf Organic Spinach'],
  'Organic Apple': ['Granny Smith Organic Apple', 'Fuji Organic Apple'],
  'Organic Banana': ['Cavendish Organic Banana'],
  'Raw Honey': ['Wildflower Raw Honey', 'Forest Raw Honey'],
  'Multi-floral Honey': [
    'Spring Multi-floral Honey',
    'Summer Multi-floral Honey'
  ],

  // Processed Products
  'Wheat Flour': ['Whole Wheat Flour', 'Refined Wheat Flour'],
  'Rice Flour': ['White Rice Flour', 'Brown Rice Flour'],
  'Cornmeal': ['Fine Cornmeal', 'Coarse Cornmeal'],
  'Mango Pickle': ['Spicy Mango Pickle', 'Sweet Mango Pickle'],
  'Lemon Pickle': ['Tangy Lemon Pickle', 'Sweet Lemon Pickle'],
  'Mixed Vegetable Pickle': [
    'Spicy Vegetable Pickle',
    'Sweet Vegetable Pickle'
  ],
  'Raisins': ['Golden Raisins', 'Black Raisins'],
  'Almonds': ['Raw Almonds', 'Blanched Almonds'],
  'Cashews': ['Whole Cashews', 'Split Cashews'],

  // Spices and Herbs
  'Turmeric': ['Dried Turmeric', 'Turmeric Powder'],
  'Cumin': ['Whole Cumin Seeds', 'Ground Cumin'],
  'Coriander': ['Whole Coriander Seeds', 'Coriander Powder'],
  'Black Pepper': ['Whole Black Peppercorns', 'Ground Black Pepper'],
  'Mint': ['Fresh Mint', 'Dried Mint'],
  'Basil': ['Sweet Basil', 'Holy Basil'],
  'Thyme': ['Fresh Thyme', 'Dried Thyme'],
  'Oregano': ['Mediterranean Oregano', 'Mexican Oregano'],

  // Flowers and Plants
  'Roses': ['Red Roses', 'Yellow Roses', 'Pink Roses'],
  'Lilies': ['White Lilies', 'Asiatic Lilies'],
  'Tulips': ['Red Tulips', 'Yellow Tulips'],
  'Succulents': ['Aloe Vera', 'Jade Plant'],
  'Ferns': ['Boston Fern', 'Maidenhair Fern'],

  // Beverages
  'Orange Juice': ['Freshly Squeezed Orange Juice', 'Packaged Orange Juice'],
  'Apple Juice': ['Fresh Apple Juice', 'Packaged Apple Juice'],
  'Mixed Fruit Juice': ['Tropical Mixed Juice', 'Berry Mixed Juice'],
  'Green Tea': ['Matcha Green Tea', 'Lemon Green Tea'],
  'Chamomile Tea': ['Loose Chamomile Tea', 'Chamomile Tea Bags'],
  'Peppermint Tea': ['Loose Peppermint Tea', 'Peppermint Tea Bags'],
  'Arabica Coffee': ['Ground Arabica Coffee', 'Whole Bean Arabica Coffee'],
  'Robusta Coffee': ['Ground Robusta Coffee', 'Whole Bean Robusta Coffee'],

  // Feed and Fertilizers
  'Cattle Pellets': [
    'Protein-Rich Cattle Pellets',
    'Mineral-Enriched Cattle Pellets'
  ],
  'Grass Silage': ['Maize Grass Silage', 'Napier Grass Silage'],
  'Layer Feed': ['Starter Layer Feed', 'Grower Layer Feed'],
  'Broiler Feed': ['Starter Broiler Feed', 'Grower Broiler Feed'],
  'Floating Pellets': [
    'High Protein Floating Pellets',
    'Basic Floating Pellets'
  ],
  'Sinking Pellets': ['Nutritious Sinking Pellets', 'Economic Sinking Pellets'],
  'Cow Dung Manure': ['Sun-Dried Cow Dung', 'Composted Cow Dung'],
  'Neem Cake': ['Powdered Neem Cake', 'Granulated Neem Cake'],
  'Green Waste Compost': ['Vegetable Waste Compost', 'Fruit Waste Compost'],
  'Mixed Organic Compost': ['Kitchen Waste Compost', 'Farm Waste Compost'],

  // Miscellaneous
  'Wildflower Honey': ['Raw Wildflower Honey', 'Filtered Wildflower Honey'],
  'Eucalyptus Honey': ['Organic Eucalyptus Honey', 'Raw Eucalyptus Honey'],
  'Coconut Oil': ['Cold-Pressed Coconut Oil', 'Refined Coconut Oil'],
  'Mustard Oil': ['Cold-Pressed Mustard Oil', 'Double Filtered Mustard Oil'],
  'Olive Oil': ['Extra Virgin Olive Oil', 'Light Olive Oil'],
  'Clay Pots': ['Terracotta Clay Pots', 'Hand-Painted Clay Pots'],
  'Handwoven Baskets': ['Jute Baskets', 'Cotton Rope Baskets'],
  'Jute Bags': ['Eco-Friendly Jute Bags', 'Decorative Jute Bags'],
};

final List<String> seedCompanies = [
  'Bayer',
  'Syngenta',
  'Mahyco',
  'ICAR Seeds',
  'Rijk Zwaan',
  'Sakata',
  'Dow AgroSciences',
  'Monsanto',
];

final List<String> grades = [
  'Premium',
  'First Grade',
  'Second Grade',
  'Economy Grade',
];

final List<String> quantityUnits = ['kg', 'quintal', 'ton'];
