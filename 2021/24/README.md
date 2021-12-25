# Solving

Each `inp` sublist follows the same structure, where only three values are different between each program out of the available 18 lines. I've replaced them with `A`, `B`, and `C`:

```
inp w
mul x 0
add x z
mod x 26
div z A
add x B
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y C
mul y x
add z y
```

What is noteworthy is that only the values from the `z` register carry over to each step. Both the `x` and `y` registers are zeroed out before getting used in the ALU on lines `2` and `9` respectively. Also, the value for `A` seems to only be `1` or `26`.

Next, let's attempt to simplify each ALU into a singular function.

- The value for `x` can be determined as `w == (z % 26 + B) ? 0 : 1`
- The value for `y` can be determined as `(w + C) * x`
- The value for `z` can be determined as `z / A * (25 * x + 1) + y`.

From my own puzzle input, the list of `A`, `B` and `C` values are:

```dart
final aSet = {1, 1, 1, 26, 1, 26, 26, 1, 1, 1, 26, 26, 26, 26};
final bSet = {14, 15, 13, -10, 14, -3, -14, 12, 14, 12, -6, -6, -2, -9};
final cSet = {8, 11, 2, 11, 1, 5, 10, 6, 1, 11, 9, 14, 11, 2};
```

## Spitballing

Let's choose a simple `w` of 1. We know `x` must be 1 since the addition `(z % 26 + B)` is 14, out of the valid range for a `w` value. With the chosen `w` value, `y` becomes 9. The resulting `z` is must be the value of `y` because the first division `z / A` makes the multiplication result 0.

Next, let's use that `z` of 9 and another `w` of 1. No matter what, if `B` is greater than 9, `x` will always be 1. Our `y` value is now 12. The resulting `z` value becomes `9 * 26 + 12` or 246.

Step 3. Let's continue using `w` of 1. We know from the previous step observation that `x` must be 1. Our `y` register takes on a value of 3. And `z` is `246 * 26 + 3` or 6399.

Step 4 is where things get interesting. It's the first time that the `aSet` value is 26. And where `B` is negative. `6399 % 26 - 10` is -7 so `x` must be `1` no matter what `w` value we have. Let's go with `w` of 1, making `y` 12. The computation for `z` is a bit different now that we're dividing by 26 and not 1. When dividing, we floor. Therefore, `z / A` becomes 246.

Wait a minute--that was a previous Z value. In fact, if we take a look at our `aSet` and `bSet`, the value is 26 in `aSet` for every time the value in `bSet` is negative. There is also the same number of negative numbers to positive numbers.

Could there be a pattern emerging here? I'll find out when it's not 2:30am on Christmas Day.
