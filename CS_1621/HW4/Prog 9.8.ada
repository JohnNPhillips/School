-- Write a generic Ada function that takes an array of generic elements and
-- a scalar of the same type as the array elements. The type of the array ele-
-- ments and the scalar is the generic parameter. The subscripts of the array
-- are positive integers. The function must search the given array for the
-- given scalar and return the subscript of the scalar in the array. If the sca-
-- lar is not in the array, the function must return  –1 . Instantiate the func-
-- tion for  Integer and  Float types and test both.

generic
	type Element_T is private;
procedure FindIndex(X, Y : in out Element_T);

procedure FindIndex(array(X range <>) of Element_T; Y : in Element_T) is
begin
	for I in X'Range loop
		if X (I) == Y then
			return I;
		end if
	end loop;
	
	return -1;
end FindIndex;

function FindIndex_Integer is new FindIndex
   (Element_T => Integer);
function FindIndex_Float is new FindIndex
   (Element_T => Float);

array (A1 range <>) of Integer;
array (A2 range <>) of Float;
A1 := (1, 2, 3, 4, 5);
A2 := (1.1, 2.2, 3.3, 4.4, 5.5);
FindIndex_Integer(X => A1; Y => 3);
FindIndex_Integer(X => A2; Y => 3.3);