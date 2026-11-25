import strutils

type
  Product = object
    name: string
    quantity: int
    price: float

var inventory: seq[Product] = @[]

proc addProduct() =
  var product: Product
  echo "\nEnter product name:"
  product.name = readLine(stdin)
  echo "Enter quantity:"
  product.quantity = parseInt(readLine(stdin))
  echo "Enter price:"
  product.price = parseFloat(readLine(stdin))
  inventory.add(product)
  echo "Product added successfully!"

proc updateQuantity() =
  echo "\nEnter product name to update:"
  let searchName = readLine(stdin)
  for i in 0..<inventory.len:
    if inventory[i].name == searchName:
      echo "Enter new quantity:"
      inventory[i].quantity = parseInt(readLine(stdin))
      echo "Quantity updated successfully!"
      return
  echo "Product not found."

proc displayInventory() =
  echo "\n=== INVENTORY LIST ==="
  if inventory.len == 0:
    echo "Inventory is empty."
  for product in inventory:
    echo "Product: ", product.name
    echo "Quantity: ", product.quantity
    echo "Price: ", product.price
    echo "--------------------"

proc totalValue(): float =
  result = 0.0
  for product in inventory:
    result += float(product.quantity) * product.price

var choice: int

while true:
  echo "\n=== INVENTORY MANAGEMENT ==="
  echo "1. Add Product"
  echo "2. Update Quantity"
  echo "3. Display Inventory"
  echo "4. Calculate Total Value"
  echo "5. Exit"
  echo "Enter choice:"
  choice = parseInt(readLine(stdin))
  case choice
  of 1:
    addProduct()
  of 2:
    updateQuantity()
  of 3:
    displayInventory()
  of 4:
    echo "Total Inventory Value: ", totalValue()
  of 5:
    echo "Exiting program..."
    break
  else:
    echo "Invalid choice."
