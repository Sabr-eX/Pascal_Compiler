program ReverseNumber;
var
  number, reversedNumber, remainder: Integer;
begin
  write("Enter a number to reverse:", 3, number);
  read(number);
  reversedNumber := 0;
  while number <> 0 do
  begin
    remainder := number % 10;
    reversedNumber := reversedNumber * 10 + remainder;
    number := number / 10;
  end;
  write("The reversed number is: ");
  write(reversedNumber);
end.
