program InventoryManagement;

type
  Product = record
    name: string;
    quantity: integer;
    price: real;
  end;
  InventoryArray = array[1..100] of Product;

var
  inventory: InventoryArray;
  count, choice: integer;

procedure AddProduct;
begin
  if count >= 100 then
  begin
    writeln('Inventory is full.');
    exit;
  end;

  count := count + 1;
  writeln;
  write('Enter product name: ');
  readln(inventory[count].name);
  write('Enter quantity: ');
  readln(inventory[count].quantity);
  write('Enter price: ');
  readln(inventory[count].price);
  writeln('Product added successfully!');
end;

procedure UpdateQuantity;
var
  searchName: string;
  i: integer;
begin
  write('Enter product name to update: ');
  readln(searchName);

  for i := 1 to count do
  begin
    if inventory[i].name = searchName then
    begin
      write('Enter new quantity: ');
      readln(inventory[i].quantity);
      writeln('Quantity updated successfully!');
      exit;
    end;
  end;
  writeln('Product not found.');
end;

procedure DisplayInventory;
var
  i: integer;
begin
  writeln;
  writeln('=== INVENTORY LIST ===');
  if count = 0 then
    writeln('Inventory is empty.');

  for i := 1 to count do
  begin
    writeln('Product: ', inventory[i].name);
    writeln('Quantity: ', inventory[i].quantity);
    writeln('Price: ', inventory[i].price:0:2);
    writeln('--------------------');
  end;
end;

function TotalValue: real;
var
  i: integer;
begin
  TotalValue := 0;
  for i := 1 to count do
    TotalValue := TotalValue +
      (inventory[i].quantity * inventory[i].price);
end;

begin
  count := 0;
  repeat
    writeln;
    writeln('=== INVENTORY MANAGEMENT ===');
    writeln('1. Add Product');
    writeln('2. Update Quantity');
    writeln('3. Display Inventory');
    writeln('4. Calculate Total Value');
    writeln('5. Exit');
    write('Enter choice: ');
    readln(choice);

    case choice of
      1: AddProduct;
      2: UpdateQuantity;
      3: DisplayInventory;
      4: writeln('Total Inventory Value: ', TotalValue:0:2);
      5: writeln('Exiting program...');
    else
      writeln('Invalid choice.');
    end;
  until choice = 5;
end.
